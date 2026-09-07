-- Main menu framework for ESP-OS
local menu = {}

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
  while true do
    ui.clear()
    ui.header(lang["menu_title"])
    ui.box({
      "[1] " .. lang["menu_system_info"],
      "[2] " .. lang["menu_wifi_manager"],
      "[3] " .. lang["menu_gpio_manager"],
      "[4] " .. lang["menu_settings"],
      "[5] " .. lang["menu_restart"],
      "[Q] " .. lang["menu_cmd"]
    })

    serial.print(lang["menu_select"] .. " [1-5/Q]: ")
    local choice = tostring(serial.readKey() or "")

    if choice == "1" then
      -- Free RAM before loading module
      collectgarbage("collect")
      local mod = load_module_if_needed("system_monitor", "/ESP-OS/system/system_monitor.lua")
      if mod and mod.show then
        mod.show()
      end
      -- Free RAM after closing module
      _G["system_monitor"] = nil
      collectgarbage("collect")
    elseif choice == "2" then
      collectgarbage("collect")
      local mod = load_module_if_needed("wifi_manager", "/ESP-OS/system/wifi_manager.lua")
      if mod and mod.show then
        mod.show()
      end
      _G["wifi_manager"] = nil
      collectgarbage("collect")
    elseif choice == "3" then
      collectgarbage("collect")
      local mod = load_module_if_needed("gpio_manager", "/ESP-OS/system/gpio_manager.lua")
      if mod and mod.show then
        mod.show()
      end
      _G["gpio_manager"] = nil
      collectgarbage("collect")
    elseif choice == "4" then
      collectgarbage("collect")
      local mod = load_module_if_needed("settings", "/ESP-OS/system/settings.lua")
      if mod and mod.show then
        mod.show()
      end
      _G["settings"] = nil
      collectgarbage("collect")
    elseif choice == "5" then
      serial.print("\n[SYSTEM] " .. lang["system_restarting"] .. "\n")
      system.delay(1000)
      system.restart()
    elseif choice == "q" or choice == "Q" then
      -- Terminal needs more RAM - aggressive cleanup first
      _G["system_monitor"] = nil
      _G["wifi_manager"] = nil
      _G["gpio_manager"] = nil
      _G["settings"] = nil
      collectgarbage("collect")
      collectgarbage("collect")  -- Double GC for terminal
      
      local mod = load_module_if_needed("terminal", "/ESP-OS/system/terminal.lua")
      if mod and mod.run then
        mod.run()
      end
      -- Terminal cleanup
      _G["terminal"] = nil
      collectgarbage("collect")
    else
      ui.box({"[ERROR] " .. lang["error_invalid_choice"]})
      system.delay(1000)
    end
  end
end

return menu
