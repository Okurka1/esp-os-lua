-- Settings module
local settings = {}

local function save_system_config(cfg)
  local order = {
    "device_name", "version", "language", "debug", "auto_reconnect", "serial_baud", "sd_cs_pin", "ansi_enabled"
  }

  local file_content = "config = {\n"
  for _, key in ipairs(order) do
    local value = cfg[key]
    if value ~= nil then
      if type(value) == "string" then
        file_content = file_content .. string.format("  %s = %q,\n", key, value)
      else
        file_content = file_content .. string.format("  %s = %s,\n", key, tostring(value))
      end
    end
  end
  file_content = file_content .. "}\n\nreturn config\n"

  return sd.write("/ESP-OS/config/system.lua", file_content)
end

function settings.change_language()
  print("\n╔════════════════════════════════════════╗")
  print("║  Language / Jazyk                      ║")
  print("╠════════════════════════════════════════╣")
  print("║  [1] Čeština                           ║")
  print("║  [2] English                           ║")
  print("╚════════════════════════════════════════╝")
  print("\nSelect [1-2]: ")

  local choice = serial.readKey()

  if choice == "1" then
    if lang.switch("cs") then
      print("\n" .. lang["settings_lang_changed_cs"])
      system.delay(2000)
      system.restart()
    end
  elseif choice == "2" then
    if lang.switch("en") then
      print("\n" .. lang["settings_lang_changed_en"])
      system.delay(2000)
      system.restart()
    end
  end
end

function settings.change_device_name()
  local cfg = dofile("/ESP-OS/config/system.lua")
  local current_name = tostring(cfg.device_name or "ESP-OS")
  local new_name = ui.prompt(lang["settings_enter_device_name"] .. " [" .. current_name .. "]: ")
  new_name = tostring(new_name or "")
  if new_name == "" then
    return
  end

  cfg.device_name = new_name
  local ok = save_system_config(cfg)
  if ok then
    config = cfg
    ui.box({lang["settings_saved"] .. ": " .. new_name})
  else
    ui.box({"[ERROR] Save failed"})
  end
  serial.print(lang["press_key_back"] .. "...\n")
  serial.readKey()
end

function settings.toggle_ansi()
  local cfg = dofile("/ESP-OS/config/system.lua")
  cfg.ansi_enabled = not (cfg.ansi_enabled or false)
  
  local ok = save_system_config(cfg)
  if ok then
    config = cfg
    -- Update runtime ansi module if loaded
    if ansi then
      ansi.enabled = cfg.ansi_enabled
    end
    local status = cfg.ansi_enabled and "ENABLED" or "DISABLED"
    ui.box({"ANSI colors: " .. status})
    print("\n" .. lang["settings_saved"] .. "!")
  else
    ui.box({"[ERROR] Save failed"})
  end
  serial.print(lang["press_key_back"] .. "...\n")
  serial.readKey()
end

function settings.show()
  while true do
    local ansi_status = config.ansi_enabled and "ON " or "OFF"
    
    print("\n╔════════════════════════════════════════╗")
    print("║        " .. lang["settings_title"] .. "                        ║")
    print("╠════════════════════════════════════════╣")
    print("║  [1] " .. lang["settings_language"] .. "               ║")
    print("║  [2] " .. lang["settings_device_name"] .. "              ║")
    print("║  [3] ANSI Colors [" .. ansi_status .. "]              ║")
    print("║  [B] " .. lang["back"] .. "                               ║")
    print("╚════════════════════════════════════════╝")
    print("\n" .. lang["menu_select"] .. " [1-3/B]: ")

    local choice = serial.readKey()

    if choice == "1" then
      settings.change_language()
    elseif choice == "2" then
      settings.change_device_name()
    elseif choice == "3" then
      settings.toggle_ansi()
    elseif choice == "b" or choice == "B" then
      break
    end
  end
end

return settings
