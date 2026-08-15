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
  // Limit file size to prevent memory issues (max 32KB for sd.read())
  const size_t maxSize = 32768;
  size_t fileSize = file.size();
  
  if (fileSize > maxSize) {
    Serial.printf("[WARN] File is too large (%u bytes), truncating to %u bytes\n", 
                  fileSize, maxSize);
    fileSize = maxSize;
  }

  String content;
  content.reserve(fileSize + 16);
  
  size_t bytesRead = 0;
  while (file.available() && bytesRead < fileSize) {
    content += static_cast<char>(file.read());
    bytesRead++;
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

int lua_sd_list(lua_State* L) {
  const char* path = luaL_optstring(L, 1, "/");

  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.list: nelze získat mutex");
  }

  File dir = SD.open(path);
  if (!dir) {
    lua_pushnil(L);
    lua_pushfstring(L, "Adresář nelze otevřít: %s", path);
    return 2;
  }

  if (!dir.isDirectory()) {
    dir.close();
    lua_pushnil(L);
    lua_pushfstring(L, "Cesta není adresář: %s", path);
    return 2;
  }

  lua_newtable(L);
  int index = 1;

  File entry = dir.openNextFile();
  while (entry) {
    lua_newtable(L);
    
    lua_pushstring(L, entry.name());
    lua_setfield(L, -2, "name");
    
    lua_pushboolean(L, entry.isDirectory());
    lua_setfield(L, -2, "isDir");
    
    if (!entry.isDirectory()) {
      lua_pushinteger(L, entry.size());
      lua_setfield(L, -2, "size");
    }
    
    lua_rawseti(L, -2, index++);
    entry.close();
    entry = dir.openNextFile();
  }

  dir.close();
  return 1;
}

int lua_sd_remove(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);

  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.remove: nelze získat mutex");
  }

  if (!SD.exists(path)) {
    lua_pushboolean(L, false);
    lua_pushfstring(L, "Soubor neexistuje: %s", path);
    return 2;
  }

  bool success = SD.remove(path);
  lua_pushboolean(L, success);
  
  if (!success) {
    lua_pushfstring(L, "Nelze smazat soubor: %s", path);
    return 2;
  }
  
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
  lua_pushcfunction(L, lua_sd_list);
  lua_setfield(L, -2, "list");
  lua_pushcfunction(L, lua_sd_remove);
  lua_setfield(L, -2, "remove");
  lua_setglobal(L, "sd");
}
