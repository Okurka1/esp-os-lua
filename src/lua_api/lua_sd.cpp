#include "lua_sd.h"

#include <Arduino.h>
#include <FS.h>
#include <SD.h>
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

String readAll(File& file) {
  String content;
  content.reserve(file.size() + 16);
  while (file.available()) {
    content += static_cast<char>(file.read());
  }
  return content;
}

int lua_sd_exists(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.exists: nelze získat mutex");
  }

  lua_pushboolean(L, SD.exists(path));
  return 1;
}

int lua_sd_read(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);

  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.read: nelze získat mutex");
  }

  File file = SD.open(path, FILE_READ);
  if (!file) {
    lua_pushnil(L);
    lua_pushfstring(L, "Soubor nelze otevřít: %s", path);
    return 2;
  }

  String content = readAll(file);
  file.close();

  lua_pushlstring(L, content.c_str(), content.length());
  return 1;
}

int lua_sd_write(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);
  size_t len = 0;
  const char* content = luaL_checklstring(L, 2, &len);

  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.write: nelze získat mutex");
  }

  // FILE_WRITE na některých platformách appenduje.
  // Pro konfigurační soubory potřebujeme deterministický overwrite.
  if (SD.exists(path) && !SD.remove(path)) {
    lua_pushboolean(L, false);
    lua_pushfstring(L, "Soubor nelze přepsat (remove selhal): %s", path);
    return 2;
  }

  File file = SD.open(path, FILE_WRITE);
  if (!file) {
    lua_pushboolean(L, false);
    lua_pushfstring(L, "Soubor nelze otevřít pro zápis: %s", path);
    return 2;
  }

  const size_t written = file.write(reinterpret_cast<const uint8_t*>(content), len);
  file.close();

  if (written != len) {
    lua_pushboolean(L, false);
    lua_pushfstring(L, "Zapsáno jen %d z %d bajtů", static_cast<int>(written), static_cast<int>(len));
    return 2;
  }

  lua_pushboolean(L, true);
  return 1;
}

int lua_sd_available(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.available: nelze získat mutex");
  }

  File root = SD.open("/");
  if (!root) {
    lua_pushboolean(L, false);
    return 1;
  }

  root.close();
  lua_pushboolean(L, true);
  return 1;
}

int lua_sd_size(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.size: nelze získat mutex");
  }

  lua_pushinteger(L, static_cast<lua_Integer>(SD.totalBytes()));
  return 1;
}

int lua_sd_free(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.free: nelze získat mutex");
  }

  const uint64_t total = SD.totalBytes();
  const uint64_t used = SD.usedBytes();
  lua_pushinteger(L, static_cast<lua_Integer>(total - used));
  return 1;
}

}  // namespace

void register_lua_sd(lua_State* L) {
  lua_newtable(L);
  lua_pushcfunction(L, lua_sd_exists);
  lua_setfield(L, -2, "exists");
  lua_pushcfunction(L, lua_sd_available);
  lua_setfield(L, -2, "available");
  lua_pushcfunction(L, lua_sd_read);
  lua_setfield(L, -2, "read");
  lua_pushcfunction(L, lua_sd_write);
  lua_setfield(L, -2, "write");
  lua_pushcfunction(L, lua_sd_size);
  lua_setfield(L, -2, "size");
  lua_pushcfunction(L, lua_sd_free);
  lua_setfield(L, -2, "free");
  lua_setglobal(L, "sd");
}
