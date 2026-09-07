#pragma once

#include <Arduino.h>
#include <freertos/FreeRTOS.h>
#include <freertos/semphr.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
}

#include "config.h"

// Thread-safe Lua lock using RAII pattern
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
