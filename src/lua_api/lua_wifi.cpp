#include "lua_wifi.h"

#include <Arduino.h>
#include <WiFi.h>
#include <esp_wifi.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
}

#include "config.h"
#include "lua_helpers.h"

namespace {

const char* wifiStatusToString(wl_status_t status) {
  switch (status) {
    case WL_CONNECTED:
      return "CONNECTED";
    case WL_NO_SSID_AVAIL:
      return "NO_SSID";
    case WL_CONNECT_FAILED:
      return "CONNECT_FAILED";
    case WL_CONNECTION_LOST:
      return "CONNECTION_LOST";
    case WL_DISCONNECTED:
      return "DISCONNECTED";
    case WL_IDLE_STATUS:
      return "IDLE";
    default:
      return "UNKNOWN";
  }
}

int lua_wifi_scan(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.scan: nelze získat mutex");
  }

  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);

  const int n = WiFi.scanNetworks(false, true);
  lua_newtable(L);

  for (int i = 0; i < n; ++i) {
    lua_newtable(L);
    lua_pushstring(L, WiFi.SSID(i).c_str());
    lua_setfield(L, -2, "ssid");
    lua_pushinteger(L, WiFi.RSSI(i));
    lua_setfield(L, -2, "rssi");
    lua_pushinteger(L, WiFi.encryptionType(i));
    lua_setfield(L, -2, "encryption");

    lua_rawseti(L, -2, i + 1);
  }

  WiFi.scanDelete();
  return 1;
}

int lua_wifi_connect(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.connect: cannot acquire mutex");
  }

  const char* ssid = luaL_checkstring(L, 1);
  const char* password = luaL_optstring(L, 2, "");

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  const unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && (millis() - start) < Config::WIFI_CONNECT_TIMEOUT_MS) {
    delay(200);
  }

  lua_pushboolean(L, WiFi.status() == WL_CONNECTED);
  return 1;
}

int lua_wifi_disconnect(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.disconnect: nelze získat mutex");
  }

  const bool ok = WiFi.disconnect(true, true);
  lua_pushboolean(L, ok);
  return 1;
}

int lua_wifi_status(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.status: nelze získat mutex");
  }

  lua_pushstring(L, wifiStatusToString(WiFi.status()));
  return 1;
}

int lua_wifi_ip(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.ip: nelze získat mutex");
  }

  if (WiFi.getMode() == WIFI_MODE_AP || WiFi.getMode() == WIFI_MODE_APSTA) {
    lua_pushstring(L, WiFi.softAPIP().toString().c_str());
  } else {
    lua_pushstring(L, WiFi.localIP().toString().c_str());
  }
  return 1;
}

int lua_wifi_start_ap(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.startAP: cannot acquire mutex");
  }

  const char* ssid = luaL_checkstring(L, 1);
  const char* password = luaL_optstring(L, 2, "");

  WiFi.mode(WIFI_AP);
  const bool ok = WiFi.softAP(ssid, password);
  lua_pushboolean(L, ok);
  return 1;
}

int lua_wifi_rssi(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.rssi: nelze získat mutex");
  }

  lua_pushinteger(L, WiFi.RSSI());
  return 1;
}

int lua_wifi_ssid(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.ssid: nelze získat mutex");
  }

  lua_pushstring(L, WiFi.SSID().c_str());
  return 1;
}

int lua_wifi_mac(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.mac: nelze získat mutex");
  }

  lua_pushstring(L, WiFi.macAddress().c_str());
  return 1;
}

int lua_wifi_gateway(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.gateway: nelze získat mutex");
  }

  lua_pushstring(L, WiFi.gatewayIP().toString().c_str());
  return 1;
}

int lua_wifi_dns(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.dns: nelze získat mutex");
  }

  lua_pushstring(L, WiFi.dnsIP().toString().c_str());
  return 1;
}

int lua_wifi_channel(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.channel: nelze získat mutex");
  }

  lua_pushinteger(L, WiFi.channel());
  return 1;
}

int lua_wifi_phy_mode(lua_State* L) {
  ScopedLuaLock lock;
  if (!lock.ok()) {
    return luaL_error(L, "wifi.phyMode: nelze získat mutex");
  }

  wifi_mode_t mode = WIFI_MODE_NULL;
  if (esp_wifi_get_mode(&mode) != ESP_OK) {
    lua_pushstring(L, "N/A");
    return 1;
  }

  if (mode == WIFI_MODE_STA || mode == WIFI_MODE_APSTA) {
    wifi_ap_record_t ap_info;
    if (esp_wifi_sta_get_ap_info(&ap_info) == ESP_OK) {
      if (ap_info.phy_11n) {
        lua_pushstring(L, "802.11n");
        return 1;
      }
      if (ap_info.phy_11g) {
        lua_pushstring(L, "802.11g");
        return 1;
      }
      if (ap_info.phy_11b) {
        lua_pushstring(L, "802.11b");
        return 1;
      }
    }
  }

  lua_pushstring(L, "N/A");
  return 1;
}

}  // namespace

void register_lua_wifi(lua_State* L) {
  lua_newtable(L);
  lua_pushcfunction(L, lua_wifi_scan);
  lua_setfield(L, -2, "scan");
  lua_pushcfunction(L, lua_wifi_connect);
  lua_setfield(L, -2, "connect");
  lua_pushcfunction(L, lua_wifi_disconnect);
  lua_setfield(L, -2, "disconnect");
  lua_pushcfunction(L, lua_wifi_status);
  lua_setfield(L, -2, "status");
  lua_pushcfunction(L, lua_wifi_ip);
  lua_setfield(L, -2, "ip");
  lua_pushcfunction(L, lua_wifi_start_ap);
  lua_setfield(L, -2, "startAP");
  lua_pushcfunction(L, lua_wifi_rssi);
  lua_setfield(L, -2, "rssi");
  lua_pushcfunction(L, lua_wifi_ssid);
  lua_setfield(L, -2, "ssid");
  lua_pushcfunction(L, lua_wifi_mac);
  lua_setfield(L, -2, "mac");
  lua_pushcfunction(L, lua_wifi_gateway);
  lua_setfield(L, -2, "gateway");
  lua_pushcfunction(L, lua_wifi_dns);
  lua_setfield(L, -2, "dns");
  lua_pushcfunction(L, lua_wifi_channel);
  lua_setfield(L, -2, "channel");
  lua_pushcfunction(L, lua_wifi_phy_mode);
  lua_setfield(L, -2, "phyMode");
  lua_setglobal(L, "wifi");
}
