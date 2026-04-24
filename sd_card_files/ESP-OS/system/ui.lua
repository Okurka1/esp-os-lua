-- UI helper funkce pro textové rozhraní přes Serial
local ui = {}

function ui.clear()
  -- Simulace vyčištění obrazovky výpisem prázdných řádků
  for _ = 1, 20 do
    serial.print("\n")
  end
end

function ui.header(text)
  local line = string.rep("=", 44)
  serial.print(line .. "\n")
  serial.print("  " .. text .. "\n")
  serial.print(line .. "\n")
end

function ui.box(lines)
  local width = 44
  serial.print("+" .. string.rep("-", width - 2) .. "+\n")
  for _, entry in ipairs(lines) do
    local text = tostring(entry)
    if #text > width - 4 then
      text = text:sub(1, width - 7) .. "..."
    end
    serial.print("| " .. text .. string.rep(" ", width - 3 - #text) .. "|\n")
  end
  serial.print("+" .. string.rep("-", width - 2) .. "+\n")
end

function ui.prompt(text)
  serial.print(text)
  return serial.read()
end

return ui
