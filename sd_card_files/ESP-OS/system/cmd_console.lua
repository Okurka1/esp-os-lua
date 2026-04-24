-- Command console module
local cmd_console = {}

function cmd_console.run()
  print("\n╔════════════════════════════════════════╗")
  print("║        " .. lang["cmd_title"] .. "              ║")
  print("║        " .. lang["cmd_help_prompt"] .. "       ║")
  print("╚════════════════════════════════════════╝\n")

  while true do
    print(lang["cmd_prompt"] .. " ")
    local input = serial.read() or ""
    local cmd = input:lower():match("^%S+") or ""
    local args = input:match("^%S+%s+(.+)")

    if cmd == "help" then
      cmd_console.cmd_help()
    elseif cmd == "ls" then
      cmd_console.cmd_ls(args)
    elseif cmd == "cat" then
      cmd_console.cmd_cat(args)
    elseif cmd == "free" then
      cmd_console.cmd_free()
    elseif cmd == "uptime" then
      cmd_console.cmd_uptime()
    elseif cmd == "wifi" then
      cmd_console.cmd_wifi()
    elseif cmd == "gpio" then
      cmd_console.cmd_gpio()
    elseif cmd == "reboot" then
      cmd_console.cmd_reboot()
    elseif cmd == "shutdown" then
      cmd_console.cmd_shutdown()
    elseif cmd == "exit" then
      print("\n[CMD] " .. lang["cmd_exit_desc"] .. "...")
      break
    elseif cmd == "clear" then
      cmd_console.cmd_clear()
    elseif cmd == "" then
      -- ignore empty command
    else
      print("[ERROR] " .. lang["cmd_unknown"] .. ": " .. cmd)
      print(lang["cmd_help_text"])
    end
  end
end

function cmd_console.cmd_help()
  print("\n╔════════════════════════════════════════╗")
  print("║  " .. lang["cmd_available"] .. "                    ║")
  print("╠════════════════════════════════════════╣")
  print("║  help         - " .. lang["cmd_help_desc"] .. "          ║")
  print("║  ls [path]    - " .. lang["cmd_ls_desc"] .. "         ║")
  print("║  cat <file>   - " .. lang["cmd_cat_desc"] .. "        ║")
  print("║  free         - " .. lang["cmd_free_desc"] .. "               ║")
  print("║  uptime       - " .. lang["cmd_uptime_desc"] .. "               ║")
  print("║  wifi         - " .. lang["cmd_wifi_desc"] .. "              ║")
  print("║  gpio         - " .. lang["cmd_gpio_desc"] .. "              ║")
  print("║  clear        - " .. lang["cmd_clear_desc"] .. "     ║")
  print("║  reboot       - " .. lang["cmd_reboot_desc"] .. "        ║")
  print("║  shutdown     - " .. lang["cmd_shutdown_desc"] .. "       ║")
  print("║  exit         - " .. lang["cmd_exit_desc"] .. "         ║")
  print("╚════════════════════════════════════════╝")
end

function cmd_console.cmd_ls(path)
  if not sd.available() then
    print("[ERROR] " .. lang["error_sd_not_connected"])
    return
  end

  path = path or "/ESP-OS"
  print("\n[LS] " .. path)
  print("(TODO)")
end

function cmd_console.cmd_cat(file)
  if not file then
    print("[ERROR] Usage: cat <file>")
    return
  end

  if not sd.available() then
    print("[ERROR] " .. lang["error_sd_not_connected"])
    return
  end

  local content = sd.read(file)
  if content then
    print("\n" .. content)
  else
    print("[ERROR] " .. lang["error_file_not_found"] .. ": " .. file)
  end
end

function cmd_console.cmd_free()
  local free = system.heap() / 1024
  local total = system.heapSize() / 1024
  local used = total - free
  local percent = 0
  if total > 0 then
    percent = (used / total) * 100
  end

  print(string.format("\n%s: %.2f / %.2f KB (%.1f%%)", lang["sysinfo_ram"], used, total, percent))
end

function cmd_console.cmd_uptime()
  local ms = system.millis()
  local seconds = math.floor(ms / 1000)
  local minutes = math.floor(seconds / 60)
  local hours = math.floor(minutes / 60)
  local days = math.floor(hours / 24)

  seconds = seconds % 60
  minutes = minutes % 60
  hours = hours % 24

  print(string.format("\n%s: %d d, %02d:%02d:%02d", lang["sysinfo_uptime"], days, hours, minutes, seconds))
end

function cmd_console.cmd_wifi()
  local status = wifi.status()
  if status == "CONNECTED" then
    print("\nWiFi: " .. lang["wifi_connected"])
    print(lang["wifi_info_ssid"] .. ": " .. (wifi.ssid() or "N/A"))
    print(lang["wifi_info_ip"] .. ": " .. (wifi.ip() or "N/A"))
    print(lang["wifi_info_gateway"] .. ": " .. (wifi.gateway() or "N/A"))
    print(lang["wifi_info_dns"] .. ": " .. (wifi.dns() or "N/A"))
    print(lang["wifi_info_mac"] .. ": " .. (wifi.mac() or "N/A"))
    print(lang["wifi_info_channel"] .. ": " .. tostring(wifi.channel() or "N/A"))
    print(lang["wifi_info_phy_mode"] .. ": " .. (wifi.phyMode() or "N/A"))
    print(lang["wifi_info_rssi"] .. ": " .. tostring(wifi.rssi() or "N/A") .. " dBm")
  else
    print("\nWiFi: " .. lang["wifi_disconnected"])
    print(lang["wifi_info_status"] .. ": " .. tostring(status or "N/A"))
  end
end

function cmd_console.cmd_gpio()
  print("\nGPIO Info:")
  print("Safe pins: 2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33")
  print("ADC pins: 32, 33, 34, 35, 36, 39")
end

function cmd_console.cmd_clear()
  print("\027[2J\027[H")
end

function cmd_console.cmd_reboot()
  print("\n[SYSTEM] " .. lang["system_restarting"])
  system.delay(3000)
  system.restart()
end

function cmd_console.cmd_shutdown()
  print("\n[SYSTEM] " .. lang["system_shutting_down"])
  print(lang["system_press_boot"])
  system.delay(2000)
  system.shutdown()
end

return cmd_console
