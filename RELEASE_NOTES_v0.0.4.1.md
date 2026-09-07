# 🚀 ESP-OS v0.0.4.1 - Release Notes

**Release Date:** August 26, 2026  
**Type:** Maintenance Release (Bug fixes + optimizations)

---

## 📋 What's New

### 🐛 Critical Bug Fixes (9 total)

1. **Memory leak in sd.list()** ⚠️ CRITICAL
   - File handles not properly closed during directory iteration
   - Led to gradual memory exhaustion
   - **Fix:** Explicit closure of all file handles

2. **Buffer overflow in serial input** ⚠️ HIGH
   - Unlimited user input size
   - Risk of crash when entering long text
   - **Fix:** 256B limit + audio-visual feedback (beep)

3. **Race condition in bootloader** ⚠️ MEDIUM
   - String without allocation caused heap fragmentation
   - **Fix:** Buffer pre-allocation

4. **Duplicate code** ⚠️ LOW
   - ScopedLuaLock duplicated in 5 files
   - **Fix:** Shared header lua_helpers.h

5. **Unlimited sd.list()** ⚠️ MEDIUM
   - Possible infinite loop with large directories
   - **Fix:** 200 entries limit

6. **Cursor position bug in menu prompts** ⚠️ LOW
   - Blinking cursor overwrites menu text
   - Caused by incorrect carriage return placement
   - **Fix:** Add `\r` only when text ends with `\n`

7. **Critical crash in serial.print()** ⚠️ CRITICAL
   - System abort when accessing menu items
   - Race condition: Lua stack access before mutex lock
   - **Fix:** Proper mutex locking order + safe string access with `luaL_checklstring()`

8. **Systemic race conditions in Lua C API** ⚠️ CRITICAL
   - ALL Lua API functions had race conditions (15+ functions)
   - Caused memory corruption, crashes, and SD card disconnects
   - **Fix:** Comprehensive audit - mutex lock FIRST in all functions before any Lua stack access

9. **Terminal "not enough memory" error** ⚠️ HIGH
   - Terminal module couldn't load due to insufficient RAM
   - Large module (456 lines) + other modules not freed
   - **Fix:** Aggressive GC cleanup before terminal + explicit module freeing after use

---

### ⚡ Performance Improvements

| Optimization | RAM Saved | Flash Saved |
|--------------|-----------|-------------|
| String buffer tuning | ~200B | - |
| ScopedLuaLock deduplication | ~500B | ~1.5KB |
| **Aggressive module lifecycle management** | ~20-30KB | - |
| Mutex timeout increased (SD stability) | - | - |
| **TOTAL** | **~25-30KB** | **~1.5KB** |

**Key improvement:** Modules now explicitly freed after use - prevents RAM fragmentation!

---

### 🎨 New Features

#### **ANSI Color Toggle**

Support for terminals without ANSI escape sequences!

**Usage:**

```bash
# In terminal
ansi on       # Enable colors
ansi off      # Disable colors
ansi          # Show current status
```

**In Settings:**
- New option: `[3] ANSI Colors [ON/OFF]`
- Toggle without restart
- Persistent configuration

**Fallback Modes:**
- Progress bar: `[====----] 50%` (ASCII instead of UTF-8 blocks)
- Status: `[OK]` / `[FAIL]` (instead of ✓/✗)
- All colors → plain text

---

## 🔧 Technical Changes

### New Files:
```
include/lua_helpers.h              # Shared ScopedLuaLock
docs/OPTIMIZATION_v0.0.4.1.md     # Optimization documentation
RELEASE_NOTES_v0.0.4.1.md         # This file
```

### Modified Files:
```
C++ Firmware (9 files):
  include/config.h
  src/main.cpp
  src/bootloader/bootloader_menu.cpp
  src/lua_api/*.cpp (all 5)

Lua Runtime (5 files):
  sd_card_files/ESP-OS/boot/init.lua
  sd_card_files/ESP-OS/config/system.lua
  sd_card_files/ESP-OS/system/ansi.lua
  sd_card_files/ESP-OS/system/settings.lua
  sd_card_files/ESP-OS/system/terminal.lua

Documentation (3 files):
  README.md
  CHANGELOG.md
  platformio.ini
```

---

## 📦 Installation

### For Existing Users:

1. **Backup current configuration**
   ```bash
   # Backup your SD card
   ```

2. **Upload new firmware**
   ```bash
   platformio run -t upload
   ```

3. **Update system.lua**
   ```lua
   config = {
     -- ...
     ansi_enabled = true  -- ADD THIS LINE
   }
   ```

4. **Restart device**

### For New Users:
See [INSTALL.md](INSTALL.md)

---

## 🧪 Testing

### ✅ Tests Performed:
- [x] Compilation without errors/warnings
- [x] Boot to Main OS
- [x] Boot to Recovery Mode
- [x] Bootloader menu (BOOT button)
- [x] Serial input overflow test (300+ characters)
- [x] sd.list() on large directory (100+ files)
- [x] ANSI toggle functionality
- [x] Settings persistence after restart
- [x] Resource manager auto-cleanup

### 🔬 Recommended Additional Tests:
- [ ] 24h stability test
- [ ] Serial input stress test (continuous)
- [ ] Memory leak profiling (sd.list() 1000x)
- [ ] WiFi reconnect stability

---

## ⚠️ Breaking Changes

**NONE** - Version 0.0.4.1 is fully backward compatible with 0.0.4.

Only **recommendation**: Add `ansi_enabled = true` to `system.lua` to use the new feature.

---

## 🐛 Known Issues

1. **PlatformIO command not found** in some PowerShell environments
   - Workaround: Use VS Code integrated terminal
   
2. **UTF-8 characters in PuTTY** require proper configuration
   - Settings → Translation → UTF-8
   - Settings → Appearance → Font → "Consolas"

---

## 🔮 Coming in v0.0.5

- **OTA Updates** - Firmware updates over WiFi
- **Web Interface** - Management via web browser
- **Bytecode caching** - Faster Lua script loading
- **String pool** - Additional RAM optimization
- **WiFi buffer tuning** - Network buffer optimization

---

## 👥 Contributors

Thanks to everyone who helped with testing and bug reporting!

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

## 📞 Support

- **Issues:** GitHub Issues
- **Documentation:** [docs/](docs/)
- **API Reference:** [docs/LUA_API.md](docs/LUA_API.md)
- **Bootloader:** [docs/BOOTLOADER.md](docs/BOOTLOADER.md)
- **Optimizations:** [docs/OPTIMIZATION_v0.0.4.1.md](docs/OPTIMIZATION_v0.0.4.1.md)

---

**Happy upgrading! 🎉**
