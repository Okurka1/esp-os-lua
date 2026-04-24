-- System monitor module
local system_monitor = {}

local function fmt_bytes(bytes)
  if bytes == nil then
    return "N/A"
  end

  local units = {"B", "KB", "MB", "GB"}
  local idx = 1
  local value = tonumber(bytes) or 0

  while value >= 1024 and idx < #units do
    value = value / 1024
    idx = idx + 1
  end

  return string.format("%.2f %s", value, units[idx])
end

function system_monitor.show()
  local free_heap = system.heap()
  local heap_total = system.heapSize()
  local flash_size = system.flashSize()
  local uptime_ms = system.millis()

  local ram_usage = 0
  if heap_total > 0 then
    ram_usage = ((heap_total - free_heap) / heap_total) * 100
  end

  ui.header(lang["menu_system_info"])

  if not sd.available() then
    ui.box({
      lang["sysinfo_sd_card"] .. ": " .. lang["error_sd_not_connected"],
      lang["sysinfo_sd_retry"]
    })
    serial.print(lang["press_key"] .. "...\n")
    serial.readKey()
    return
  end

  local sd_total = sd.size()
  local sd_free = sd.free()

  ui.box({
    string.format("%s: %s", lang["sysinfo_chip"], system.chipModel()),
    string.format("%s: %.2f s", lang["sysinfo_uptime"], uptime_ms / 1000),
    string.format("%s: %s / %s (%.1f%%)", lang["sysinfo_ram"], fmt_bytes(heap_total - free_heap), fmt_bytes(heap_total), ram_usage),
    string.format("%s: %s", lang["sysinfo_flash"], fmt_bytes(flash_size)),
    string.format("%s: %s", lang["sysinfo_sd_total"], fmt_bytes(sd_total)),
    string.format("%s: %s", lang["sysinfo_sd_free"], fmt_bytes(sd_free))
  })

  serial.print("\n" .. lang["press_key_back"] .. "...\n")
  serial.readKey()
end

return system_monitor
