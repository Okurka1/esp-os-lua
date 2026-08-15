#pragma once

struct lua_State;

// Registrace Lua modulu: system.*
void register_lua_system(lua_State* L);
