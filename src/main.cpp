#include <Arduino.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
}

#include "bootloader/post.h"
#include "config.h"
#include "lua_api/lua_gpio.h"
#include "lua_api/lua_sd.h"
#include "lua_api/lua_serial.h"
#include "lua_api/lua_system.h"
#include "lua_api/lua_wifi.h"

SemaphoreHandle_t g_luaMutex = nullptr;
static lua_State* g_luaState = nullptr;

namespace {

String readFileFromSD(const char* path, bool* ok = nullptr) {
  File file = SD.open(path, FILE_READ);
  if (!file) {
    if (ok) {
      *ok = false;
    }
    return "";
  }

  String content;
  content.reserve(file.size() + 16);
  while (file.available()) {
    content += static_cast<char>(file.read());
  }
  file.close();

  if (ok) {
    *ok = true;
  }
  return content;
}

bool executeLuaScriptFromFile(lua_State* L, const char* path) {
  bool readOk = false;
  const String source = readFileFromSD(path, &readOk);
  if (!readOk) {
    Serial.printf("[LUA][ERROR] Nelze otevřít script: %s\n", path);
    return false;
  }

  // Načtení a spuštění Lua skriptu.
  const int loadStatus = luaL_loadbuffer(L, source.c_str(), source.length(), path);
  if (loadStatus != LUA_OK) {
    Serial.printf("[LUA][ERROR] Chyba kompilace %s: %s\n", path, lua_tostring(L, -1));
    lua_pop(L, 1);
    return false;
  }

  const int runStatus = lua_pcall(L, 0, LUA_MULTRET, 0);
  if (runStatus != LUA_OK) {
    Serial.printf("[LUA][ERROR] Runtime chyba %s: %s\n", path, lua_tostring(L, -1));
    lua_pop(L, 1);
    return false;
  }

  // Boot script návratové hodnoty zde nevyužíváme.
  lua_settop(L, 0);
  return true;
}

int lua_dofile_from_sd(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);

  bool readOk = false;
  const String source = readFileFromSD(path, &readOk);
  if (!readOk) {
    return luaL_error(L, "dofile: nelze otevřít soubor %s", path);
  }

  const int loadStatus = luaL_loadbuffer(L, source.c_str(), source.length(), path);
  if (loadStatus != LUA_OK) {
    return lua_error(L);
  }

  if (lua_pcall(L, 0, LUA_MULTRET, 0) != LUA_OK) {
    return lua_error(L);
  }

  // Odstraníme vstupní argument path, aby na stacku zůstaly jen návratové hodnoty skriptu.
  lua_remove(L, 1);
  return lua_gettop(L);
}

void registerLuaModules(lua_State* L) {
  register_lua_serial(L);
  register_lua_gpio(L);
  register_lua_wifi(L);
  register_lua_sd(L);
  register_lua_system(L);

  // Přepíšeme dofile tak, aby četl soubory ze SD karty.
  lua_pushcfunction(L, lua_dofile_from_sd);
  lua_setglobal(L, "dofile");
}

bool initLua() {
  g_luaState = luaL_newstate();
  if (!g_luaState) {
    Serial.println(F("[LUA][FATAL] Nelze vytvořit Lua VM."));
    return false;
  }

  luaL_openlibs(g_luaState);
  registerLuaModules(g_luaState);

  Serial.println(F("[LUA] Lua VM inicializována."));
  return true;
}

}  // namespace

void setup() {
  Serial.begin(Config::SERIAL_BAUD);
  delay(200);
  Serial.println();
  Serial.println(F("=== ESP-OS v0.0.1 boot ==="));

  g_luaMutex = xSemaphoreCreateMutex();
  if (!g_luaMutex) {
    Serial.println(F("[FATAL] Nelze vytvořit Lua mutex."));
    while (true) {
      delay(1000);
    }
  }

  if (!Bootloader::runPOST(Config::SD_CS_PIN)) {
    Serial.println(F("[FATAL] POST selhal. Boot zastaven."));
    while (true) {
      delay(1000);
    }
  }

  // Ujistíme se, že SD je přimountována i po POST.
  if (!SD.begin(Config::SD_CS_PIN)) {
    Serial.println(F("[FATAL] SD mount selhal po POST."));
    while (true) {
      delay(1000);
    }
  }

  if (!initLua()) {
    while (true) {
      delay(1000);
    }
  }

  Serial.printf("[BOOT] Spouštím %s\n", Config::BOOT_SCRIPT_PATH);
  if (!executeLuaScriptFromFile(g_luaState, Config::BOOT_SCRIPT_PATH)) {
    Serial.println(F("[FATAL] Boot Lua script selhal."));
    while (true) {
      delay(1000);
    }
  }

  Serial.println(F("[BOOT] Převzetí řízení Lua kernelu dokončeno."));
}

void loop() {
  // Hlavní smyčka je řízená Lua skripty.
  delay(50);
}
