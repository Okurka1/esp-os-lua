-- Main menu framework for ESP-OS
local menu = {}
local colors = sd_require("system.colors")

local function load_module_if_needed(global_name, path)
  if _G[global_name] then
    return _G[global_name]
  end

  local ok, module_or_err = pcall(dofile, path)
  if not ok then
    ui.box({string.format("Failed to load module %s:", global_name), tostring(module_or_err)})
    return nil
  end

  _G[global_name] = module_or_err
  return module_or_err
end

function menu.show_main()
  colors = _G.colors or colors
  ui.clear()
  print("\n" .. colors.BRIGHT_BLACK .. "========================================" .. colors.RESET)
  print(colors.title("        ESP-OS v" .. tostring(config.version or "0.0.3.2")))
  print(colors.BRIGHT_BLACK .. "========================================" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "+---------------------------------------+" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[1]") .. " " .. lang["menu_system_info"] .. "                    " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[2]") .. " " .. lang["menu_wifi_manager"] .. "                     " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[3]") .. " " .. lang["menu_gpio_manager"] .. "                     " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[4]") .. " " .. lang["menu_settings"] .. "                          " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[5]") .. " " .. lang["menu_restart"] .. "                           " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[Q]") .. " " .. lang["menu_cmd"] .. "                       " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
  print(colors.BRIGHT_BLACK .. "+---------------------------------------+" .. colors.RESET)
  print("\n" .. lang["menu_select"] .. " [1-5/Q]: " .. colors.BRIGHT_GREEN)

  local choice = tostring(serial.readKey() or "")

  if choice == "1" then
    local mod = load_module_if_needed("system_monitor", "/ESP-OS/system/system_monitor.lua")
    if mod and mod.show then
      mod.show()
    end
  elseif choice == "2" then
    local mod = load_module_if_needed("wifi_manager", "/ESP-OS/system/wifi_manager.lua")
    if mod and mod.show then
      mod.show()
    end
  elseif choice == "3" then
    local mod = load_module_if_needed("gpio_manager", "/ESP-OS/system/gpio_manager.lua")
    if mod and mod.show then
      mod.show()
    end
  elseif choice == "4" then
    local mod = load_module_if_needed("settings", "/ESP-OS/system/settings.lua")
    if mod and mod.show_menu then
      mod.show_menu()
    elseif mod and mod.show then
      mod.show()
    end
  elseif choice == "5" then
    print(colors.warning("\n[SYSTEM] " .. lang["system_restarting"]))
    system.delay(1000)
    system.restart()
  elseif choice == "q" or choice == "Q" then
    local mod = load_module_if_needed("cmd_console", "/ESP-OS/system/cmd_console.lua")
    if mod and mod.run then
      mod.run()
    end
  else
    print(colors.error("[ERROR] " .. lang["error_invalid_choice"]))
    system.delay(1000)
  end

  return true
end

return menu
