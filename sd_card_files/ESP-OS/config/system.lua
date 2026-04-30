config = {
  device_name = "ESP-OS",
  version = "0.0.3.2",  -- Finální verze (odstraněno -dev)
  language = "cs",
  debug = false,
  auto_reconnect = true,
  use_colors = false, -- Default: vypnuto (VSCode kompatibilita)
  serial_baud = 115200,
  sd_cs_pin = 5
}

return config
