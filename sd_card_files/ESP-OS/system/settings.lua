local settings = {}
local colors = sd_require("system.colors")

local USER_CONFIG_PATH = "/ESP-OS/config/user.lua"

local function load_system_config()
  local ok, cfg = pcall(sd_require, "config.system")
  if ok and type(cfg) == "table" then
    return cfg
  end

  return {
    device_name = "ESP-OS",
    version = "0.0.3.2-dev",
    language = "cs",
    debug = false,
    auto_reconnect = true,
    use_colors = false,
  }
end

function settings.load_user_config()
  local ok, cfg = pcall(sd_require, "config.user")
  if ok and type(cfg) == "table" then
    return cfg
  end

  return {
    language = "cs",
    auto_reconnect = true,
    use_colors = false,
  }
end

function settings.load_runtime_config()
  local cfg = load_system_config()
  local user = settings.load_user_config()
  for k, v in pairs(user) do
    cfg[k] = v
  end
  return cfg
end

function settings.save_user_config(config)
  local content = string.format([[user = {
  language = %q,
  auto_reconnect = %s,
  use_colors = %s,
}

return user
]],
    tostring(config.language or "cs"),
    tostring(config.auto_reconnect == true),
    tostring(config.use_colors == true)
  )

  local ok = sd.write(USER_CONFIG_PATH, content)
  if ok then
    package.loaded["config.user"] = nil
    local merged = settings.load_runtime_config()
    _G.config = merged
  end
  return ok
end

function settings.change_language(config)
  print("\n" .. colors.info(lang["settings_change_lang"]))
  print("  [1] " .. lang["settings_czech"])
  print("  [2] " .. lang["settings_english"])
  print("\n" .. lang["menu_select"] .. " [1-2]: " .. colors.BRIGHT_GREEN)

  local choice = serial.readKey()
  print(colors.RESET)

  if choice == "1" then
    config.language = "cs"
    if settings.save_user_config(config) then
      print(colors.success("✓ Jazyk změněn na Čeština"))
      print(colors.info(lang["settings_restarting"]))
      system.delay(2000)
      system.restart()
    else
      print(colors.error(lang["settings_save_error"]))
    end
  elseif choice == "2" then
    config.language = "en"
    if settings.save_user_config(config) then
      print(colors.success("✓ Language changed to English"))
      print(colors.info(lang["settings_restarting"]))
      system.delay(2000)
      system.restart()
    else
      print(colors.error(lang["settings_save_error"]))
    end
  end
end

function settings.toggle_colors(config)
  config.use_colors = not config.use_colors
  if not settings.save_user_config(config) then
    print(colors.error(lang["settings_save_error"]))
    serial.readKey()
    return
  end

  colors = colors.reload()
  _G.colors = colors

  if config.use_colors then
    print(colors.success(lang["settings_colors_on"]))
    print(colors.info(lang["settings_colors_info_on"]))
  else
    print(lang["settings_colors_off"])
    print(lang["settings_colors_info_off"])
  end

  serial.readKey()
end

function settings.toggle_autoreconnect(config)
  config.auto_reconnect = not config.auto_reconnect

  if not settings.save_user_config(config) then
    print(colors.error(lang["settings_save_error"]))
    serial.readKey()
    return
  end

  if config.auto_reconnect then
    print(colors.success(lang["settings_autoreconnect_on"]))
  else
    print(colors.warning(lang["settings_autoreconnect_off"]))
  end

  serial.readKey()
end

function settings.show_menu()
  while true do
    local config = settings.load_runtime_config()

    print("\n" .. colors.title(lang["settings_title"]))
    print(colors.BRIGHT_BLACK .. "========================================" .. colors.RESET)
    print(colors.BRIGHT_BLACK .. "+---------------------------------------+" .. colors.RESET)
    print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[1]") .. " " .. lang["settings_language"] .. ": " .. (config.language == "cs" and lang["settings_czech"] or lang["settings_english"]) .. "                  " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
    print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[2]") .. " " .. lang["settings_colors"] .. ": " .. (config.use_colors and colors.success(lang["settings_enabled"]) or colors.error(lang["settings_disabled"])) .. "                    " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
    print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[3]") .. " " .. lang["settings_autoreconnect"] .. ": " .. (config.auto_reconnect and lang["settings_yes"] or lang["settings_no"]) .. "         " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
    print(colors.BRIGHT_BLACK .. "|" .. colors.RESET .. "  " .. colors.menu_item("[B]") .. " " .. lang["settings_back"] .. "                               " .. colors.BRIGHT_BLACK .. "|" .. colors.RESET)
    print(colors.BRIGHT_BLACK .. "+---------------------------------------+" .. colors.RESET)
    print("\n" .. lang["menu_select"] .. " [1-3/B]: " .. colors.BRIGHT_GREEN)

    local choice = serial.readKey()
    print(colors.RESET)

    if choice == "1" then
      settings.change_language(config)
    elseif choice == "2" then
      settings.toggle_colors(config)
    elseif choice == "3" then
      settings.toggle_autoreconnect(config)
    elseif choice == "b" or choice == "B" then
      break
    end
  end
end

settings.show = settings.show_menu

return settings
