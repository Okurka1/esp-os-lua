#pragma once

struct lua_State;

// Registrace Lua modulu: gpio.*
void register_lua_gpio(lua_State* L);
