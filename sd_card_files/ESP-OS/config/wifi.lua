wifi_config = {
  auto_reconnect = true,
  saved_networks = {
    {
      ssid = "MojeWiFi",
      password = "heslo123",
      priority = 1
    }
  },
  ap_mode = {
    ssid = "ESP-OS-AP",
    password = "12345678"
  }
}

return wifi_config
