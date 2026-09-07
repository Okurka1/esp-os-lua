# ESP-OS Bootloader v0.0.2 Documentation

## Overview

ESP-OS includes an advanced bootloader system (v0.0.2) with support for:
- **Bootloader Menu** - Interactive menu for OS selection
- **Recovery Mode** - Minimal system for OS recovery
- **Dual-Boot** - Ability to run alternative OS
- **Auto-Recovery** - Automatic recovery activation on failure

## SD Card Structure

```
/
├── bootloader.cfg              # Bootloader configuration
├── ESP-OS/                     # Main operating system
│   └── boot/
│       └── init.lua
├── ESP-OS-Recovery/            # Recovery system
│   └── boot/
│       └── init.lua
└── ESP-OS-Alt/                 # Alternative OS (optional)
    └── boot/
        └── init.lua
```

## Entering Bootloader Menu

The bootloader menu can be accessed in several ways:

### 1. Press BOOT button during startup
- Hold the BOOT button (GPIO0) while powering on the device
- Menu will appear automatically

### 2. From terminal
```
reboot bootloader    # Restart with bootloader entry instruction
```

### 3. Automatically on error
- If main OS fails and auto-recovery is enabled
- If boot script is not found

### 4. Configuration setting
- In bootloader settings, enable "Show Menu on Boot"
- Menu will appear on every startup

## Bootloader Menu

```
╔════════════════════════════════════════╗
║          BOOTLOADER v0.0.2             ║
╠════════════════════════════════════════╣
║  [1] Boot Main OS                      ║
║  [2] Boot Recovery Mode                ║
║  [3] Boot Alternative OS               ║
║  [4] Bootloader Settings               ║
║  [5] System Information                ║
╚════════════════════════════════════════╝
```

### Menu options:

1. **Boot Main OS** - Start the main operating system
2. **Boot Recovery Mode** - Start recovery system for repair
3. **Boot Alternative OS** - Start alternative OS (dual-boot)
4. **Bootloader Settings** - Bootloader configuration
5. **System Information** - Display system information

## Bootloader Settings

### Available settings:

1. **Main OS Path** - Path to main OS boot script
   - Default: `/ESP-OS/boot/init.lua`

2. **Recovery Path** - Path to recovery boot script
   - Default: `/ESP-OS-Recovery/boot/init.lua`

3. **Alt OS Path** - Path to alternative OS
   - Default: `/ESP-OS-Alt/boot/init.lua`

4. **Default Boot** - Default system for boot
   - 0 = Main OS
   - 1 = Recovery
   - 2 = Alternative OS

5. **Boot Timeout** - Timeout for automatic boot (0-60 seconds)
   - 0 = no timeout, waits for selection
   - Default: 0 seconds (infinite)

6. **Auto Recovery** - Automatically start recovery on error
   - Enabled/Disabled
   - Default: Enabled

7. **Show Menu on Boot** - Display menu on every startup
   - Yes/No
   - Default: No

8. **Boot Count** - Number of boots (read-only)

## Recovery Mode

Recovery mode is a minimal system designed for:
- Checking main OS integrity
- Displaying files on SD card
- System diagnostics
- Restarting to main OS

### Recovery Menu:

```
╔════════════════════════════════════════╗
║        Recovery Menu                   ║
╠════════════════════════════════════════╣
║  [1] Show files on SD card             ║
║  [2] Check main OS                     ║
║  [3] System information                ║
║  [4] Restart to main OS                ║
║  [5] Restart device                    ║
╚════════════════════════════════════════╝
```

### Activating Recovery Mode:

1. **Automatically on error** - If main OS fails
2. **From bootloader menu** - Option [2]
3. **From terminal**:
   ```
   reboot recovery
   ```
4. **BOOT button during startup** - Select Recovery in menu

## Terminal Commands

### Reboot commands:
```bash
reboot              # Normal restart
reboot recovery     # Restart to Recovery Mode
reboot bootloader   # Restart to Bootloader Menu
```

### Bootloader info:
```bash
bootloader          # Display bootloader commands and info
```

## Bootloader Configuration

Configuration is stored in `/bootloader.cfg` file on SD card.

### Default configuration:
```
os_path: /ESP-OS/boot/init.lua
recovery_path: /ESP-OS-Recovery/boot/init.lua
alt_os_path: /ESP-OS-Alt/boot/init.lua
default_boot: 0 (Main OS)
boot_timeout: 0 seconds (infinite)
auto_recovery: true
show_menu_on_boot: false
```

## Dual-Boot System

To set up dual-boot:

1. Create `/ESP-OS-Alt/` folder on SD card
2. Copy complete OS to this folder
3. In bootloader settings, set path to alternative OS
4. During startup, select [3] Boot Alternative OS

## Security Features

### Auto-Recovery
- Automatically activates recovery mode on main OS failure
- Checks existence of critical files
- Can be disabled in bootloader settings

### Boot Count
- Tracks number of system boots
- Useful for diagnosing repeated restart issues

### Timeout
- Prevents lockup when no input is available
- Automatically starts default OS after timeout
- 0 = infinite timeout (waits for user)

## Troubleshooting

### SD card not found
- Bootloader displays error message
- Offers entry to settings (BOOT button)
- Waits 10 seconds for action

### Boot script not found
- Automatically activates recovery mode (if enabled)
- Displays error message with path to missing file

### Recovery also failed
- System stops with error message
- Restart and SD card check required

## Usage Examples

### Scenario 1: Corrupted main OS
1. System automatically starts recovery mode
2. In recovery, select [2] to check OS
3. Identify missing files
4. Fix files via SD card reader
5. Select [4] to restart to main OS

### Scenario 2: Testing new OS version
1. Copy new version to `/ESP-OS-Alt/`
2. Restart and press BOOT button
3. Select [3] Boot Alternative OS
4. Test new version
5. If it works, copy to `/ESP-OS/`

### Scenario 3: Changing default OS
1. Enter bootloader menu (BOOT button)
2. Select [4] Bootloader Settings
3. Change "Default Boot" to desired OS
4. Press [S] to save
5. Restart automatically starts new default OS

## Technical Details

### BOOT Button
- GPIO0 (standard on ESP32 boards)
- Active in LOW state (pull-up resistor)
- Detection during startup and POST

### Configuration
- Binary format for fast loading
- Size: sizeof(BootConfig) = ~200 bytes
- Automatic creation of default configuration

### Timeout Mechanism
- Implemented in C++ for precision
- Independent of Lua runtime
- Check every 100ms

## Future Extensions

Planned features:
- [ ] Boot script encryption
- [ ] Support for more than 3 OS
- [ ] Bootloader password
- [ ] Automatic backups before updates
- [ ] OTA updates via WiFi
- [ ] Boot log for diagnostics

---

*For Czech version of this documentation, see BOOTLOADER_cs.md*
