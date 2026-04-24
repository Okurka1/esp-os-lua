#include "lua_serial.h"

#include <Arduino.h>
#include <freertos/FreeRTOS.h>
#include <freertos/semphr.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
}

#include "config.h"

namespace {

class ScopedLuaLock {
 public:
  ScopedLuaLock() {
    locked_ = g_luaMutex && (xSemaphoreTake(g_luaMutex, pdMS_TO_TICKS(Config::LUA_API_LOCK_TIMEOUT_MS)) == pdTRUE);
  }

  ~ScopedLuaLock() {
    if (locked_) {
      xSemaphoreGive(g_luaMutex);
    }
  }

  bool ok() const { return locked_; }

 private:
  bool locked_ = false;
};

int lua_serial_print(lua_State* L) {
  const char* text = luaL_checkstring(L, 1);
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "serial.print: nelze získat mutex");
  }

  Serial.print(text);
  return 0;
}

String read_line_from_serial(bool mask_input) {
  String input;
  input.reserve(64);

  while (true) {
    if (Serial.available() > 0) {
      const char c = static_cast<char>(Serial.read());

      // Enter: ukonči vstup jen pokud uživatel něco zadal.
      if (c == '\n' || c == '\r') {
        if (input.length() > 0) {
          break;
        }
        continue;
      }

      // Backspace / Delete.
      if (c == 8 || c == 127) {
        if (input.length() > 0) {
          input.remove(input.length() - 1);
          Serial.print("\b \b");
        }
        continue;
      }

      input += c;
      if (mask_input) {
        Serial.print('*');
      } else {
        Serial.print(c);
      }
    }

    delay(10);
  }

  // Posuň kurzor na nový řádek po Enteru.
  Serial.println();
  return input;
}

int lua_serial_read(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "serial.read: nelze získat mutex");
  }

  const String input = read_line_from_serial(false);
  lua_pushstring(L, input.c_str());
  return 1;
}

int lua_serial_read_password(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "serial.readPassword: nelze získat mutex");
  }

  const String input = read_line_from_serial(true);
  lua_pushstring(L, input.c_str());
  return 1;
}

int lua_serial_read_key(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "serial.readKey: nelze získat mutex");
  }

  // Čekej na první nerežijní znak bez nutnosti Enter.
  while (!Serial.available()) {
    delay(10);
  }

  char c = static_cast<char>(Serial.read());
  while (c == '\r' || c == '\n') {
    while (!Serial.available()) {
      delay(10);
    }
    c = static_cast<char>(Serial.read());
  }

  // Echo vybraného znaku + nový řádek kvůli čitelnosti menu.
  Serial.println(c);

  char str[2] = {c, '\0'};
  lua_pushstring(L, str);
  return 1;
}

int lua_serial_available(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "serial.available: nelze získat mutex");
  }

  lua_pushinteger(L, Serial.available());
  return 1;
}

}  // namespace

void register_lua_serial(lua_State* L) {
  lua_newtable(L);
  lua_pushcfunction(L, lua_serial_print);
  lua_setfield(L, -2, "print");
  lua_pushcfunction(L, lua_serial_read);
  lua_setfield(L, -2, "read");
  lua_pushcfunction(L, lua_serial_read_password);
  lua_setfield(L, -2, "readPassword");
  lua_pushcfunction(L, lua_serial_read_key);
  lua_setfield(L, -2, "readKey");
  lua_pushcfunction(L, lua_serial_available);
  lua_setfield(L, -2, "available");
  lua_setglobal(L, "serial");
}
