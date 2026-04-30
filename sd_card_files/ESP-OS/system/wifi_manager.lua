-- WiFi manager module
local wifi_manager = {}
local colors = sd_require("system.colors")

local CONFIG_PATH = "/ESP-OS/config/wifi.lua"

wifi_manager.config = nil
wifi_manager.last_scan = {}

local function trim(value)
  return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function wait_back()
  serial.print(lang["sysinfo_press_key"] .. "\n")
  serial.readKey()
end

local function default_config()
  return {
    auto_reconnect = true,
    saved_networks = {},
    ap_mode = {
      ssid = "ESP-OS-AP",
      password = "12345678"
    }
  }
end

function wifi_manager.default_config()
  return default_config()
end

function wifi_manager.signal_strength_percent(rssi)
  local value = tonumber(rssi)
  if not value then
    return 0
  end
  return math.min(100, math.max(0, (value + 100) * 2))
end

function wifi_manager.load_config()
  if not sd.available() then
    serial.print("[WiFi][" .. lang["error"] .. "] " .. lang["error_sd_not_connected"] .. "\n")
    wifi_manager.config = default_config()
    return wifi_manager.config
  end

  if not sd.exists(CONFIG_PATH) then
    wifi_manager.config = default_config()
    wifi_manager.save_config()
    return wifi_manager.config
  end

  local ok, cfg = pcall(dofile, CONFIG_PATH)
  if not ok or type(cfg) ~= "table" then
    wifi_manager.config = default_config()
    return wifi_manager.config
  end

  cfg.auto_reconnect = (cfg.auto_reconnect ~= false)
  cfg.saved_networks = cfg.saved_networks or {}
  cfg.ap_mode = cfg.ap_mode or { ssid = "ESP-OS-AP", password = "12345678" }
  cfg.ap_mode.ssid = cfg.ap_mode.ssid or "ESP-OS-AP"
  cfg.ap_mode.password = cfg.ap_mode.password or "12345678"

  wifi_manager.config = cfg
  return cfg
end

function wifi_manager.save_config()
  if not sd.available() then
    serial.print("[WiFi][" .. lang["error"] .. "] " .. lang["error_sd_not_connected"] .. "\n")
    return false
  end

  local cfg = wifi_manager.config or default_config()

  local lines = {
    "wifi_config = {",
    string.format("  auto_reconnect = %s,", cfg.auto_reconnect and "true" or "false"),
    "  saved_networks = {"
  }

  for _, net in ipairs(cfg.saved_networks or {}) do
    table.insert(lines, string.format("    { ssid = %q, password = %q, priority = %d },", net.ssid or "", net.password or "", tonumber(net.priority) or 1))
  end

  table.insert(lines, "  },")
  table.insert(lines, "  ap_mode = {")
  table.insert(lines, string.format("    ssid = %q,", cfg.ap_mode.ssid or "ESP-OS-AP"))
  table.insert(lines, string.format("    password = %q", cfg.ap_mode.password or "12345678"))
  table.insert(lines, "  }")
  table.insert(lines, "}")
  table.insert(lines, "return wifi_config")

  return sd.write(CONFIG_PATH, table.concat(lines, "\n") .. "\n") and true or false
end

function wifi_manager.save_network(ssid, password)
  local cfg = wifi_manager.load_config()
  local target_ssid = trim(ssid)

  if target_ssid == "" then
    return false
  end

  local found = false
  for _, net in ipairs(cfg.saved_networks) do
    if net.ssid == target_ssid then
      net.password = tostring(password or "")
      found = true
      break
    end
  end

  if not found then
    table.insert(cfg.saved_networks, {
      ssid = target_ssid,
      password = tostring(password or ""),
      priority = #cfg.saved_networks + 1
    })
  end

  wifi_manager.config = cfg
  return wifi_manager.save_config()
end

local function sort_networks_by_priority(networks)
  table.sort(networks, function(a, b)
    local pa = tonumber(a.priority) or 999
    local pb = tonumber(b.priority) or 999
    return pa < pb
  end)
end

local function connect_to_network(ssid, password, is_open)
  if trim(ssid) == "" then
    ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_failed"]})
    return false
  end

  if not is_open and #tostring(password or "") < 8 then
    ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_password_min"]})
    return false
  end

  ui.box({lang["wifi_connecting"] .. " " .. ssid .. "..."})
  local ok = wifi.connect(ssid, password or "")
  if ok then
    print(colors.success(lang["wifi_connected"]))
    ui.box({lang["wifi_connected"], lang["wifi_ip"] .. " " .. (wifi.ip() or "N/A")})
    return true
  end

  print(colors.error("[" .. lang["error"] .. "] " .. lang["wifi_failed"]))
  ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_failed"]})
  return false
end

local function scan_networks()
  ui.header(lang["wifi_scan"])
  print(colors.info(lang["wifi_scanning"]))

  local networks = wifi.scan() or {}
  wifi_manager.last_scan = networks

  if #networks == 0 then
    ui.box({lang["wifi_no_networks"]})
    wait_back()
    return
  end

  serial.print(lang["wifi_found"] .. " " .. tostring(#networks) .. " " .. lang["wifi_networks"] .. "\n")
  for i, net in ipairs(networks) do
    local ssid = trim(net.ssid)
    if ssid == "" then ssid = "<hidden>" end
    local rssi = tonumber(net.rssi) or -100
    local percent = wifi_manager.signal_strength_percent(rssi)
    serial.print(string.format("[%d] %s | %d dBm (%d%%)\n", i, ssid, rssi, percent))
  end

  local choice = ui.prompt(lang["wifi_select"] .. tostring(#networks) .. "]: ")
  local idx = tonumber(trim(choice))
  if not idx or not networks[idx] then
    return
  end

  local selected = networks[idx]
  local ssid = trim(selected.ssid)
  local password = ""
  if tonumber(selected.encryption) ~= 0 then
    serial.print(lang["wifi_enter_pass"] .. " " .. ssid .. "\n")
    serial.print(lang["wifi_password"] .. " ")
    password = serial.readPassword() or ""
  end

  if connect_to_network(ssid, password, tonumber(selected.encryption) == 0) then
    wifi_manager.save_network(ssid, password)
  end

  wait_back()
end

local function connect_manual()
  ui.header(lang["wifi_connect"])
  local ssid = trim(ui.prompt(lang["wifi_ssid"] .. " "))
  if ssid == "" then
    ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_failed"]})
    return
  end

  serial.print(lang["wifi_enter_pass"] .. " " .. ssid .. "\n")
  serial.print(lang["wifi_password"] .. " ")
  local password = serial.readPassword() or ""
  if connect_to_network(ssid, password, false) then
    wifi_manager.save_network(ssid, password)
  end

  wait_back()
end

local function disconnect_network()
  local ok = wifi.disconnect()
  if ok then
    ui.box({lang["wifi_disconnected"]})
  else
    ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_failed"]})
  end
  wait_back()
end

local function start_ap_mode()
  local cfg = wifi_manager.load_config()
  ui.header(lang["wifi_ap_mode"])

  local ssid = trim(ui.prompt(lang["wifi_ap_ssid"] .. " [" .. cfg.ap_mode.ssid .. "]: "))
  if ssid == "" then ssid = cfg.ap_mode.ssid end

  local password = trim(ui.prompt(lang["wifi_ap_pass"] .. " [" .. cfg.ap_mode.password .. "]: "))
  if password == "" then password = cfg.ap_mode.password end

  if #password < 8 then
    ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_password_min"]})
    return
  end

  local ok = wifi.startAP(ssid, password)
  if ok then
    cfg.ap_mode.ssid = ssid
    cfg.ap_mode.password = password
    wifi_manager.config = cfg
    wifi_manager.save_config()
    ui.box({lang["wifi_ap_started"], lang["wifi_ap_ip"] .. " " .. (wifi.ip() or "192.168.4.1")})
  else
    ui.box({"[" .. lang["error"] .. "] " .. lang["wifi_failed"]})
  end

  wait_back()
end

local function show_saved_networks()
  local cfg = wifi_manager.load_config()
  local networks = cfg.saved_networks or {}
  sort_networks_by_priority(networks)

  ui.header(lang["wifi_saved_networks"])
  if #networks == 0 then
    ui.box({lang["wifi_saved_networks"], "-"})
    wait_back()
    return
  end

  serial.print(lang["wifi_saved_networks"] .. "\n")
  for i, net in ipairs(networks) do
    serial.print(string.format("[%d] %s\n", i, net.ssid or "?"))
  end

  serial.print("[P] Connect [S] Delete [B] " .. lang["wifi_back"] .. ": ")
  local action = string.lower(tostring(serial.readKey() or ""))
  if action == "b" then
    return
  end

  if action == "p" then
    local idx = tonumber(ui.prompt("#: "))
    if idx and networks[idx] then
      connect_to_network(networks[idx].ssid, networks[idx].password, (networks[idx].password or "") == "")
    end
  elseif action == "s" then
    local idx = tonumber(ui.prompt("#: "))
    if idx and networks[idx] then
      table.remove(networks, idx)
      for i, net in ipairs(networks) do
        net.priority = i
      end
      cfg.saved_networks = networks
      wifi_manager.config = cfg
      wifi_manager.save_config()
      ui.box({lang["settings_saved"]})
    end
  end

  wait_back()
end

local function toggle_auto_reconnect()
  local cfg = wifi_manager.load_config()
  cfg.auto_reconnect = not cfg.auto_reconnect
  wifi_manager.config = cfg
  wifi_manager.save_config()
  local state = cfg.auto_reconnect and lang["enabled"] or lang["disabled"]
  ui.box({lang["wifi_autoreconnect"] .. ": " .. state})
  wait_back()
end

function wifi_manager.show_info()
  print("\n╔════════════════════════════════════════╗")
  print("║           " .. lang["wifi_info"] .. "             ║")
  print("╚════════════════════════════════════════╝")

  local status = wifi.status()
  if status == "CONNECTED" or status == 3 then
    print("\n" .. lang["wifi_status"] .. " " .. lang["wifi_connected"])
    print(lang["wifi_ssid"] .. " " .. (wifi.ssid() or "N/A"))
    print(lang["wifi_ip"] .. " " .. (wifi.ip() or "N/A"))
    print(lang["wifi_gateway"] .. " " .. (wifi.gateway() or "N/A"))
    print(lang["wifi_dns"] .. " " .. (wifi.dns() or "N/A"))
    print(lang["wifi_mac"] .. " " .. (wifi.mac() or "N/A"))
    print(lang["wifi_channel"] .. " " .. tostring(wifi.channel() or "N/A"))
    print(lang["wifi_speed"] .. " " .. (wifi.phyMode() or "N/A"))

    local rssi = wifi.rssi()
    if rssi then
      local percent = math.min(100, math.max(0, (rssi + 100) * 2))
      print(string.format("%s %d dBm (%.0f%%)", lang["wifi_signal"], rssi, percent))
    end
  else
    print("\n" .. lang["wifi_not_connected"])
    print(lang["wifi_status"] .. " " .. tostring(status or "N/A"))
  end

  wait_back()
end

function wifi_manager.auto_connect()
  local cfg = wifi_manager.load_config()
  local networks = cfg.saved_networks or {}
  if #networks == 0 then
    return false
  end

  sort_networks_by_priority(networks)
  local net = networks[1]
  return connect_to_network(net.ssid, net.password or "", (net.password or "") == "")
end

function wifi_manager.show()
  wifi_manager.load_config()

  while true do
    local cfg = wifi_manager.load_config()
    ui.clear()
    ui.header(lang["wifi_title"])
    ui.box({
      "[1] " .. lang["wifi_scan"],
      "[2] " .. lang["wifi_connect"],
      "[3] " .. lang["wifi_disconnect"],
      "[4] " .. lang["wifi_ap_mode"],
      "[5] " .. lang["wifi_saved_networks"],
      "[6] " .. lang["wifi_autoreconnect"] .. ": " .. tostring(cfg.auto_reconnect),
      "[7] " .. lang["wifi_info"],
      "[B] " .. lang["wifi_back"]
    })

    serial.print(lang["menu_select"] .. " [1-7/B]: ")
    local choice = string.lower(tostring(serial.readKey() or ""))

    if choice == "1" then
      scan_networks()
    elseif choice == "2" then
      connect_manual()
    elseif choice == "3" then
      disconnect_network()
    elseif choice == "4" then
      start_ap_mode()
    elseif choice == "5" then
      show_saved_networks()
    elseif choice == "6" then
      toggle_auto_reconnect()
    elseif choice == "7" then
      wifi_manager.show_info()
    elseif choice == "b" then
      break
    else
      ui.box({"[" .. lang["error"] .. "] " .. lang["error_invalid_choice"]})
      system.delay(900)
    end
  end
end

return wifi_manager
