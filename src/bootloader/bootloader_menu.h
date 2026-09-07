#pragma once

#include <Arduino.h>

namespace Bootloader {

// Bootloader konfigurace
struct BootConfig {
  char os_path[64];           // Cesta k hlavnímu OS
  char recovery_path[64];     // Cesta k recovery OS
  char alt_os_path[64];       // Cesta k alternativnímu OS (dual-boot)
  uint8_t default_boot;       // 0=main OS, 1=recovery, 2=alt OS
  uint8_t boot_timeout;       // Timeout v sekundách (0=žádný timeout)
  bool auto_recovery;         // Automaticky spustit recovery při chybě
  bool show_menu_on_boot;     // Zobrazit menu při každém startu
  uint32_t boot_count;        // Počet bootů (pro diagnostiku)
  uint32_t last_boot_time;    // Timestamp posledního bootu
};

// Výchozí konfigurace
const BootConfig DEFAULT_BOOT_CONFIG = {
  "/ESP-OS/boot/init.lua",           // os_path
  "/ESP-OS-Recovery/boot/init.lua",  // recovery_path
  "/ESP-OS-Alt/boot/init.lua",       // alt_os_path
  0,                                  // default_boot (main OS)
  0,                                  // boot_timeout (0 = nekonečný)
  true,                               // auto_recovery
  false,                              // show_menu_on_boot
  0,                                  // boot_count
  0                                   // last_boot_time
};

// Načte bootloader konfiguraci ze souboru
bool loadBootConfig(BootConfig& config);

// Uloží bootloader konfiguraci do souboru
bool saveBootConfig(const BootConfig& config);

// Zobrazí bootloader menu a vrátí vybranou volbu
// Vrací: 0=main OS, 1=recovery, 2=alt OS, 3=settings, -1=chyba
int showBootloaderMenu(const BootConfig& config);

// Zkontroluje, zda je stisknuto BOOT tlačítko
bool isBootButtonPressed();

// Zobrazí bootloader nastavení a umožní jejich změnu
void showBootloaderSettings(BootConfig& config);

// Zobrazí systémové informace
void printSystemInfo();

}  // namespace Bootloader
