-- Main kernel ESP-OS
local kernel = {
  running = false
}

local function load_module_if_needed(global_name, path)
  if _G[global_name] then
    return _G[global_name]
  end

  local ok, module_or_err = pcall(dofile, path)
  if not ok then
    serial.print(string.format("[KERNEL][WARN] %s: %s\n", global_name, tostring(module_or_err)))
    return nil
  end

  _G[global_name] = module_or_err
  return module_or_err
end

function kernel.init()
  serial.print(lang["kernel_init"] .. "\n")
  serial.print(string.format("%s %s | %s %s\n", lang["kernel_device"], config.device_name, lang["kernel_version"], config.version))

  if not sd.available() then
    serial.print(lang["kernel_sd_unavailable"] .. "\n")
    serial.print(lang["kernel_ready"] .. "\n")
    return
  end

  local ok_cfg, wifi_cfg = pcall(dofile, "/ESP-OS/config/wifi.lua")
  if not ok_cfg then
    serial.print(lang["kernel_wifi_cfg_invalid"] .. "\n")
    wifi_cfg = nil
  end

  if config.auto_reconnect and wifi_cfg then
    local manager = load_module_if_needed("wifi_manager", "/ESP-OS/system/wifi_manager.lua")
    if manager and manager.auto_connect then
      serial.print(lang["kernel_autoreconnect"] .. "\n")
      local ok_auto, auto_result = pcall(manager.auto_connect)
      if not ok_auto then
        serial.print(string.format("%s: %s\n", lang["kernel_connect_failed"], tostring(auto_result)))
      end
    else
      serial.print(lang["kernel_module_missing"] .. "\n")
    end
  else
    serial.print(lang["kernel_autoreconnect_disabled"] .. "\n")
  end

  serial.print(lang["kernel_ready"] .. "\n")
end

function kernel.run()
  serial.print(lang["kernel_starting_menu"] .. "\n")
  kernel.running = true

  while kernel.running do
    local continue_loop = menu.show_main()
    if continue_loop == false then
      kernel.running = false
    end
    system.delay(10)
  end

  serial.print(lang["kernel_loop_stopped"] .. "\n")
end

return kernel
