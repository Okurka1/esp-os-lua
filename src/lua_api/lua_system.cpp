#include "lua_system.h"

#include <Arduino.h>
#include <esp_sleep.h>
#include <esp_system.h>
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

int lua_system_restart(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.restart: nelze získat mutex");
  }

  Serial.println(F("[SYSTEM] Restart zařízení..."));
  delay(100);
  ESP.restart();
  return 0;
}

// Deep sleep - vypnutí zařízení
int lua_system_shutdown(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.shutdown: nelze získat mutex");
  }

  // Probuzení BOOT tlačítkem (GPIO0), aktivní LOW
  esp_sleep_enable_ext0_wakeup(GPIO_NUM_0, 0);
  esp_deep_sleep_start();

  return 0;  // sem by se běžně nemělo dojít
}

int lua_system_heap(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.heap: nelze získat mutex");
  }

  lua_pushinteger(L, ESP.getFreeHeap());
  return 1;
}

int lua_system_heap_size(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.heapSize: nelze získat mutex");
  }

  lua_pushinteger(L, ESP.getHeapSize());
  return 1;
}

int lua_system_flash_size(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.flashSize: nelze získat mutex");
  }

  lua_pushinteger(L, ESP.getFlashChipSize());
  return 1;
}

int lua_system_chip_model(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.chipModel: nelze získat mutex");
  }

  lua_pushstring(L, ESP.getChipModel());
  return 1;
}

int lua_system_millis(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.millis: nelze získat mutex");
  }

  lua_pushinteger(L, millis());
  return 1;
}

int lua_system_delay(lua_State* L) {
  const uint32_t ms = static_cast<uint32_t>(luaL_checkinteger(L, 1));

  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "system.delay: nelze získat mutex");
  }

  delay(ms);
  return 0;
}

}  // namespace

void register_lua_system(lua_State* L) {
  lua_newtable(L);
  lua_pushcfunction(L, lua_system_restart);
  lua_setfield(L, -2, "restart");
  lua_pushcfunction(L, lua_system_shutdown);
  lua_setfield(L, -2, "shutdown");
  lua_pushcfunction(L, lua_system_heap);
  lua_setfield(L, -2, "heap");
  lua_pushcfunction(L, lua_system_heap_size);
  lua_setfield(L, -2, "heapSize");
  lua_pushcfunction(L, lua_system_flash_size);
  lua_setfield(L, -2, "flashSize");
  lua_pushcfunction(L, lua_system_chip_model);
  lua_setfield(L, -2, "chipModel");
  lua_pushcfunction(L, lua_system_millis);
  lua_setfield(L, -2, "millis");
  lua_pushcfunction(L, lua_system_delay);
  lua_setfield(L, -2, "delay");
  lua_setglobal(L, "system");
}
