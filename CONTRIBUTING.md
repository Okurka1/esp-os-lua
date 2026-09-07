# Contributing to ESP-OS

Thanks for your interest in improving ESP-OS! 🎉

## Development Setup

1. Fork or clone the repository.
2. Install PlatformIO (VS Code extension or CLI).
3. Connect ESP32 board and prepare SD card with `sd_card_files/ESP-OS/`.
4. Build and upload:
   ```bash
   pio run -t upload
   ```
5. Monitor logs:
   ```bash
   pio device monitor -b 115200
   ```

## Branching Guidelines

- Create a feature branch from `main`:
  ```bash
  git checkout -b feature/short-description
  ```
- Keep commits focused and small.
- Use clear commit messages.

## Coding Standards

### C++ (Firmware)
- Keep functions small and testable.
- Use clear error handling for hardware/IO calls.
- Keep Lua C API bindings thread-safe.

### Lua (Runtime Scripts)
- Keep menu/UI text translatable.
- Validate SD/Wi-Fi calls with fallback handling.
- Prefer modular files in `/ESP-OS/system`.

## Pull Request Checklist

Before opening PR:
- [ ] Build succeeds (`pio run`)
- [ ] Upload succeeds on hardware (`pio run -t upload`)
- [ ] Serial boot is clean (no blocking errors)
- [ ] README/INSTALL/CHANGELOG updated if needed
- [ ] No debug leftovers

## Reporting Issues

Please include:
- ESP32 board model
- ESP-OS version/tag
- Steps to reproduce
- Serial log output
- SD card type/format info

## Feature Requests

Open an issue with:
- Problem statement
- Proposed solution
- Impact on RAM/flash/runtime

Thanks for contributing! 💚
