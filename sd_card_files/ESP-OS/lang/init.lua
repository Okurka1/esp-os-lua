-- Language System
lang = {}
local current_lang = "cs"
local translations = {}

function lang.load(language)
  current_lang = language or current_lang

  local lang_file = "/ESP-OS/lang/" .. current_lang .. ".lua"
  if not sd.exists(lang_file) then
    serial.print("[WARNING] Language file not found: " .. lang_file .. "\n")
    current_lang = "en"
    lang_file = "/ESP-OS/lang/en.lua"
  end

  local success, data = pcall(dofile, lang_file)
  if success and type(data) == "table" then
    translations = data
    serial.print("[LANG] Loaded: " .. current_lang .. "\n")
  else
    serial.print("[ERROR] Failed to load language: " .. current_lang .. "\n")
    translations = {}
  end
end

function lang.get(key)
  return translations[key] or key
end

function lang.current()
  return current_lang
end

local function load_user_config()
  local ok, cfg = pcall(dofile, "/ESP-OS/config/user.lua")
  if ok and type(cfg) == "table" then
    return cfg
  end
  return {
    language = "cs",
    auto_reconnect = true,
    use_colors = false,
  }
end

local function save_user_config(cfg)
  local file_content = string.format([[user = {
  language = %q,
  auto_reconnect = %s,
  use_colors = %s,
}

return user
]],
    tostring(cfg.language or "cs"),
    tostring(cfg.auto_reconnect == true),
    tostring(cfg.use_colors == true)
  )

  return sd.write("/ESP-OS/config/user.lua", file_content)
end

function lang.switch(new_lang)
  if new_lang ~= "cs" and new_lang ~= "en" then
    return false
  end

  current_lang = new_lang
  lang.load(current_lang)

  local user_cfg = load_user_config()
  user_cfg.language = new_lang

  local ok_write = save_user_config(user_cfg)
  if ok_write then
    package.loaded["config.user"] = nil
    if _G.config and type(_G.config) == "table" then
      _G.config.language = new_lang
    end
  end

  return ok_write and true or false
end

setmetatable(lang, {
  __index = function(_, key)
    return lang.get(key)
  end
})

return lang
