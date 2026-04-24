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

function lang.switch(new_lang)
  if new_lang ~= "cs" and new_lang ~= "en" then
    return false
  end

  current_lang = new_lang
  lang.load(current_lang)

  local ok_cfg, config_or_err = pcall(dofile, "/ESP-OS/config/system.lua")
  if not ok_cfg or type(config_or_err) ~= "table" then
    serial.print("[ERROR] Failed to load system config for language save\n")
    return false
  end

  config_or_err.language = new_lang

  local file_content = "config = {\n"
  for k, v in pairs(config_or_err) do
    if type(v) == "string" then
      file_content = file_content .. "  " .. k .. ' = "' .. v .. '",\n'
    elseif type(v) == "boolean" then
      file_content = file_content .. "  " .. k .. " = " .. tostring(v) .. ",\n"
    else
      file_content = file_content .. "  " .. k .. " = " .. tostring(v) .. ",\n"
    end
  end
  file_content = file_content .. "}\nreturn config\n"

  local ok_write = sd.write("/ESP-OS/config/system.lua", file_content)
  if ok_write then
    config = config_or_err
  end
  return ok_write and true or false
end

setmetatable(lang, {
  __index = function(_, key)
    return lang.get(key)
  end
})

return lang
