-- ESP-OS boot script
serial.print("\n[ESP-OS] Boot init.lua start...\n")

-- Load language system first
lang = dofile("/ESP-OS/lang/init.lua")

-- Load config and selected language
config = dofile("/ESP-OS/config/system.lua")
lang.load(config.language or "cs")

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

serial.print("[ESP-OS] Core modules loaded. Starting kernel...\n")

kernel.init()
kernel.run()
