# Changelog

All notable changes to this project are documented in this file.

## [v0.0.4] - 2026-08
### Added
- **Advanced Bootloader (v0.0.2)** - Interactive menu with dual-boot support
- **Recovery Mode** - Minimal OS for system recovery and diagnostics
- **Dual-boot system** - Support for Main OS, Recovery, and Alternative OS
- **Persistent reboot flags** - NVS-based flags for `reboot recovery` and `reboot bootloader`
- **Auto-recovery** - Automatic recovery mode activation on boot failure
- **Boot diagnostics** - Boot count, timestamps, and configuration persistence
- **BOOT button detection** - Manual bootloader menu access
- **Terminal commands** - `reboot recovery`, `reboot bootloader`, `bootloader` info
- **CMD Console `ls` command** - Full implementation with directory listing support
- **New Lua API function `sd.list(path)`** - Lists files and directories on SD card
- **New Lua API function `system.cpuFreq()`** - Returns CPU frequency in MHz
- **Complete Lua API documentation** - New `docs/LUA_API.md` with full reference
- **Bootloader documentation** - New `docs/BOOTLOADER.md` with complete guide
- **Memory optimization** - File size limits (64KB for Lua scripts, 32KB for sd.read())
- **Language restart feature** - Device automatically restarts after language change
- **ANSI color support** - Better terminal UX with colors

### Improved
- Memory safety with file size limits to prevent heap exhaustion
- Better error handling in file operations
- Documentation structure with dedicated API reference
- Serial output formatting with proper CR+LF for PuTTY compatibility
- Boot process with unified POST, BOOT, and KERNEL messages
- Bootloader timeout (0 = infinite, waits for user)

### Fixed
- TODO item in `cmd_console.lua` - `ls` command now fully functional
- Potential memory issues with large file reads
- PuTTY display issues with misaligned text
- Missing `system.cpuFreq()` function in Recovery mode
- Duplicate boot messages

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
