# ESP-OS Installation Guide

This guide explains how to install and run ESP-OS on ESP32.

## 1) Requirements

### Hardware
- ESP32 dev board
- MicroSD card (recommended FAT32)
- USB data cable
- Optional: 3.5" ESP32 display module

### Software
- [PlatformIO](https://platformio.org/) via:
  - VS Code extension, or
  - CLI (`pip install -U platformio`)
- USB serial driver for your ESP32 board (if needed)

## 2) Get the source code

```bash
git clone https://github.com/Okurka1/esp-os-lua.git
cd esp-os-lua
```

## 3) Prepare SD card

1. Format SD card as FAT or FAT32.
2. Copy folder `ESP-OS/` and `ESP-OS-Recovery` to SD card root.
3. Verify key files exist on SD card:
   - `/ESP-OS/boot/init.lua`
   - `/ESP-OS/system/kernel.lua`
   - `/ESP-OS/config/system.lua`
   - `/ESP-OS/config/wifi.lua`

## 4) Build firmware

```bash
pio run
```

## 5) Upload firmware

```bash
pio run -t upload
```

If your board is not detected, run:
```bash
pio device list
```
Then configure upload port in `platformio.ini` if needed.

## 6) Open Serial Monitor

```bash
pio device monitor -b 115200
```

Expected boot flow:
1. POST checks are printed.
2. SD mount check passes.
3. Lua kernel starts.
4. Main menu appears.

## 7) First Run Tips

- Use single-key input in menu (`1..5`, `Q`, `B`) where applicable.
- Wi-Fi passwords use masked input (`serial.readPassword`).
- If SD is unavailable, some features run in limited mode.

## 8) Common Problems

### SD card not detected
- Reformat FAT32.
- Check SD wiring and CS pin.
- Verify `SD_CS_PIN` in `include/config.h`.

### Upload fails
- Hold BOOT button while flashing (some boards).
- Check cable (must support data, not only power).
- Close other serial tools using the same COM port.

### Garbage serial output
- Ensure monitor baud is `115200`.

### Lua script error at boot
- Verify files on SD card and paths.
- Check syntax in modified Lua scripts.

## 9) Version Reference

Current target release: **v0.0.4**

See [CHANGELOG.md](CHANGELOG.md) for full release history.
