-- Command console module
local cmd_console = {}
local commands = {}
local colors = _G.colors or sd_require("system.colors")

local function split_args(input)
  local args = {}
  for token in string.gmatch(input or "", "%S+") do
    table.insert(args, token)
  end
  return args
end

local function print_sd_error()
  print("[" .. lang["error"] .. "] " .. lang["error_sd_not_connected"])
end

function commands.help()
  print("\n" .. colors.title(lang["cmd_help_title"]))
  print("  " .. colors.menu_item("help") .. "      - " .. lang["cmd_help"])
  print("  " .. colors.menu_item("ls") .. "        - " .. lang["cmd_ls"])
  print("  " .. colors.menu_item("cat") .. "       - " .. lang["cmd_cat"])
  print("  " .. colors.menu_item("free") .. "      - " .. lang["cmd_free"])
  print("  " .. colors.menu_item("uptime") .. "    - " .. lang["cmd_uptime"])
  print("  " .. colors.menu_item("wifi") .. "      - " .. lang["cmd_wifi"])
  print("  " .. colors.menu_item("gpio") .. "      - " .. lang["cmd_gpio"])
  print("  " .. colors.menu_item("colors") .. "    - " .. lang["cmd_colors"])
  print("  " .. colors.menu_item("clear") .. "     - " .. lang["cmd_clear"])
  print("  " .. colors.menu_item("reboot") .. "    - " .. lang["cmd_reboot"])
  print("  " .. colors.menu_item("shutdown") .. "  - " .. lang["cmd_shutdown"])
  print("  " .. colors.menu_item("exit") .. "      - " .. lang["cmd_exit"])
  print()
end

function commands.ls(args)
  if not sd.available() then
    print_sd_error()
    return
  end

  if #args > 1 then
    print(lang["cmd_ls_usage"])
    return
  end

  local path = args[1] or "/ESP-OS"
  print("\n[LS] " .. path)
  print("(TODO)")
end

function commands.cat(args)
  local file = args[1]
  if not file then
    print("[" .. lang["error"] .. "] " .. lang["cmd_cat_usage"])
    return
  end

  if not sd.available() then
    print_sd_error()
    return
  end

  local content = sd.read(file)
  if content then
    print("\n" .. content)
  else
    print("[" .. lang["error"] .. "] " .. lang["cmd_cat_error"] .. " " .. file)
  end
end

function commands.free()
  local free = system.heap() / 1024
  local total = system.heapSize() / 1024
  local used = total - free

  print(string.format("\n%s %.2f KB", lang["cmd_free_total"], total))
  print(string.format("%s %.2f KB", lang["cmd_free_used"], used))
  print(string.format("%s %.2f KB", lang["cmd_free_free"], free))
end

function commands.uptime()
  local ms = system.millis()
  local seconds = math.floor(ms / 1000)
  local minutes = math.floor(seconds / 60)
  local hours = math.floor(minutes / 60)
  local days = math.floor(hours / 24)

  seconds = seconds % 60
  minutes = minutes % 60
  hours = hours % 24

  print(string.format("\n%s %d d, %02d:%02d:%02d", lang["cmd_uptime_result"], days, hours, minutes, seconds))
end

function commands.wifi()
  local status = wifi.status()
  if status == "CONNECTED" then
    print("\n" .. lang["cmd_wifi_connected"] .. " " .. lang["yes"])
    print(lang["wifi_ssid"] .. " " .. (wifi.ssid() or "N/A"))
    print(lang["cmd_wifi_ip"] .. " " .. (wifi.ip() or "N/A"))
    print(lang["wifi_gateway"] .. " " .. (wifi.gateway() or "N/A"))
    print(lang["wifi_dns"] .. " " .. (wifi.dns() or "N/A"))
    print(lang["wifi_mac"] .. " " .. (wifi.mac() or "N/A"))
    print(lang["wifi_channel"] .. " " .. tostring(wifi.channel() or "N/A"))
    print(lang["wifi_speed"] .. " " .. (wifi.phyMode() or "N/A"))
    print(lang["wifi_signal"] .. " " .. tostring(wifi.rssi() or "N/A") .. " dBm")
  else
    print("\n" .. lang["cmd_wifi_disconnected"])
    print(lang["wifi_status"] .. " " .. tostring(status or "N/A"))
  end
end

function commands.gpio()
  print("\n" .. lang["cmd_gpio_title"])
  print(lang["gpio_safe_pins"] .. " 2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33")
  print(lang["gpio_analog_pins"])
end

function commands.colors(args)
  package.loaded["config.user"] = nil
  local ok_cfg, config = pcall(sd_require, "config.user")
  if not ok_cfg or type(config) ~= "table" then
    config = {
      language = _G.config and _G.config.language or "cs",
      auto_reconnect = _G.config and (_G.config.auto_reconnect ~= false) or true,
      use_colors = _G.config and (_G.config.use_colors == true) or false,
    }
  end

  if not args[1] then
    if config.use_colors then
      print(colors.success(lang["cmd_colors_on"]))
    else
      print(lang["cmd_colors_off"])
    end
    print("\n" .. lang["cmd_colors_usage"])
    print("  " .. lang["cmd_colors_usage_on"])
    print("  " .. lang["cmd_colors_usage_off"])
    print("  " .. lang["cmd_colors_usage_toggle"])
    return
  end

  local action = args[1]:lower()
  local settings = sd_require("system.settings")

  if action == "on" then
    config.use_colors = true
    settings.save_user_config(config)
    colors = colors.reload()
    _G.colors = colors
    print(colors.success(lang["cmd_colors_enabled"]))
    print(colors.info(lang["cmd_colors_reload"]))
  elseif action == "off" then
    config.use_colors = false
    settings.save_user_config(config)
    colors = colors.reload()
    _G.colors = colors
    print(lang["cmd_colors_disabled"])
    print(lang["cmd_colors_reload"])
  elseif action == "toggle" then
    config.use_colors = not config.use_colors
    settings.save_user_config(config)
    colors = colors.reload()
    _G.colors = colors
    if config.use_colors then
      print(colors.success(lang["cmd_colors_enabled"]))
    else
      print(lang["cmd_colors_disabled"])
    end
  else
    print(lang["cmd_colors_invalid"])
  end
end

function commands.clear()
  print("\027[2J\027[H")
end

function commands.reboot()
  print("\n[SYSTEM] " .. lang["system_restarting"])
  system.delay(1000)
  system.restart()
end

function commands.shutdown()
  print("\n[SYSTEM] " .. lang["system_shutting_down"])
  print(lang["system_press_boot"])
  system.delay(2000)
  system.shutdown()
end

function cmd_console.run()
  print("\n╔════════════════════════════════════════╗")
  print("║            " .. lang["cmd_title"] .. "             ║")
  print("║        " .. lang["cmd_help"] .. " (help)         ║")
  print("╚════════════════════════════════════════╝\n")

  while true do
    print(lang["cmd_prompt"] .. "> ")
    local input = serial.read() or ""
    local args = split_args(input)
    local cmd = (args[1] or ""):lower()

    if cmd == "" then
      -- ignore empty command
    elseif cmd == "exit" then
      print("\n[CMD] " .. lang["cmd_exit"] .. "...")
      break
    else
      table.remove(args, 1)
      local handler = commands[cmd]
      if handler then
        handler(args)
      else
        print("[" .. lang["error"] .. "] " .. lang["cmd_unknown"] .. " " .. cmd)
        print(lang["cmd_help"] .. ": help")
      end
    end
  end
end

return cmd_console
