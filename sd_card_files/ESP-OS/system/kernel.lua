-- Hlavní kernel ESP-OS
local kernel = {
  running = false
}

local function load_module_if_needed(global_name, path)
  if _G[global_name] then
    return _G[global_name]
  end

  local ok, module_or_err = pcall(dofile, path)
  if not ok then
    serial.print(string.format("[KERNEL][WARN] Nepodařilo se načíst %s: %s\n", global_name, tostring(module_or_err)))
    return nil
  end

  _G[global_name] = module_or_err
  return module_or_err
end

function kernel.init()
  serial.print("[KERNEL] Inicializace...\n")
  serial.print(string.format("[KERNEL] Device: %s | verze: %s\n", config.device_name, config.version))

  -- Lazy loading: WiFi manager načti jen pokud je potřeba pro auto-reconnect.
  if not sd.available() then
    serial.print("[KERNEL][WARN] SD karta není dostupná, přeskakuji auto-reconnect.\n")
    serial.print("[KERNEL] Připraven!\n")
    return
  end

  local ok_cfg, wifi_cfg = pcall(dofile, "/ESP-OS/config/wifi.lua")
  if not ok_cfg then
    serial.print("[KERNEL][WARN] WiFi konfigurace nenalezena nebo je poškozená.\n")
    wifi_cfg = nil
  end

  if wifi_cfg and wifi_cfg.auto_reconnect then
    local manager = load_module_if_needed("wifi_manager", "/ESP-OS/system/wifi_manager.lua")
    if manager and manager.auto_connect then
      serial.print("[KERNEL] Auto-reconnect WiFi...\n")
      local ok_auto, auto_result = pcall(manager.auto_connect)
      if not ok_auto then
        serial.print(string.format("[KERNEL][WARN] Auto-reconnect selhal: %s\n", tostring(auto_result)))
      end
    else
      serial.print("[KERNEL][WARN] wifi_manager.auto_connect není dostupný.\n")
    end
  else
    serial.print("[KERNEL] Auto-reconnect je vypnut nebo není dostupný.\n")
  end

  serial.print("[KERNEL] Připraven!\n")
end

function kernel.run()
  serial.print("[KERNEL] Spouštím hlavní smyčku menu.\n")
  kernel.running = true

  while kernel.running do
    local continue_loop = menu.show_main()
    if continue_loop == false then
      kernel.running = false
    end
    system.delay(10)
  end

  serial.print("[KERNEL] Smyčka ukončena. Zařízení zůstává aktivní.\n")
end

return kernel
