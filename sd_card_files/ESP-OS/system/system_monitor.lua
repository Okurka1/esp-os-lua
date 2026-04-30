-- System monitor module
local system_monitor = {}
local colors = sd_require("system.colors")

local function format_size(bytes)
  if bytes == nil then
    return "N/A"
  end

  if bytes < 1024 then
    return string.format("%.0f B", bytes)
  elseif bytes < 1024 * 1024 then
    return string.format("%.2f KB", bytes / 1024)
  elseif bytes < 1024 * 1024 * 1024 then
    return string.format("%.2f MB", bytes / (1024 * 1024))
  else
    return string.format("%.2f GB", bytes / (1024 * 1024 * 1024))
  end
end

function system_monitor.show_info()
  local free_heap = system.heap()
  local heap_total = system.heapSize()
  local flash_size = system.flashSize()
  local uptime_ms = system.millis()

  local ram_usage = 0
  if heap_total > 0 then
    ram_usage = ((heap_total - free_heap) / heap_total) * 100
  end

  ui.header(lang["menu_system_info"])
  print("\n" .. colors.title(lang["sysinfo_title"]))

  print(string.format("%s: %s", lang["sysinfo_chip"], system.chipModel()))
  print(string.format("%s: %.2f s", lang["sysinfo_uptime"], uptime_ms / 1000))
  print(string.format("%s: %s / %s (%.1f%%)",
    lang["sysinfo_ram"],
    format_size(heap_total - free_heap),
    format_size(heap_total),
    ram_usage))
  print(string.format("%s: %s", lang["sysinfo_flash"], format_size(flash_size)))

  if sd.available() then
    local total = sd.totalBytes()
    local used = sd.usedBytes()

    if total and used and total > 0 then
      local percent = (used / total) * 100
      print(string.format("%s: %s / %s (%.1f%%)",
        lang["sysinfo_sd_card"],
        colors.CYAN .. format_size(used) .. colors.RESET,
        colors.CYAN .. format_size(total) .. colors.RESET,
        percent))
    else
      print(lang["sysinfo_sd_card"] .. ": " .. colors.warning("N/A"))
    end
  else
    print(lang["sysinfo_sd_card"] .. ": " .. colors.error(lang["wifi_not_connected"]))
  end
end

function system_monitor.show()
  system_monitor.show_info()
  serial.print("\n" .. lang["sysinfo_press_key"] .. "\n")
  serial.readKey()
end

return system_monitor
