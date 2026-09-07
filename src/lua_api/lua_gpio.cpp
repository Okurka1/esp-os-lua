#include "lua_gpio.h"

#include <Arduino.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
}

#include "config.h"
#include "lua_helpers.h"

namespace {

int parsePinMode(lua_State* L, int index) {
  if (lua_isnumber(L, index)) {
    return static_cast<int>(lua_tointeger(L, index));
  }

  const char* mode = luaL_checkstring(L, index);
  if (strcmp(mode, "INPUT") == 0) {
    return INPUT;
  }
  if (strcmp(mode, "OUTPUT") == 0) {
    return OUTPUT;
  }
  if (strcmp(mode, "INPUT_PULLUP") == 0) {
    return INPUT_PULLUP;
  }

  return -1;
}

int lua_gpio_mode(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "gpio.mode: cannot acquire mutex");
  }

  const int pin = static_cast<int>(luaL_checkinteger(L, 1));
  const int mode = parsePinMode(L, 2);
  if (mode < 0) {
    return luaL_error(L, "gpio.mode: invalid mode (INPUT/OUTPUT/INPUT_PULLUP)");
  }

  pinMode(pin, mode);
  return 0;
}

int lua_gpio_write(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "gpio.write: cannot acquire mutex");
  }

  const int pin = static_cast<int>(luaL_checkinteger(L, 1));
  const int value = static_cast<int>(luaL_checkinteger(L, 2));

  digitalWrite(pin, value ? HIGH : LOW);
  return 0;
}

int lua_gpio_read(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "gpio.read: cannot acquire mutex");
  }

  const int pin = static_cast<int>(luaL_checkinteger(L, 1));

  lua_pushinteger(L, digitalRead(pin));
  return 1;
}

int lua_gpio_analog_write(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "gpio.analogWrite: cannot acquire mutex");
  }

  const int pin = static_cast<int>(luaL_checkinteger(L, 1));
  int value = static_cast<int>(luaL_checkinteger(L, 2));
  value = constrain(value, 0, 255);

  // V Arduino core pro ESP32 je analogWrite mapováno na LEDC PWM.
  analogWrite(pin, value);
  return 0;
}

int lua_gpio_analog_read(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "gpio.analogRead: cannot acquire mutex");
  }

  const int pin = static_cast<int>(luaL_checkinteger(L, 1));

  lua_pushinteger(L, analogRead(pin));
  return 1;
}

}  // namespace

void register_lua_gpio(lua_State* L) {
  lua_newtable(L);
  lua_pushcfunction(L, lua_gpio_mode);
  lua_setfield(L, -2, "mode");
  lua_pushcfunction(L, lua_gpio_write);
  lua_setfield(L, -2, "write");
  lua_pushcfunction(L, lua_gpio_read);
  lua_setfield(L, -2, "read");
  lua_pushcfunction(L, lua_gpio_analog_write);
  lua_setfield(L, -2, "analogWrite");
  lua_pushcfunction(L, lua_gpio_analog_read);
  lua_setfield(L, -2, "analogRead");
  lua_setglobal(L, "gpio");
}
