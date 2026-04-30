-- ESP-OS boot script

-- Override require() for SD card modules
_G.original_require = require
function require(module_name)
  if type(module_name) ~= "string" then
    return _G.original_require(module_name)
  end

  if module_name:match("^system%.") or
     module_name:match("^lang%.") or
     module_name:match("^apps%.") then
    return sd_require(module_name)
  end

  return _G.original_require(module_name)
end

-- Load language system first
lang = dofile("/ESP-OS/lang/init.lua")

-- Load base config
config = dofile("/ESP-OS/config/system.lua")

-- Merge user overrides (language, colors, auto_reconnect, ...)
local user_cfg_loaded = false
do
  local ok_user, user_cfg = pcall(dofile, "/ESP-OS/config/user.lua")
  if ok_user and type(user_cfg) == "table" then
    for k, v in pairs(user_cfg) do
      config[k] = v
    end
    user_cfg_loaded = true
  end
end

lang.load(config.language or "cs")

serial.print("\n" .. lang["boot_start"] .. "\n")
print(lang["boot_init"])

if not user_cfg_loaded then
  serial.print(lang["boot_user_config_missing"] .. "\n")
end

serial.print(lang["boot_lang_loaded"] .. " " .. tostring(lang.current()) .. "\n")

-- Core modules
ui = dofile("/ESP-OS/system/ui.lua")
menu = dofile("/ESP-OS/system/menu.lua")
kernel = dofile("/ESP-OS/system/kernel.lua")

-- Lazy modules
wifi_manager = nil
system_monitor = nil
gpio_manager = nil
settings = nil
cmd_console = nil

serial.print(lang["boot_core_loaded"] .. "\n")

kernel.init()
kernel.run()
