# ESP-OS v0.0.4.1 - Optimizations and Fixes

This document describes all optimizations and fixes made in version 0.0.4.1.

## 🐛 Fixed Bugs

### 1. Memory leak in lua_sd_list()
**Problem:** File handles were not properly closed during iteration.  
**Solution:** Explicit entry.close() before loading next + dir.close() at the end.  
**Impact:** Eliminated memory leak with frequent sd.list() calls.

### 2. Buffer overflow risk in serial input
**Problem:** Unlimited input size - only 64B reservation without limit check.  
**Solution:** 256B limit + length check + beep when limit reached.  
**Impact:** Protection against buffer overflow and crash.

### 3. Duplicate ScopedLuaLock code
**Problem:** Same class in 5 files (150 lines of duplication).  
**Solution:** Shared lua_helpers.h header.  
**Impact:** -120 lines, better maintenance, smaller binary.

### 4. Cursor position bug in menu prompts
**Problem:** Blinking cursor overwrites menu text after prompt.  
**Solution:** Add `\r` (carriage return) only when text ends with `\n`.  
**Impact:** Fixed UI glitch, proper cursor positioning in all menus.

### 5. Critical crash in serial.print()
**Problem:** System abort/crash when accessing menu items - race condition with Lua stack access before mutex lock.  
**Solution:** Proper locking order (mutex first) + use `luaL_checklstring()` for safe string access with length.  
**Impact:** Eliminated critical crash, improved thread safety and performance.

---

## ⚡ RAM Optimization

- Centralized memory limits in Config namespace
- Optimized String buffers (removed +16B padding)
- Savings: ~700B RAM, ~1.5KB Flash

---

## 🎨 ANSI Toggle

- New config parameter: ansi_enabled
- Terminal command: ansi on/off
- Settings menu: [3] ANSI Colors
- ASCII fallback for terminals without ANSI support

---

**Version:** 0.0.4.1  
**Date:** 2026-08-26
