-- ANSI color codes module for terminal output
local ansi = {}

-- ANSI escape codes
ansi.codes = {
  -- Reset
  reset = "\027[0m",
  
  -- Text colors
  black = "\027[30m",
  red = "\027[31m",
  green = "\027[32m",
  yellow = "\027[33m",
  blue = "\027[34m",
  magenta = "\027[35m",
  cyan = "\027[36m",
  white = "\027[37m",
  
  -- Bright text colors
  bright_black = "\027[90m",
  bright_red = "\027[91m",
  bright_green = "\027[92m",
  bright_yellow = "\027[93m",
  bright_blue = "\027[94m",
  bright_magenta = "\027[95m",
  bright_cyan = "\027[96m",
  bright_white = "\027[97m",
  
  -- Background colors
  bg_black = "\027[40m",
  bg_red = "\027[41m",
  bg_green = "\027[42m",
  bg_yellow = "\027[43m",
  bg_blue = "\027[44m",
  bg_magenta = "\027[45m",
  bg_cyan = "\027[46m",
  bg_white = "\027[47m",
  
  -- Text styles
  bold = "\027[1m",
  dim = "\027[2m",
  italic = "\027[3m",
  underline = "\027[4m",
  blink = "\027[5m",
  reverse = "\027[7m",
  hidden = "\027[8m",
  
  -- Cursor control
  clear_screen = "\027[2J\027[H",
  clear_line = "\027[2K",
  cursor_up = "\027[1A",
  cursor_down = "\027[1B",
  cursor_right = "\027[1C",
  cursor_left = "\027[1D",
  cursor_home = "\027[H",
  cursor_save = "\027[s",
  cursor_restore = "\027[u",
}

-- Helper functions for colored output
function ansi.color(text, color_code)
  return color_code .. text .. ansi.codes.reset
end

function ansi.success(text)
  return ansi.color(text, ansi.codes.green)
end

function ansi.error(text)
  return ansi.color(text, ansi.codes.red)
end

function ansi.warning(text)
  return ansi.color(text, ansi.codes.yellow)
end

function ansi.info(text)
  return ansi.color(text, ansi.codes.blue)
end

function ansi.highlight(text)
  return ansi.color(text, ansi.codes.cyan)
end

function ansi.bold(text)
  return ansi.codes.bold .. text .. ansi.codes.reset
end

function ansi.dim(text)
  return ansi.codes.dim .. text .. ansi.codes.reset
end

-- Clear screen (PuTTY compatible)
function ansi.clear()
  return ansi.codes.clear_screen
end

-- Progress bar
function ansi.progress_bar(percent, width)
  width = width or 20
  -- Ensure percent is a valid number and convert to integer
  percent = tonumber(percent) or 0
  percent = math.floor(percent)
  
  local filled = math.floor(percent / 100 * width)
  local empty = width - filled
  
  local bar = "["
  if filled > 0 then
    bar = bar .. ansi.color(string.rep("█", filled), ansi.codes.green)
  end
  if empty > 0 then
    bar = bar .. ansi.color(string.rep("░", empty), ansi.codes.dim)
  end
  bar = bar .. "] " .. string.format("%3d%%", percent)
  
  return bar
end

-- Status indicator
function ansi.status(success)
  if success then
    return ansi.success("✓")
  else
    return ansi.error("✗")
  end
end

return ansi
