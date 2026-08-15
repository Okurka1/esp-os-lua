# ESP-OS Lua API Reference v0.0.4

Complete Lua API documentation for ESP-OS.

## 📋 Table of Contents

- [serial - Serial Communication](#serial---serial-communication)
- [wifi - Wi-Fi Management](#wifi---wi-fi-management)
- [gpio - GPIO Control](#gpio---gpio-control)
- [sd - SD Card](#sd---sd-card)
- [system - System Functions](#system---system-functions)
- [dofile - Script Loading](#dofile---script-loading)

---

## serial - Serial Communication

### `serial.print(text)`
Prints text to serial port without newline.

**Parameters:**
- `text` (string) - Text to print

**Example:**
```lua
serial.print("Hello ")
serial.print("World\n")
```

---

### `serial.read()`
Reads a line from serial port (waits for Enter).

**Returns:**
- `string` - Read text

**Example:**
```lua
serial.print("Enter name: ")
local name = serial.read()
serial.print("Hello " .. name .. "!\n")
```

---

### `serial.readPassword()`
Reads password from serial port (masked with asterisks).

**Returns:**
- `string` - Read password

**Example:**
```lua
serial.print("Enter password: ")
local password = serial.readPassword()
```

---

### `serial.readKey()`
Reads one character from serial port (without Enter).

**Returns:**
- `string` - Read character (1 char)

**Example:**
```lua
serial.print("Press key [Y/N]: ")
local choice = serial.readKey()
if choice == "Y" or choice == "y" then
  serial.print("Yes!\n")
end
```

---

### `serial.available()`
Returns number of available bytes in serial buffer.

**Returns:**
- `number` - Number of available bytes

---

## wifi - Wi-Fi Management

### `wifi.scan()`
Scans available Wi-Fi networks.

**Returns:**
- `table` - Array of objects with network information

**Object structure:**
```lua
{
  ssid = "NetworkName",
  rssi = -45,           -- Signal strength in dBm
  encryption = 3        -- Encryption type
}
```

**Example:**
```lua
local networks = wifi.scan()
for i, net in ipairs(networks) do
  print(string.format("%d. %s (%d dBm)", i, net.ssid, net.rssi))
end
```

---

### `wifi.connect(ssid, password)`
Connects to Wi-Fi network.

**Parameters:**
- `ssid` (string) - Network name
- `password` (string, optional) - Password (empty for open networks)

**Returns:**
- `boolean` - `true` if connection succeeded

**Example:**
```lua
if wifi.connect("MyNetwork", "password123") then
  print("Connected!")
else
  print("Connection failed")
end
```

---

### `wifi.disconnect()`
Disconnects from Wi-Fi network.

**Returns:**
- `boolean` - `true` if disconnection succeeded

---

### `wifi.status()`
Returns current Wi-Fi connection status.

**Returns:**
- `string` - Status: `"CONNECTED"`, `"DISCONNECTED"`, `"NO_SSID"`, `"CONNECT_FAILED"`, `"CONNECTION_LOST"`, `"IDLE"`, `"UNKNOWN"`

**Example:**
```lua
if wifi.status() == "CONNECTED" then
  print("Connected to network")
end
```

---

### `wifi.ip()`
Returns device IP address.

**Returns:**
- `string` - IP address (e.g. `"192.168.1.100"`)

---

### `wifi.startAP(ssid, password)`
Starts Access Point mode.

**Parameters:**
- `ssid` (string) - AP name
- `password` (string, optional) - Password (min 8 chars, empty for open AP)

**Returns:**
- `boolean` - `true` if start succeeded

**Example:**
```lua
if wifi.startAP("ESP-OS-AP", "password123") then
  print("AP started on IP: " .. wifi.ip())
end
```

---

### `wifi.rssi()`
Returns signal strength of current network.

**Returns:**
- `number` - Signal strength in dBm (e.g. `-45`)

---

### `wifi.ssid()`
Returns current network name.

**Returns:**
- `string` - SSID

---

### `wifi.mac()`
Returns device MAC address.

**Returns:**
- `string` - MAC address (e.g. `"AA:BB:CC:DD:EE:FF"`)

---

### `wifi.gateway()`
Returns gateway IP address.

**Returns:**
- `string` - Gateway IP address

---

### `wifi.dns()`
Returns DNS server IP address.

**Returns:**
- `string` - DNS IP address

---

### `wifi.channel()`
Returns Wi-Fi channel number.

**Returns:**
- `number` - Channel number (1-13)

---

### `wifi.phyMode()`
Returns PHY connection mode.

**Returns:**
- `string` - Mode: `"802.11b"`, `"802.11g"`, `"802.11n"`, `"N/A"`

---

## gpio - GPIO Control

### `gpio.mode(pin, mode)`
Sets GPIO pin mode.

**Parameters:**
- `pin` (number) - Pin number (e.g. `2`, `4`, `5`)
- `mode` (string|number) - Mode: `"INPUT"`, `"OUTPUT"`, `"INPUT_PULLUP"` or numeric constant

**Example:**
```lua
gpio.mode(2, "OUTPUT")
gpio.mode(4, "INPUT_PULLUP")
```

---

### `gpio.write(pin, value)`
Writes digital value to pin.

**Parameters:**
- `pin` (number) - Pin number
- `value` (number) - Value: `0` (LOW) or `1` (HIGH)

**Example:**
```lua
gpio.mode(2, "OUTPUT")
gpio.write(2, 1)  -- Turn on pin 2
system.delay(1000)
gpio.write(2, 0)  -- Turn off pin 2
```

---

### `gpio.read(pin)`
Reads digital value from pin.

**Parameters:**
- `pin` (number) - Pin number

**Returns:**
- `number` - Value: `0` or `1`

**Example:**
```lua
gpio.mode(4, "INPUT_PULLUP")
local state = gpio.read(4)
print("Pin 4 is: " .. (state == 1 and "HIGH" or "LOW"))
```

---

### `gpio.analogWrite(pin, value)`
Sets PWM output on pin (0-255).

**Parameters:**
- `pin` (number) - Pin number
- `value` (number) - PWM value (0-255)

**Example:**
```lua
-- Set LED to 50% brightness
gpio.analogWrite(2, 128)
```

---

### `gpio.analogRead(pin)`
Reads analog value from ADC pin.

**Parameters:**
- `pin` (number) - ADC pin number (32, 33, 34, 35, 36, 39)

**Returns:**
- `number` - Value (0-4095)

**Example:**
```lua
local value = gpio.analogRead(34)
local voltage = (value / 4095) * 3.3
print(string.format("Voltage: %.2f V", voltage))
```

---

## sd - SD Card

### `sd.available()`
Checks SD card availability.

**Returns:**
- `boolean` - `true` if SD card is available

---

### `sd.exists(path)`
Checks file or directory existence.

**Parameters:**
- `path` (string) - File path

**Returns:**
- `boolean` - `true` if file exists

**Example:**
```lua
if sd.exists("/ESP-OS/config/wifi.lua") then
  print("Configuration exists")
end
```

---

### `sd.read(path)`
Reads entire file from SD card (max 32KB).

**Parameters:**
- `path` (string) - File path

**Returns:**
- `string` - File content
- `nil, string` - On error returns `nil` and error message

**Example:**
```lua
local content, err = sd.read("/ESP-OS/config/system.lua")
if content then
  print("Content: " .. content)
else
  print("Error: " .. err)
end
```

---

### `sd.write(path, content)`
Writes content to file (overwrites existing).

**Parameters:**
- `path` (string) - File path
- `content` (string) - Content to write

**Returns:**
- `boolean` - `true` if write succeeded
- `boolean, string` - On error returns `false` and error message

**Example:**
```lua
local ok, err = sd.write("/test.txt", "Hello World!")
if ok then
  print("File written")
else
  print("Error: " .. err)
end
```

---

### `sd.list(path)`
Lists directory contents.

**Parameters:**
- `path` (string, optional) - Directory path (default: `"/"`)

**Returns:**
- `table` - Array of objects with file information
- `nil, string` - On error returns `nil` and error message

**Object structure:**
```lua
{
  name = "file.txt",
  isDir = false,
  size = 1024          -- Only for files
}
```

**Example:**
```lua
local entries, err = sd.list("/ESP-OS")
if entries then
  for _, entry in ipairs(entries) do
    if entry.isDir then
      print("[DIR]  " .. entry.name)
    else
      print(string.format("%6d B  %s", entry.size, entry.name))
    end
  end
else
  print("Error: " .. err)
end
```

---

### `sd.size()`
Returns total SD card size.

**Returns:**
- `number` - Size in bytes

---

### `sd.free()`
Returns free space on SD card.

**Returns:**
- `number` - Free space in bytes

**Example:**
```lua
local free_mb = sd.free() / (1024 * 1024)
print(string.format("Free space: %.2f MB", free_mb))
```

---

## system - System Functions

### `system.restart()`
Restarts the device.

**Example:**
```lua
print("Restarting in 3 seconds...")
system.delay(3000)
system.restart()
```

---

### `system.shutdown()`
Shuts down device (deep sleep). Wake up by pressing BOOT button (GPIO0).

**Example:**
```lua
print("Shutting down device...")
system.delay(2000)
system.shutdown()
```

---

### `system.heap()`
Returns free RAM memory.

**Returns:**
- `number` - Free RAM in bytes

**Example:**
```lua
local free_kb = system.heap() / 1024
print(string.format("Free RAM: %.2f KB", free_kb))
```

---

### `system.heapSize()`
Returns total RAM memory size.

**Returns:**
- `number` - Total RAM in bytes

---

### `system.cpuFreq()`
Returns CPU frequency.

**Returns:**
- `number` - CPU frequency in MHz

**Example:**
```lua
print("CPU Frequency: " .. system.cpuFreq() .. " MHz")
```

---

### `system.flashSize()`
Returns flash memory size.

**Returns:**
- `number` - Flash size in bytes

---

### `system.chipModel()`
Returns chip model.

**Returns:**
- `string` - Chip model (e.g. `"ESP32-D0WDQ6"`)

---

### `system.millis()`
Returns time since device startup.

**Returns:**
- `number` - Time in milliseconds

**Example:**
```lua
local uptime_sec = system.millis() / 1000
print(string.format("Uptime: %.1f s", uptime_sec))
```

---

### `system.delay(ms)`
Waits for specified number of milliseconds.

**Parameters:**
- `ms` (number) - Number of milliseconds

**Example:**
```lua
print("Waiting 2 seconds...")
system.delay(2000)
print("Done!")
```

---

## dofile - Script Loading

### `dofile(path)`
Loads and executes Lua script from SD card (max 64KB).

**Parameters:**
- `path` (string) - Path to Lua file

**Returns:**
- Returns values that script returns using `return`

**Example:**
```lua
-- Load configuration
local config = dofile("/ESP-OS/config/system.lua")
print("Version: " .. config.version)

-- Load module
local ui = dofile("/ESP-OS/system/ui.lua")
ui.header("Test")
```

---

## 📝 Notes

### Safe ESP32 Pins
**Recommended pins for GPIO:**
- `2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33`

**ADC pins:**
- `32, 33, 34, 35, 36, 39`

**Avoid:**
- `0` (BOOT button)
- `1, 3` (UART TX/RX)
- `6-11` (Flash SPI)

### Memory Limits
- **Lua scripts (dofile):** max 64KB
- **sd.read():** max 32KB
- **Total RAM:** ~320KB (ESP32)

### Thread Safety
All Lua API functions are thread-safe thanks to mutex synchronization with 2000ms timeout.

---

**Documentation version:** 0.0.4  
**Date:** 2026-08-15
