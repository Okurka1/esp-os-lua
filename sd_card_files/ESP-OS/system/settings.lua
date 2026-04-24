-- Settings module
local settings = {}

local function save_system_config(cfg)
  local order = {
    "device_name", "version", "language", "debug", "auto_reconnect", "serial_baud", "sd_cs_pin"
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
    end
  elseif choice == "2" then
    if lang.switch("en") then
      print("\n" .. lang["settings_lang_changed_en"])
    end
  end

  system.delay(1500)
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

function settings.show()
  while true do
    print("\n╔════════════════════════════════════════╗")
    print("║        " .. lang["settings_title"] .. "                        ║")
    print("╠════════════════════════════════════════╣")
    print("║  [1] " .. lang["settings_language"] .. "               ║")
    print("║  [2] " .. lang["settings_device_name"] .. "              ║")
    print("║  [B] " .. lang["back"] .. "                               ║")
    print("╚════════════════════════════════════════╝")
    print("\n" .. lang["menu_select"] .. " [1-2/B]: ")

    local choice = serial.readKey()

    if choice == "1" then
      settings.change_language()
    elseif choice == "2" then
      settings.change_device_name()
    elseif choice == "b" or choice == "B" then
      break
    end
  end
end

return settings
