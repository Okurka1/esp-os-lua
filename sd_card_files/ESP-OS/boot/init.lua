-- ESP-OS boot script
serial.print("\n[ESP-OS] Boot init.lua start...\n")

-- Override global print() to use serial.print for proper line endings
_G.print = function(...)
  local args = {...}
  local output = ""
  for i, v in ipairs(args) do
    if i > 1 then
      output = output .. "\t"
    end
    output = output .. tostring(v)
  end
  serial.print(output .. "\n")
end

-- Load language system first
lang = dofile("/ESP-OS/lang/init.lua")

-- Load config and selected language
config = dofile("/ESP-OS/config/system.lua")
lang.load(config.language or "cs")

-- Core modules
ui = dofile("/ESP-OS/system/ui.lua")
menu = dofile("/ESP-OS/system/menu.lua")
kernel = dofile("/ESP-OS/system/kernel.lua")

-- Initialize Resource Manager
resource_manager = dofile("/ESP-OS/system/resource_manager.lua")
resource_manager.init()

-- Lazy modules
ansi = nil
wifi_manager = nil
system_monitor = nil
gpio_manager = nil
settings = nil
terminal = nil

-- Načti ANSI modul a nastav enable flag z config
if config.ansi_enabled ~= nil then
  ansi = dofile("/ESP-OS/system/ansi.lua")
  ansi.enabled = config.ansi_enabled
end

serial.print("[ESP-OS] Core modules loaded. Starting kernel...\n")

kernel.init()
kernel.run()
