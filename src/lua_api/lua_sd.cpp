#include "lua_sd.h"

#include <Arduino.h>
#include <FS.h>
#include <SD.h>
#include <freertos/FreeRTOS.h>
#include <freertos/semphr.h>
#include <stdlib.h>

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

// SD Card total bytes (64-bit)
int lua_sd_totalBytes(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.totalBytes: nelze získat mutex");
  }

  if (!SD.begin()) {
    lua_pushnil(L);
    return 1;
  }

  uint64_t totalBytes = SD.totalBytes();
  lua_pushnumber(L, static_cast<lua_Number>(totalBytes));
  return 1;
}

// SD Card used bytes (64-bit)
int lua_sd_usedBytes(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.usedBytes: nelze získat mutex");
  }

  if (!SD.begin()) {
    lua_pushnil(L);
    return 1;
  }

  uint64_t usedBytes = SD.usedBytes();
  lua_pushnumber(L, static_cast<lua_Number>(usedBytes));
  return 1;
}

int lua_sd_size(lua_State* L) {
  // backward-compat alias for sd.totalBytes()
  return lua_sd_totalBytes(L);
}

int lua_sd_free(lua_State* L) {
  // backward-compat alias for (sd.totalBytes() - sd.usedBytes())
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "sd.free: nelze získat mutex");
  }

  if (!SD.begin()) {
    lua_pushnil(L);
    return 1;
  }

  const uint64_t total = SD.totalBytes();
  const uint64_t used = SD.usedBytes();
  lua_pushnumber(L, static_cast<lua_Number>(total - used));
  return 1;
}

// Custom require() pro SD kartu
static int lua_sd_require(lua_State* L) {
  const char* module_name = luaL_checkstring(L, 1);

  // Mimic Lua require cache (package.loaded[module_name])
  lua_getglobal(L, "package");            // stack: package
  lua_getfield(L, -1, "loaded");          // stack: package, loaded
  lua_getfield(L, -1, module_name);        // stack: package, loaded, loaded[module]
  if (!lua_isnil(L, -1)) {
    return 1;  // already loaded
  }
  lua_pop(L, 1);  // pop nil

  String name = String(module_name);
  name.replace('.', '/');

  String filepath = "/ESP-OS/" + name + ".lua";
  String source_path = filepath;

  size_t size = 0;
  char* buffer = nullptr;

  {
    ScopedLuaLock lock;
    if (!lock.ok()) {
      return luaL_error(L, "sd_require: nelze získat mutex");
    }

    Serial.printf("[SD_REQUIRE] Loading module: %s -> %s\n", module_name, filepath.c_str());

    File file = SD.open(filepath.c_str(), FILE_READ);
    if (!file) {
      filepath = "/ESP-OS/" + name + "/init.lua";
      source_path = filepath;
      Serial.printf("[SD_REQUIRE] Trying: %s\n", filepath.c_str());
      file = SD.open(filepath.c_str(), FILE_READ);

      if (!file) {
        return luaL_error(L, "module '%s' not found on SD (tried '%s' and '/ESP-OS/%s/init.lua')",
                          module_name,
                          ("/ESP-OS/" + name + ".lua").c_str(),
                          name.c_str());
      }
    }

    size = static_cast<size_t>(file.size());
    buffer = static_cast<char*>(malloc(size + 1));
    if (!buffer) {
      file.close();
      return luaL_error(L, "Out of memory loading module: %s", module_name);
    }

    const size_t read_bytes = file.read(reinterpret_cast<uint8_t*>(buffer), size);
    file.close();

    if (read_bytes != size) {
      free(buffer);
      return luaL_error(L, "Failed to read module '%s' from SD (%d/%d bytes)",
                        module_name,
                        static_cast<int>(read_bytes),
                        static_cast<int>(size));
    }

    buffer[size] = '\0';
    Serial.printf("[SD_REQUIRE] Loaded %d bytes from %s\n", static_cast<int>(size), source_path.c_str());
  }

  const int load_status = luaL_loadbuffer(L, buffer, size, source_path.c_str());
  free(buffer);
  buffer = nullptr;

  if (load_status != LUA_OK) {
    return lua_error(L);  // propagate syntax/load error
  }

  // Execute loaded chunk (0 args, 1 result)
  if (lua_pcall(L, 0, 1, 0) != LUA_OK) {
    return lua_error(L);  // propagate runtime error
  }

  // package.loaded[module_name] = result (or true if nil)
  if (lua_isnil(L, -1)) {
    lua_pop(L, 1);
    lua_pushboolean(L, 1);
  }

  lua_pushvalue(L, -1);                    // duplicate result for return
  lua_setfield(L, -3, module_name);        // loaded[module_name] = result

  // Keep only return value on stack
  lua_replace(L, 1);                       // arg1 <- result
  lua_settop(L, 1);
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
  lua_pushcfunction(L, lua_sd_totalBytes);
  lua_setfield(L, -2, "totalBytes");
  lua_pushcfunction(L, lua_sd_usedBytes);
  lua_setfield(L, -2, "usedBytes");
  lua_pushcfunction(L, lua_sd_size);
  lua_setfield(L, -2, "size");
  lua_pushcfunction(L, lua_sd_free);
  lua_setfield(L, -2, "free");
  lua_setglobal(L, "sd");

  lua_register(L, "sd_require", lua_sd_require);
}
