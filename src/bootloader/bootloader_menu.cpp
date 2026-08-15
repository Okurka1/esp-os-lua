#include "bootloader_menu.h"

#include <SD.h>
#include <SPI.h>

#include "config.h"

namespace Bootloader {

// Pin pro BOOT tlačítko (GPIO0 na většině ESP32 boardů)
static constexpr uint8_t BOOT_BUTTON_PIN = 0;

// Cesta ke konfiguračnímu souboru bootloaderu
static constexpr const char* BOOT_CONFIG_PATH = "/bootloader.cfg";

bool loadBootConfig(BootConfig& config) {
  if (!SD.exists(BOOT_CONFIG_PATH)) {
    Serial.println(F("[BOOTLOADER] Konfigurace nenalezena, používám výchozí."));
    config = DEFAULT_BOOT_CONFIG;
    return false;
  }

  File file = SD.open(BOOT_CONFIG_PATH, FILE_READ);
  if (!file) {
    Serial.println(F("[BOOTLOADER][ERROR] Nelze otevřít konfiguraci."));
    config = DEFAULT_BOOT_CONFIG;
    return false;
  }

  size_t bytesRead = file.read((uint8_t*)&config, sizeof(BootConfig));
  file.close();

  if (bytesRead != sizeof(BootConfig)) {
    Serial.println(F("[BOOTLOADER][WARN] Neplatná konfigurace, používám výchozí."));
    config = DEFAULT_BOOT_CONFIG;
    return false;
  }

  Serial.println(F("[BOOTLOADER] Konfigurace načtena."));
  return true;
}

bool saveBootConfig(const BootConfig& config) {
  File file = SD.open(BOOT_CONFIG_PATH, FILE_WRITE);
  if (!file) {
    Serial.println(F("[BOOTLOADER][ERROR] Nelze uložit konfiguraci."));
    return false;
  }

  size_t bytesWritten = file.write((const uint8_t*)&config, sizeof(BootConfig));
  file.close();

  if (bytesWritten != sizeof(BootConfig)) {
    Serial.println(F("[BOOTLOADER][ERROR] Chyba při zápisu konfigurace."));
    return false;
  }

  Serial.println(F("[BOOTLOADER] Konfigurace uložena."));
  return true;
}

bool isBootButtonPressed() {
  pinMode(BOOT_BUTTON_PIN, INPUT_PULLUP);
  delay(10);
  return digitalRead(BOOT_BUTTON_PIN) == LOW;
}

void printBootMenu(const BootConfig& config) {
  Serial.println(F("\r\n╔════════════════════════════════════════╗\r"));
  Serial.println(F("║          BOOTLOADER v0.0.2             ║\r"));
  Serial.println(F("╠════════════════════════════════════════╣\r"));
  Serial.println(F("║  [1] Boot Main OS                      ║\r"));
  Serial.println(F("║  [2] Boot Recovery Mode                ║\r"));
  Serial.println(F("║  [3] Boot Alternative OS               ║\r"));
  Serial.println(F("║  [4] Bootloader Settings               ║\r"));
  Serial.println(F("║  [5] System Information                ║\r"));
  Serial.println(F("╚════════════════════════════════════════╝\r"));
  
  Serial.printf("\r\n[INFO] Výchozí volba: ");
  switch (config.default_boot) {
    case 0: Serial.println("Main OS\r"); break;
    case 1: Serial.println("Recovery\r"); break;
    case 2: Serial.println("Alternative OS\r"); break;
  }
  
  if (config.boot_timeout > 0) {
    Serial.printf("[INFO] Automatický boot za %d sekund...\r\n", config.boot_timeout);
  }
  
  Serial.print(F("\r\nVyberte volbu [1-5]: "));
}

void printSystemInfo() {
  Serial.println(F("\r\n╔════════════════════════════════════════╗\r"));
  Serial.println(F("║        System Information              ║\r"));
  Serial.println(F("╠════════════════════════════════════════╣\r"));
  
  Serial.printf("║ Chip: %-32s ║\r\n", ESP.getChipModel());
  Serial.printf("║ Cores: %-31d ║\r\n", ESP.getChipCores());
  Serial.printf("║ CPU Freq: %d MHz                    ║\r\n", ESP.getCpuFreqMHz());
  Serial.printf("║ Flash: %.2f MB                      ║\r\n", ESP.getFlashChipSize() / (1024.0 * 1024.0));
  Serial.printf("║ Free Heap: %.2f KB                  ║\r\n", ESP.getFreeHeap() / 1024.0);
  Serial.printf("║ SD Card: %.2f MB                    ║\r\n", SD.cardSize() / (1024.0 * 1024.0));
  
  Serial.println(F("╚════════════════════════════════════════╝\r"));
  Serial.println(F("\r\nStiskněte libovolnou klávesu...\r"));
  
  while (!Serial.available()) {
    delay(10);
  }
  while (Serial.available()) {
    Serial.read();
  }
}

void showBootloaderSettings(BootConfig& config) {
  while (true) {
    Serial.println(F("\r\n╔════════════════════════════════════════╗\r"));
    Serial.println(F("║      Bootloader Settings               ║\r"));
    Serial.println(F("╠════════════════════════════════════════╣\r"));
    Serial.printf("║ [1] Main OS Path:                      ║\r\n");
    Serial.printf("║     %-34s ║\r\n", config.os_path);
    Serial.printf("║ [2] Recovery Path:                     ║\r\n");
    Serial.printf("║     %-34s ║\r\n", config.recovery_path);
    Serial.printf("║ [3] Alt OS Path:                       ║\r\n");
    Serial.printf("║     %-34s ║\r\n", config.alt_os_path);
    Serial.printf("║ [4] Default Boot: %-20s ║\r\n", 
                  config.default_boot == 0 ? "Main OS" : 
                  config.default_boot == 1 ? "Recovery" : "Alt OS");
    Serial.printf("║ [5] Boot Timeout: %-3d sec             ║\r\n", config.boot_timeout);
    Serial.printf("║ [6] Auto Recovery: %-19s ║\r\n", config.auto_recovery ? "Enabled" : "Disabled");
    Serial.printf("║ [7] Show Menu on Boot: %-15s ║\r\n", config.show_menu_on_boot ? "Yes" : "No");
    Serial.printf("║ [8] Boot Count: %-22lu ║\r\n", config.boot_count);
    Serial.println(F("║                                        ║\r"));
    Serial.println(F("║ [S] Save & Exit                        ║\r"));
    Serial.println(F("║ [B] Back (bez uložení)                 ║\r"));
    Serial.println(F("╚════════════════════════════════════════╝\r"));
    Serial.print(F("\r\nVyberte volbu: "));

    while (!Serial.available()) {
      delay(10);
    }
    
    char choice = Serial.read();
    while (Serial.available()) Serial.read(); // Vyčisti buffer
    Serial.println(choice);

    if (choice == 's' || choice == 'S') {
      if (saveBootConfig(config)) {
        Serial.println(F("\r\n[SUCCESS] Nastavení uloženo!\r"));
      } else {
        Serial.println(F("\r\n[ERROR] Chyba při ukládání!\r"));
      }
      delay(1500);
      return;
    } else if (choice == 'b' || choice == 'B') {
      return;
    } else if (choice == '4') {
      Serial.print(F("\r\nVýchozí boot [0=Main, 1=Recovery, 2=Alt]: "));
      while (!Serial.available()) delay(10);
      char opt = Serial.read();
      while (Serial.available()) Serial.read();
      Serial.println(opt);
      if (opt >= '0' && opt <= '2') {
        config.default_boot = opt - '0';
      }
    } else if (choice == '5') {
      Serial.print(F("\r\nTimeout (0-60 sec): "));
      String input = "";
      while (true) {
        if (Serial.available()) {
          char c = Serial.read();
          if (c == '\n' || c == '\r') {
            if (input.length() > 0) break;
          } else {
            input += c;
            Serial.print(c);
          }
        }
        delay(10);
      }
      Serial.println();
      int timeout = input.toInt();
      if (timeout >= 0 && timeout <= 60) {
        config.boot_timeout = timeout;
      }
    } else if (choice == '6') {
      config.auto_recovery = !config.auto_recovery;
    } else if (choice == '7') {
      config.show_menu_on_boot = !config.show_menu_on_boot;
    }
  }
}

int showBootloaderMenu(const BootConfig& config) {
  printBootMenu(config);

  // Timeout handling - pouze pokud je nastaven
  unsigned long startTime = millis();
  int choice = -1;
  bool timeoutEnabled = (config.boot_timeout > 0);

  while (true) {
    // Kontrola timeoutu pouze pokud je povolen
    if (timeoutEnabled) {
      unsigned long elapsed = (millis() - startTime) / 1000;
      if (elapsed >= config.boot_timeout) {
        Serial.printf("\r\n[BOOTLOADER] Timeout - spouštím výchozí volbu (%d)\r\n", config.default_boot);
        return config.default_boot;
      }
    }

    // Kontrola vstupu
    if (Serial.available() > 0) {
      char input = Serial.read();
      while (Serial.available()) Serial.read(); // Vyčisti buffer
      Serial.println(input);

      if (input >= '1' && input <= '5') {
        choice = input - '1';
        break;
      } else {
        Serial.print(F("\r\n[ERROR] Neplatná volba! Zkuste znovu: "));
      }
    }

    delay(100);
  }

  return choice;
}

}  // namespace Bootloader
