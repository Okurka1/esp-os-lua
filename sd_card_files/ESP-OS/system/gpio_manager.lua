-- GPIO manager module
local gpio_manager = {}

gpio_manager.safe_pins = {
  2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33
}

gpio_manager.reserved_pins = {
  0, 1, 3, 6, 7, 8, 9, 10, 11
}

function gpio_manager.is_reserved(pin)
  for _, reserved in ipairs(gpio_manager.reserved_pins) do
    if pin == reserved then
      return true
    end
  end
  return false
end

local function ask_pin()
  print("\n" .. lang["gpio_enter_pin"] .. ": ")
  local pin_str = serial.read()
  local pin = tonumber(pin_str)
  if not pin then
    print("[ERROR] " .. lang["error_invalid_pin"])
    system.delay(1200)
    return nil
  end
  return pin
end

local function reserved_warning(pin)
  if not gpio_manager.is_reserved(pin) then
    return true
  end

  print("\n" .. string.format(lang["gpio_warning_reserved"], pin))
  print(lang["gpio_warning_damage"])
  print(lang["gpio_warning_continue"] .. " [y/n]: ")
  local confirm = serial.readKey()
  return confirm == "y" or confirm == "Y" or confirm == "a" or confirm == "A"
end

function gpio_manager.show_overview()
  print("\n╔════════════════════════════════════════╗")
  print("║  " .. lang["gpio_overview"] .. "                          ║")
  print("╠═══════╤════════╤═══════╤═══════════════╣")
  print("║  Pin  │ Mode   │ State │ Function      ║")
  print("╠═══════╪════════╪═══════╪═══════════════╣")

  for _, pin in ipairs(gpio_manager.safe_pins) do
    print(string.format("║  %2d   │ %-6s │  %-3s  │ %-13s ║", pin, "N/A", "N/A", "[FREE]"))
  end

  print("╚═══════╧════════╧═══════╧═══════════════╝")
  print("\n" .. lang["press_key"] .. "...")
  serial.readKey()
end

function gpio_manager.digital_control()
  print("\n╔════════════════════════════════════════╗")
  print("║  " .. lang["gpio_digital"] .. "                       ║")
  print("╚════════════════════════════════════════╝")

  local pin = ask_pin()
  if not pin then
    return
  end

  if not reserved_warning(pin) then
    return
  end

  print("\n" .. lang["gpio_set_output"] .. " [y/n]: ")
  local mode = serial.readKey()

  if mode == "y" or mode == "Y" or mode == "a" or mode == "A" then
    gpio.mode(pin, 2)
    print("\n" .. lang["gpio_set_state"] .. ": ")
    local state = serial.readKey()
    if state == "0" then
      gpio.write(pin, 0)
      print("✓ Pin " .. pin .. " = 0")
    elseif state == "1" then
      gpio.write(pin, 1)
      print("✓ Pin " .. pin .. " = 1")
    else
      print("[ERROR] " .. lang["error_invalid_value"])
    end
  else
    gpio.mode(pin, 1)
    print("✓ Pin " .. pin .. " = " .. tostring(gpio.read(pin)))
  end

  print("\n" .. lang["press_key"] .. "...")
  serial.readKey()
end

function gpio_manager.pwm_control()
  print("\n╔════════════════════════════════════════╗")
  print("║  " .. lang["gpio_pwm"] .. "                           ║")
  print("╚════════════════════════════════════════╝")

  local pin = ask_pin()
  if not pin then
    return
  end

  if not reserved_warning(pin) then
    return
  end

  print("\n" .. lang["gpio_enter_pwm"] .. ": ")
  local value = tonumber(serial.read())
  if not value or value < 0 or value > 255 then
    print("[ERROR] " .. lang["error_invalid_value"])
    system.delay(1200)
    return
  end

  gpio.mode(pin, 2)
  gpio.analogWrite(pin, value)
  print(string.format("✓ Pin %d PWM = %d (%.1f%%)", pin, value, (value / 255) * 100))
  print("\n" .. lang["press_key"] .. "...")
  serial.readKey()
end

function gpio_manager.analog_read()
  print("\n╔════════════════════════════════════════╗")
  print("║  " .. lang["gpio_analog"] .. "                 ║")
  print("╚════════════════════════════════════════╝")

  print("\n" .. lang["gpio_adc_pins"] .. ": 32, 33, 34, 35, 36, 39")
  local pin = ask_pin()
  if not pin then
    return
  end

  gpio.mode(pin, 1)
  local value = gpio.analogRead(pin)
  local voltage = (value / 4095) * 3.3
  print(string.format("\n✓ Pin %d ADC = %d (%.2f V)", pin, value, voltage))

  print("\n" .. lang["press_key"] .. "...")
  serial.readKey()
end

function gpio_manager.show_config()
  print("\n╔════════════════════════════════════════╗")
  print("║  " .. lang["gpio_config"] .. "                      ║")
  print("╚════════════════════════════════════════╝")
  print("\n[INFO] Coming soon...")
  print(lang["press_key"] .. "...")
  serial.readKey()
end

function gpio_manager.show()
  while true do
    print("\n╔════════════════════════════════════════╗")
    print("║        " .. lang["gpio_title"] .. "                    ║")
    print("╠════════════════════════════════════════╣")
    print("║  [1] " .. lang["gpio_overview"] .. "                      ║")
    print("║  [2] " .. lang["gpio_digital"] .. "                   ║")
    print("║  [3] " .. lang["gpio_pwm"] .. "                       ║")
    print("║  [4] " .. lang["gpio_analog"] .. "                 ║")
    print("║  [5] " .. lang["gpio_config"] .. "                       ║")
    print("║  [B] " .. lang["back"] .. "                              ║")
    print("╚════════════════════════════════════════╝")
    print("\n" .. lang["menu_select"] .. " [1-5/B]: ")

    local choice = serial.readKey()

    if choice == "1" then
      gpio_manager.show_overview()
    elseif choice == "2" then
      gpio_manager.digital_control()
    elseif choice == "3" then
      gpio_manager.pwm_control()
    elseif choice == "4" then
      gpio_manager.analog_read()
    elseif choice == "5" then
      gpio_manager.show_config()
    elseif choice == "b" or choice == "B" then
      break
    else
      print("\n[ERROR] " .. lang["error_invalid_choice"])
      system.delay(1000)
    end
  end
end

return gpio_manager
