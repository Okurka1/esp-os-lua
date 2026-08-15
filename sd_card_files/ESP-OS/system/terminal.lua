-- Terminal module with ANSI colors and extended commands
local terminal = {}

-- Current working directory
local cwd = "/ESP-OS"

-- Lazy load ANSI module
local function get_ansi()
  if not ansi then
    ansi = dofile("/ESP-OS/system/ansi.lua")
  end
  return ansi
end

function terminal.run()
  local a = get_ansi()
  
  print(a.clear())
  print(a.bold(a.info("╔════════════════════════════════════════╗")))
  print(a.bold(a.info("║        " .. lang["terminal_title"] .. "              ║")))
  print(a.bold(a.info("║        " .. lang["terminal_help_prompt"] .. "       ║")))
  print(a.bold(a.info("╚════════════════════════════════════════╝")) .. "\n")

  while true do
    print(a.highlight(lang["terminal_prompt"]) .. " ")
    local input = serial.read() or ""
    local cmd = input:match("^%S+") or ""
    local args = input:match("^%S+%s+(.+)")

    if cmd == "help" then
      terminal.cmd_help()
    elseif cmd == "ls" then
      terminal.cmd_ls(args)
    elseif cmd == "cd" then
      terminal.cmd_cd(args)
    elseif cmd == "pwd" then
      terminal.cmd_pwd()
    elseif cmd == "cat" then
      terminal.cmd_cat(args)
    elseif cmd == "rm" then
      terminal.cmd_rm(args)
    elseif cmd == "echo" then
      terminal.cmd_echo(args)
    elseif cmd == "free" or cmd == "mem" then
      terminal.cmd_mem()
    elseif cmd == "df" then
      terminal.cmd_df()
    elseif cmd == "ps" then
      terminal.cmd_ps()
    elseif cmd == "uptime" then
      terminal.cmd_uptime()
    elseif cmd == "ver" or cmd == "version" then
      terminal.cmd_version()
    elseif cmd == "wifi" or cmd == "ifconfig" then
      terminal.cmd_wifi()
    elseif cmd == "gpio" then
      terminal.cmd_gpio()
    elseif cmd == "gc" then
      terminal.cmd_gc()
    elseif cmd == "reboot" then
      terminal.cmd_reboot(args)
    elseif cmd == "shutdown" then
      terminal.cmd_shutdown()
    elseif cmd == "bootloader" then
      terminal.cmd_bootloader()
    elseif cmd == "exit" then
      print(a.info("\n[TERMINAL] " .. lang["terminal_exit_desc"] .. "..."))
      break
    elseif cmd == "clear" or cmd == "cls" then
      terminal.cmd_clear()
    elseif cmd == "" then
      -- ignore empty command
    else
      print(a.error("[ERROR] " .. lang["terminal_unknown"] .. ": " .. cmd))
      print(a.dim(lang["terminal_help_text"]))
    end
  end
end

function terminal.cmd_help()
  local a = get_ansi()
  print(a.bold("\n╔════════════════════════════════════════╗"))
  print(a.bold("║  " .. lang["terminal_available"] .. "                    ║"))
  print(a.bold("╠════════════════════════════════════════╣"))
  print("║  " .. a.highlight("help") .. "         - " .. lang["terminal_help_desc"] .. "          ║")
  print("║  " .. a.highlight("ls") .. " [path]    - " .. lang["terminal_ls_desc"] .. "         ║")
  print("║  " .. a.highlight("cd") .. " <path>    - " .. lang["terminal_cd_desc"] .. "    ║")
  print("║  " .. a.highlight("pwd") .. "          - " .. lang["terminal_pwd_desc"] .. "       ║")
  print("║  " .. a.highlight("cat") .. " <file>   - " .. lang["terminal_cat_desc"] .. "        ║")
  print("║  " .. a.highlight("rm") .. " <file>    - " .. lang["terminal_rm_desc"] .. "       ║")
  print("║  " .. a.highlight("echo") .. " <text>  - " .. lang["terminal_echo_desc"] .. "        ║")
  print("║  " .. a.highlight("mem") .. " / " .. a.highlight("free") .. "  - " .. lang["terminal_mem_desc"] .. "               ║")
  print("║  " .. a.highlight("df") .. "           - " .. lang["terminal_df_desc"] .. "              ║")
  print("║  " .. a.highlight("ps") .. "           - " .. lang["terminal_ps_desc"] .. "       ║")
  print("║  " .. a.highlight("uptime") .. "       - " .. lang["terminal_uptime_desc"] .. "               ║")
  print("║  " .. a.highlight("ver") .. "          - " .. lang["terminal_ver_desc"] .. "              ║")
  print("║  " .. a.highlight("wifi") .. "         - " .. lang["terminal_wifi_desc"] .. "              ║")
  print("║  " .. a.highlight("gpio") .. "         - " .. lang["terminal_gpio_desc"] .. "              ║")
  print("║  " .. a.highlight("gc") .. "           - " .. lang["terminal_gc_desc"] .. "  ║")
  print("║  " .. a.highlight("clear") .. "        - " .. lang["terminal_clear_desc"] .. "     ║")
  print("║  " .. a.highlight("reboot") .. "       - " .. lang["terminal_reboot_desc"] .. "        ║")
  print("║  " .. a.highlight("shutdown") .. "     - " .. lang["terminal_shutdown_desc"] .. "       ║")
  print("║  " .. a.highlight("exit") .. "         - " .. lang["terminal_exit_desc"] .. "         ║")
  print(a.bold("╚════════════════════════════════════════╝"))
end

function terminal.cmd_ls(path)
  local a = get_ansi()
  if not sd.available() then
    print(a.error("[ERROR] " .. lang["error_sd_not_connected"]))
    return
  end

  path = path or cwd
  print(a.info("\n[LS] " .. path))
  
  local entries, err = sd.list(path)
  if not entries then
    print(a.error("[ERROR] " .. tostring(err)))
    return
  end

  if #entries == 0 then
    print(a.dim("  (empty)"))
    return
  end

  for _, entry in ipairs(entries) do
    if entry.isDir then
      print(a.info(string.format("  [DIR]  %s", entry.name)))
    else
      local size_kb = entry.size / 1024
      if size_kb < 1 then
        print(string.format("  %6d B  %s", entry.size, entry.name))
      else
        print(string.format("  %6.1f KB %s", size_kb, entry.name))
      end
    end
  end
end

function terminal.cmd_cd(path)
  local a = get_ansi()
  if not path then
    cwd = "/ESP-OS"
    print(a.success("Changed to: " .. cwd))
    return
  end
  
  if not sd.available() then
    print(a.error("[ERROR] " .. lang["error_sd_not_connected"]))
    return
  end
  
  -- Absolute path
  if path:sub(1, 1) == "/" then
    if sd.exists(path) then
      cwd = path
      print(a.success("Changed to: " .. cwd))
    else
      print(a.error("[ERROR] Directory not found: " .. path))
    end
  else
    -- Relative path
    local new_path = cwd .. "/" .. path
    if sd.exists(new_path) then
      cwd = new_path
      print(a.success("Changed to: " .. cwd))
    else
      print(a.error("[ERROR] Directory not found: " .. new_path))
    end
  end
end

function terminal.cmd_pwd()
  local a = get_ansi()
  print(a.info(cwd))
end

function terminal.cmd_cat(file)
  local a = get_ansi()
  if not file then
    print(a.error("[ERROR] Usage: cat <file>"))
    return
  end

  if not sd.available() then
    print(a.error("[ERROR] " .. lang["error_sd_not_connected"]))
    return
  end

  local content = sd.read(file)
  if content then
    print("\n" .. content)
  else
    print(a.error("[ERROR] " .. lang["error_file_not_found"] .. ": " .. file))
  end
end

function terminal.cmd_rm(file)
  local a = get_ansi()
  if not file then
    print(a.error("[ERROR] Usage: rm <file>"))
    return
  end

  if not sd.available() then
    print(a.error("[ERROR] " .. lang["error_sd_not_connected"]))
    return
  end

  print(a.warning("Delete file: " .. file .. "? [y/N]: "))
  local confirm = serial.readKey()
  if confirm == "y" or confirm == "Y" then
    local ok, err = sd.remove(file)
    if ok then
      print(a.success("✓ File deleted: " .. file))
    else
      print(a.error("[ERROR] " .. tostring(err)))
    end
  else
    print(a.info("Cancelled"))
  end
end

function terminal.cmd_echo(text)
  if text then
    print(text)
  end
end

function terminal.cmd_mem()
  local a = get_ansi()
  local free = system.heap() / 1024
  local total = system.heapSize() / 1024
  local used = total - free
  local percent = 0
  if total > 0 then
    percent = (used / total) * 100
  end

  print(a.bold("\n=== Memory Info ==="))
  print(string.format("Total: %.2f KB", total))
  print(string.format("Used:  %.2f KB", used))
  print(string.format("Free:  %.2f KB", free))
  print("Usage: " .. a.progress_bar(percent))
  
  if percent > 80 then
    print(a.warning("⚠ High memory usage!"))
  end
end

function terminal.cmd_df()
  local a = get_ansi()
  if not sd.available() then
    print(a.error("[ERROR] " .. lang["error_sd_not_connected"]))
    return
  end

  local total = sd.size() / (1024 * 1024)
  local free = sd.free() / (1024 * 1024)
  local used = total - free
  local percent = 0
  if total > 0 then
    percent = (used / total) * 100
  end

  print(a.bold("\n=== SD Card Info ==="))
  print(string.format("Total: %.2f MB", total))
  print(string.format("Used:  %.2f MB", used))
  print(string.format("Free:  %.2f MB", free))
  print("Usage: " .. a.progress_bar(percent))
end

function terminal.cmd_ps()
  local a = get_ansi()
  print(a.bold("\n=== Loaded Modules ==="))
  
  local modules = {"ui", "menu", "kernel", "lang", "ansi", "wifi_manager", 
                   "gpio_manager", "system_monitor", "settings", "terminal", "resource_manager"}
  
  for _, name in ipairs(modules) do
    if _G[name] then
      print(a.success("✓") .. " " .. name)
    else
      print(a.dim("○ " .. name))
    end
  end
end

function terminal.cmd_uptime()
  local a = get_ansi()
  local ms = system.millis()
  local seconds = math.floor(ms / 1000)
  local minutes = math.floor(seconds / 60)
  local hours = math.floor(minutes / 60)
  local days = math.floor(hours / 24)

  seconds = seconds % 60
  minutes = minutes % 60
  hours = hours % 24

  print(a.info(string.format("\n%s: %d d, %02d:%02d:%02d", lang["sysinfo_uptime"], days, hours, minutes, seconds)))
end

function terminal.cmd_version()
  local a = get_ansi()
  print(a.bold("\n=== ESP-OS Version ==="))
  print("Version: " .. a.highlight(config.version or "0.0.4"))
  print("Device:  " .. (config.device_name or "ESP-OS"))
  print("Chip:    " .. system.chipModel())
  print("Flash:   " .. string.format("%.2f MB", system.flashSize() / (1024 * 1024)))
end

function terminal.cmd_wifi()
  local a = get_ansi()
  local status = wifi.status()
  if status == "CONNECTED" then
    print(a.bold("\n=== WiFi Info ==="))
    print(a.success("Status:  Connected"))
    print("SSID:    " .. (wifi.ssid() or "N/A"))
    print("IP:      " .. a.highlight(wifi.ip() or "N/A"))
    print("Gateway: " .. (wifi.gateway() or "N/A"))
    print("DNS:     " .. (wifi.dns() or "N/A"))
    print("MAC:     " .. (wifi.mac() or "N/A"))
    print("Channel: " .. tostring(wifi.channel() or "N/A"))
    print("Mode:    " .. (wifi.phyMode() or "N/A"))
    print("RSSI:    " .. tostring(wifi.rssi() or "N/A") .. " dBm")
  else
    print(a.bold("\n=== WiFi Info ==="))
    print(a.error("Status: " .. tostring(status or "Disconnected")))
  end
end

function terminal.cmd_gpio()
  local a = get_ansi()
  print(a.bold("\n=== GPIO Info ==="))
  print(a.success("Safe pins:") .. " 2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33")
  print(a.info("ADC pins:") .. "  32, 33, 34, 35, 36, 39")
  print(a.warning("Avoid:") .. "     0 (BOOT), 1/3 (UART), 6-11 (Flash)")
end

function terminal.cmd_gc()
  local a = get_ansi()
  local before = system.heap()
  collectgarbage("collect")
  local after = system.heap()
  local freed = (after - before) / 1024
  
  print(a.success(string.format("\n✓ Garbage collection complete. Freed: %.2f KB", freed)))
end

function terminal.cmd_clear()
  local a = get_ansi()
  print(a.clear())
end

function terminal.cmd_reboot(args)
  local a = get_ansi()
  
  if args == "recovery" then
    print(a.warning("\n[SYSTEM] Restartování do Recovery Mode..."))
    system.delay(2000)
    system.restart("recovery")
  elseif args == "bootloader" then
    print(a.warning("\n[SYSTEM] Restartování do Bootloader Menu..."))
    system.delay(2000)
    system.restart("bootloader")
  else
    print(a.warning("\n[SYSTEM] " .. lang["system_restarting"]))
    system.delay(2000)
    system.restart()
  end
end

function terminal.cmd_bootloader()
  local a = get_ansi()
  print(a.info("\n=== Bootloader Commands ==="))
  print("reboot recovery    - Restart do Recovery Mode")
  print("reboot bootloader  - Restart do Bootloader Menu")
  print("reboot             - Normální restart")
  print("\n[INFO] Pro vstup do bootloaderu stiskněte BOOT tlačítko při startu.")
end

function terminal.cmd_shutdown()
  local a = get_ansi()
  print(a.warning("\n[SYSTEM] " .. lang["system_shutting_down"]))
  print(a.info(lang["system_press_boot"]))
  system.delay(2000)
  system.shutdown()
end

return terminal
