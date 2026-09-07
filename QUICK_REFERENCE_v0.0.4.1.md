# 📖 ESP-OS v0.0.4.1 - Quick Reference

## 🎨 ANSI Toggle (NEW!)

### Terminal:
```bash
ansi           # Show status
ansi on        # Enable colors
ansi off       # Disable colors
```

### Settings:
```
Settings → [3] ANSI Colors [ON/OFF]
```

### Config (system.lua):
```lua
config = {
    ansi_enabled = true  -- true/false
}
```

---

## 🐛 Fixed Bugs in 0.0.4.1

| Bug | Impact | Status |
|-----|--------|--------|
| Memory leak in sd.list() | HIGH | ✅ FIXED |
| Buffer overflow serial | HIGH | ✅ FIXED |
| Race condition bootloader | MED | ✅ FIXED |
| Duplicate ScopedLuaLock | LOW | ✅ FIXED |
| Unlimited sd.list() | MED | ✅ FIXED |
| Cursor position in menu | LOW | ✅ FIXED |
| Critical crash in serial.print() | CRITICAL | ✅ FIXED |

---

## ⚡ RAM Optimization

- **~700B RAM saved**
- **~1.5KB Flash saved**

### Memory Limits:
```cpp
MAX_LUA_SCRIPT_SIZE    = 64 KB
MAX_SD_READ_SIZE       = 32 KB
MAX_SERIAL_INPUT_SIZE  = 256 B
```

---

## 🔧 For Developers

### New shared header:
```cpp
#include "lua_helpers.h"  // Instead of local ScopedLuaLock
```

### Memory constants:
```cpp
Config::MAX_LUA_SCRIPT_SIZE
Config::MAX_SD_READ_SIZE
Config::MAX_SERIAL_INPUT_SIZE
```

---

## 📁 Modified Files

### C++:
- `include/lua_helpers.h` (NEW)
- `include/config.h`
- `src/main.cpp`
- `src/bootloader/bootloader_menu.cpp`
- `src/lua_api/*.cpp` (all 5)

### Lua:
- `boot/init.lua`
- `config/system.lua`
- `system/ansi.lua`
- `system/settings.lua`
- `system/terminal.lua`

---

## 🧪 Test Checklist

- [x] Compilation
- [x] Boot Main OS
- [x] Boot Recovery
- [x] Bootloader menu
- [x] Serial overflow test
- [x] sd.list() stress
- [x] ANSI toggle
- [x] Persistence

---

## ⚠️ Breaking Changes

**NONE** - fully backward compatible with v0.0.4

---

## 📞 Quick Links

- [README](README.md)
- [CHANGELOG](CHANGELOG.md)
- [INSTALL](INSTALL.md)
- [Lua API](docs/LUA_API.md)
- [Bootloader](docs/BOOTLOADER.md)
- [Optimizations](docs/OPTIMIZATION_v0.0.4.1.md)

---

**Version:** 0.0.4.1 | **Date:** 2026-08-26
