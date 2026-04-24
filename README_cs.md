# ESP-OS v0.0.3.1

[![Licence: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforma: ESP32](https://img.shields.io/badge/Platform-ESP32-E7352C)](https://www.espressif.com/en/products/socs/esp32)
[![Jazyk: Lua + C++](https://img.shields.io/badge/Language-Lua%205.4%20%2B%20C%2B%2B-blue)](https://www.lua.org/)
[![Verze: v0.0.3.1](https://img.shields.io/badge/Version-v0.0.3.1-success)](CHANGELOG.md)

> **Lua-powered Operating System for ESP32**

ESP-OS je modulární koncept embedded operačního systému pro ESP32:
- nízkoúrovňový boot a HW API běží v **C++ (Arduino framework)**,
- logika systému a UI běží v **Lua skriptech na SD kartě**.

## ✨ Funkce

- 🚀 **Rychlý boot proces** s POST a kontrolou SD karty
- 🧠 **Integrovaný Lua VM (5.4)** pro dynamické skriptování
- 🌍 **Dvojjazyčné UI** (čeština/angličtina) s přepínáním za běhu
- 📶 **Pokročilý Wi-Fi manager** (scan, připojení, AP režim, diagnostika)
- 🔌 **GPIO manager** (digitální I/O, PWM, ADC)
- 💻 **CMD konzole** s praktickými systémovými příkazy
- 🛡️ **Thread-safe Lua C API** díky mutex synchronizaci
- 💾 **SD-first architektura** pro skripty a konfiguraci

## 📸 Screenshoty

_Screenshoty budou doplněny brzy..._

## ⚡ Rychlý start

1. Nainstaluj [PlatformIO](https://platformio.org/) (VS Code extension nebo CLI).
2. Naklonuj repozitář:
   ```bash
   git clone https://github.com/Okurka1/esp-os-lua.git
   cd esp-os-lua
   ```
3. Zkopíruj `sd_card_files/ESP-OS/` do kořene FAT32 SD karty.
4. Přelož a nahraj firmware:
   ```bash
   pio run -t upload
   ```
5. Otevři serial monitor:
   ```bash
   pio device monitor -b 115200
   ```

Podrobný postup je v [INSTALL.md](INSTALL.md).

## 📚 Dokumentace

- [INSTALL.md](INSTALL.md) — detailní instalace a první spuštění
- [CHANGELOG.md](CHANGELOG.md) — historie verzí (v0.0.1 → v0.0.3.1)
- [CONTRIBUTING.md](CONTRIBUTING.md) — jak přispívat
- [README.md](README.md) — hlavní anglická dokumentace
- `sd_card_files/ESP-OS/` — runtime Lua systémové soubory

## 🏗️ Architektura

```text
+-------------------------------+
|        ESP32 Firmware         |
|   (C++ / Arduino Framework)   |
|  - Bootloader + POST          |
|  - Host pro Lua VM            |
|  - Lua C API (wifi/gpio/sd)   |
+---------------+---------------+
                |
                v
+-------------------------------+
|       SD karta (FAT32)        |
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

## 🗺️ Roadmapa

- ✅ **v0.0.1**: Základní boot, Lua runtime, core moduly
- ✅ **v0.0.2**: Rozšíření Wi-Fi a SD části
- ✅ **v0.0.3**: GPIO Manager, CMD Console, UX vylepšení
- ✅ **v0.0.3.1**: Dvojjazyčnost + rozšířená Wi-Fi diagnostika
- 🔜 **v0.0.4**: Recovery mode a bezpečnější rollback
- 🔜 **v0.0.5**: Rozšířený TFT workflow a bohatší UI

## 🤝 Přispívání

Příspěvky jsou vítány. Než otevřeš pull request, projdi si [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 Licence

Projekt je licencovaný pod [MIT licencí](LICENSE).
