-- ANSI Color Codes
colors = {}

-- Načti config (user override -> system fallback)
local use_colors = false

do
  local ok_user, user_cfg = pcall(sd_require, "config.user")
  if ok_user and type(user_cfg) == "table" and user_cfg.use_colors ~= nil then
    use_colors = user_cfg.use_colors
  else
    local ok_system, system_cfg = pcall(sd_require, "config.system")
    if ok_system and type(system_cfg) == "table" then
      use_colors = system_cfg.use_colors or false
    end
  end
end

-- Pokud jsou barvy vypnuté, všechny kódy budou prázdné
if not use_colors then
  -- Vypnuto - všechny barvy prázdné
  colors.RESET = ""
  colors.BLACK = ""
  colors.RED = ""
  colors.GREEN = ""
  colors.YELLOW = ""
  colors.BLUE = ""
  colors.MAGENTA = ""
  colors.CYAN = ""
  colors.WHITE = ""
  colors.BRIGHT_BLACK = ""
  colors.BRIGHT_RED = ""
  colors.BRIGHT_GREEN = ""
  colors.BRIGHT_YELLOW = ""
  colors.BRIGHT_BLUE = ""
  colors.BRIGHT_MAGENTA = ""
  colors.BRIGHT_CYAN = ""
  colors.BRIGHT_WHITE = ""
  colors.BOLD = ""
else
  -- Zapnuto - ANSI kódy
  colors.RESET = "\27[0m"
  colors.BLACK = "\27[30m"
  colors.RED = "\27[31m"
  colors.GREEN = "\27[32m"
  colors.YELLOW = "\27[33m"
  colors.BLUE = "\27[34m"
  colors.MAGENTA = "\27[35m"
  colors.CYAN = "\27[36m"
  colors.WHITE = "\27[37m"
  colors.BRIGHT_BLACK = "\27[90m"
  colors.BRIGHT_RED = "\27[91m"
  colors.BRIGHT_GREEN = "\27[92m"
  colors.BRIGHT_YELLOW = "\27[93m"
  colors.BRIGHT_BLUE = "\27[94m"
  colors.BRIGHT_MAGENTA = "\27[95m"
  colors.BRIGHT_CYAN = "\27[96m"
  colors.BRIGHT_WHITE = "\27[97m"
  colors.BOLD = "\27[1m"
end

-- Helper funkce
function colors.success(text)
  return colors.GREEN .. text .. colors.RESET
end

function colors.error(text)
  return colors.RED .. text .. colors.RESET
end

function colors.warning(text)
  return colors.YELLOW .. text .. colors.RESET
end

function colors.info(text)
  return colors.CYAN .. text .. colors.RESET
end

function colors.menu_item(text)
  return colors.BRIGHT_BLUE .. text .. colors.RESET
end

function colors.title(text)
  return colors.BOLD .. colors.BRIGHT_WHITE .. text .. colors.RESET
end

-- Funkce pro reload po změně nastavení
function colors.reload()
  package.loaded["config.user"] = nil
  package.loaded["config.system"] = nil
  package.loaded["system.colors"] = nil
  return sd_require("system.colors")
end

return colors
