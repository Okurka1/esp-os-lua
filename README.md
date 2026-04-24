# ESP-OS v0.0.3.1

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: ESP32](https://img.shields.io/badge/Platform-ESP32-E7352C)](https://www.espressif.com/en/products/socs/esp32)
[![Language: Lua + C++](https://img.shields.io/badge/Language-Lua%205.4%20%2B%20C%2B%2B-blue)](https://www.lua.org/)
[![Version: v0.0.3.1](https://img.shields.io/badge/Version-v0.0.3.1-success)](CHANGELOG.md)

> **Lua-powered Operating System for ESP32**

ESP-OS is a modular embedded OS concept for ESP32:
- low-level boot + hardware APIs in **C++ (Arduino framework)**,
- system logic and UI in **Lua scripts stored on SD card**.

## ✨ Features

- 🚀 **Fast boot pipeline** with POST and SD card checks
- 🧠 **Embedded Lua VM (5.4)** for dynamic scripting
- 🌍 **Dual language UI** (Czech/English) with runtime switch
- 📶 **Advanced Wi-Fi manager** (scan, connect, AP mode, diagnostics)
- 🔌 **GPIO manager** (digital I/O, PWM, ADC read)
- 💻 **CMD console** with useful service commands
- 🛡️ **Thread-safe Lua C API bridge** via mutex-protected calls
- 💾 **SD-first architecture** for scripts and runtime configuration

## 📸 Screenshots

_Screenshots will be added soon..._

## ⚡ Quick Start

1. Install [PlatformIO](https://platformio.org/) (VS Code extension or CLI).
2. Clone this repository:
   ```bash
   git clone https://github.com/Okurka1/esp-os-lua.git
   cd esp-os-lua
   ```
3. Copy `sd_card_files/ESP-OS/` to the root of your FAT32 SD card.
4. Build and upload firmware:
   ```bash
   pio run -t upload
   ```
5. Open serial monitor:
   ```bash
   pio device monitor -b 115200
   ```

For full setup details, see [INSTALL.md](INSTALL.md).

## 📚 Documentation

- [INSTALL.md](INSTALL.md) — full installation and first boot
- [CHANGELOG.md](CHANGELOG.md) — release history (v0.0.1 → v0.0.3.1)
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution workflow
- [README_cs.md](README_cs.md) — Czech documentation
- `sd_card_files/ESP-OS/` — runtime Lua system files

## 🏗️ Architecture

```text
+-------------------------------+
|         ESP32 Firmware        |
|   (C++ / Arduino Framework)   |
|  - Bootloader + POST          |
|  - Lua VM host                |
|  - Lua C APIs (wifi/gpio/sd)  |
+---------------+---------------+
                |
                v
+-------------------------------+
|       SD Card (FAT32)         |
|   /ESP-OS/boot/init.lua       |
|   /ESP-OS/system/*.lua        |
|   /ESP-OS/config/*.lua        |
|   /ESP-OS/lang/{cs,en}.lua    |
+---------------+---------------+
                |
                v
+-------------------------------+
|        Serial Text UI         |
|  Main Menu / WiFi / GPIO /    |
|  Settings / CMD Console       |
+-------------------------------+
```

## 🗺️ Roadmap

- ✅ **v0.0.1**: Initial boot, Lua runtime, base system modules
- ✅ **v0.0.2**: Wi-Fi + SD improvements
- ✅ **v0.0.3**: GPIO Manager, CMD Console, system UX upgrades
- ✅ **v0.0.3.1**: Dual language + extended Wi-Fi diagnostics
- 🔜 **v0.0.4**: Recovery mode and safer rollback flow
- 🔜 **v0.0.5**: Expanded TFT workflow and richer UI tools

## 🤝 Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening pull requests.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
