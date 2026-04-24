# Changelog

All notable changes to this project are documented in this file.

## [v0.0.3.1] - 2026-04
### Added
- Dual-language system (Czech/English) with runtime switch in Settings.
- Language files and translation loader (`/ESP-OS/lang/`).
- Extended Wi-Fi diagnostics APIs: gateway, DNS, channel, PHY mode.
- Better Wi-Fi info screen and translated UI strings.

### Improved
- Main menu and Settings UX.
- Documentation and release readiness for public GitHub publishing.

## [v0.0.3] - 2026-04
### Added
- CMD Console (`Q` in main menu) with core system commands.
- GPIO Manager with Digital, PWM and ADC workflows.
- `system.shutdown()` support (deep sleep).

### Improved
- System Info screen now waits for key input before returning.
- Lazy module loading for lower RAM usage.
- SD availability checks in critical runtime flows.

## [v0.0.2] - 2026-03
### Added
- Wi-Fi Manager with scanning, connect/disconnect, AP mode and saved networks.
- Wi-Fi config persistence on SD card (`/ESP-OS/config/wifi.lua`).
- Better serial input handling for forms and passwords.

### Improved
- Boot/runtime stability around Wi-Fi and SD operations.

## [v0.0.1] - 2026-03
### Added
- Initial ESP-OS bootloader flow with POST and SD mount checks.
- Embedded Lua 5.4 integration in ESP32 firmware.
- Core Lua C APIs (`serial`, `sd`, `wifi`, `gpio`, `system`).
- Basic text UI, kernel loop and menu system.

---

[Version tags are expected to be created in Git as `v0.0.x` tags.]
