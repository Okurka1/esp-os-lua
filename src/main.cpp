#include <Arduino.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h>
#include <Preferences.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
}

#include "bootloader/post.h"
#include "bootloader/bootloader_menu.h"
#include "config.h"
#include "lua_api/lua_gpio.h"
#include "lua_api/lua_sd.h"
#include "lua_api/lua_serial.h"
#include "lua_api/lua_system.h"
#include "lua_api/lua_wifi.h"

SemaphoreHandle_t g_luaMutex = nullptr;
static lua_State* g_luaState = nullptr;

namespace {

String readFileFromSD(const char* path, bool* ok = nullptr) {
  File file = SD.open(path, FILE_READ);
  if (!file) {
    if (ok) {
      *ok = false;
    }
    return "";
  }

  size_t fileSize = file.size();
  
  if (fileSize > Config::MAX_LUA_SCRIPT_SIZE) {
    Serial.printf("[WARN] File %s is too large (%u bytes), truncating to %u bytes\n", 
                  path, fileSize, Config::MAX_LUA_SCRIPT_SIZE);
    fileSize = Config::MAX_LUA_SCRIPT_SIZE;
  }

  String content;
  content.reserve(fileSize);
  
  size_t bytesRead = 0;
  while (file.available() && bytesRead < fileSize) {
    content += static_cast<char>(file.read());
    bytesRead++;
  }
  file.close();

  if (ok) {
    *ok = true;
  }
  return content;
}

bool executeLuaScriptFromFile(lua_State* L, const char* path) {
  bool readOk = false;
  const String source = readFileFromSD(path, &readOk);
  if (!readOk) {
    Serial.printf("[LUA][ERROR] Nelze otevřít script: %s\n", path);
    return false;
  }

  // Načtení a spuštění Lua skriptu.
  const int loadStatus = luaL_loadbuffer(L, source.c_str(), source.length(), path);
  if (loadStatus != LUA_OK) {
    Serial.printf("[LUA][ERROR] Chyba kompilace %s: %s\n", path, lua_tostring(L, -1));
    lua_pop(L, 1);
    return false;
  }

  const int runStatus = lua_pcall(L, 0, LUA_MULTRET, 0);
  if (runStatus != LUA_OK) {
    Serial.printf("[LUA][ERROR] Runtime chyba %s: %s\n", path, lua_tostring(L, -1));
    lua_pop(L, 1);
    return false;
  }

  // Boot script návratové hodnoty zde nevyužíváme.
  lua_settop(L, 0);
  return true;
}

int lua_dofile_from_sd(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);

  bool readOk = false;
  const String source = readFileFromSD(path, &readOk);
  if (!readOk) {
    return luaL_error(L, "dofile: nelze otevřít soubor %s", path);
  }

  const int loadStatus = luaL_loadbuffer(L, source.c_str(), source.length(), path);
  if (loadStatus != LUA_OK) {
    return lua_error(L);
  }

  if (lua_pcall(L, 0, LUA_MULTRET, 0) != LUA_OK) {
    return lua_error(L);
  }

  // Odstraníme vstupní argument path, aby na stacku zůstaly jen návratové hodnoty skriptu.
  lua_remove(L, 1);
  return lua_gettop(L);
}

void registerLuaModules(lua_State* L) {
  register_lua_serial(L);
  register_lua_gpio(L);
  register_lua_wifi(L);
  register_lua_sd(L);
  register_lua_system(L);

  // Přepíšeme dofile tak, aby četl soubory ze SD karty.
  lua_pushcfunction(L, lua_dofile_from_sd);
  lua_setglobal(L, "dofile");
}

bool initLua() {
  g_luaState = luaL_newstate();
  if (!g_luaState) {
    Serial.println(F("[LUA][FATAL] Nelze vytvořit Lua VM."));
    return false;
  }

  luaL_openlibs(g_luaState);
  registerLuaModules(g_luaState);

  Serial.println(F("[LUA] Lua VM inicializována."));
  return true;
}

}  // namespace

void setup() {
  Serial.begin(Config::SERIAL_BAUD);
  delay(200);
  Serial.println(F("\r\n╔════════════════════════════════════════╗\r"));
  Serial.println(F("║          BOOTLOADER v0.0.2             ║\r"));
  Serial.println(F("╚════════════════════════════════════════╝\r"));

  g_luaMutex = xSemaphoreCreateMutex();
  if (!g_luaMutex) {
    Serial.println(F("\r\n[FATAL] Nelze vytvořit Lua mutex.\r"));
    while (true) {
      delay(1000);
    }
  }

  // POST - kontrola SD karty
  Serial.println(F("\r\n[POST] Spouštím Power-On Self Test...\r"));
  bool sdAvailable = Bootloader::runPOST(Config::SD_CS_PIN);
  
  if (!sdAvailable) {
    Serial.println(F("\r\n[BOOTLOADER] SD karta či jiné paměťové zařízení nenalezeno!\r"));
    Serial.println(F("[BOOTLOADER] Možnosti:\r"));
    Serial.println(F("[BOOTLOADER]   - Stiskněte BOOT tlačítko pro zobrazení systémových informací\r"));
    Serial.println(F("[BOOTLOADER]   - Vložte SD kartu a stiskněte RESET pro restart\r"));
    
    // Čekej 10 sekund na stisk BOOT tlačítka
    unsigned long startWait = millis();
    while (millis() - startWait < 10000) {
      if (Bootloader::isBootButtonPressed()) {
        Serial.println(F("\r\n[BOOTLOADER] BOOT tlačítko detekováno...\r"));
        delay(500);
        
        // Zobraz systémové informace i bez SD karty
        Serial.println(F("\r\n╔════════════════════════════════════════╗\r"));
        Serial.println(F("║     System Information (No SD)         ║\r"));
        Serial.println(F("╠════════════════════════════════════════╣\r"));
        Serial.printf("║ Chip: %-32s ║\r\n", ESP.getChipModel());
        Serial.printf("║ Cores: %-31d ║\r\n", ESP.getChipCores());
        Serial.printf("║ CPU Freq: %lu MHz                   ║\r\n", ESP.getCpuFreqMHz());
        Serial.printf("║ Flash: %.2f MB                      ║\r\n", ESP.getFlashChipSize() / (1024.0 * 1024.0));
        Serial.printf("║ Free Heap: %.2f KB                  ║\r\n", ESP.getFreeHeap() / 1024.0);
        Serial.println(F("║ SD Card: NOT DETECTED                  ║\r"));
        Serial.println(F("╚════════════════════════════════════════╝\r"));
        
        Serial.println(F("\r\n[INFO] Vložte SD kartu a stiskněte RESET pro restart.\r"));
        while (true) {
          delay(1000);
        }
      }
      delay(100);
    }
    
    Serial.println(F("\r\n[FATAL] POST selhal - SD karta nenalezena. Boot zastaven.\r"));
    Serial.println(F("[INFO] Vložte SD kartu a restartujte zařízení.\r"));
    while (true) {
      delay(1000);
    }
  }

  // Ujistíme se, že SD je přimountována i po POST
  if (!SD.begin(Config::SD_CS_PIN)) {
    Serial.println(F("[FATAL] SD mount selhal po POST.\r"));
    while (true) {
      delay(1000);
    }
  }

  // Načti bootloader konfiguraci
  Bootloader::BootConfig bootConfig;
  Bootloader::loadBootConfig(bootConfig);
  
  // Inkrementuj boot count
  bootConfig.boot_count++;
  bootConfig.last_boot_time = millis();
  Bootloader::saveBootConfig(bootConfig);

  // Zkontroluj reboot flag z NVS (Preferences)
  Preferences prefs;
  prefs.begin("esp-os", false);
  uint8_t bootMode = prefs.getUChar("boot_mode", 0);
  prefs.putUChar("boot_mode", 0);  // Vyčisti flag pro příští boot
  prefs.end();

  // Zkontroluj, zda je stisknuto BOOT tlačítko nebo má být zobrazeno menu
  bool showMenu = bootConfig.show_menu_on_boot || Bootloader::isBootButtonPressed() || (bootMode == 2);
  
  const char* bootScriptPath = bootConfig.os_path;
  
  // Pokud je nastaven recovery mode flag, přeskoč menu a jdi rovnou do recovery
  if (bootMode == 1) {
    bootScriptPath = bootConfig.recovery_path;
    Serial.println(F("\r\n[BOOTLOADER] Restart do Recovery Mode požadován...\r"));
    showMenu = false;
  }
  
  if (showMenu) {
    Serial.println(F("\r\n[BOOTLOADER] Vstup do bootloader menu...\r"));
    delay(300);
    
    int menuChoice = Bootloader::showBootloaderMenu(bootConfig);
    
    switch (menuChoice) {
      case 0: // Main OS
        bootScriptPath = bootConfig.os_path;
        Serial.println(F("\r\n[BOOTLOADER] Spouštím Main OS...\r"));
        break;
      case 1: // Recovery
        bootScriptPath = bootConfig.recovery_path;
        Serial.println(F("\r\n[BOOTLOADER] Spouštím Recovery Mode...\r"));
        break;
      case 2: // Alt OS
        bootScriptPath = bootConfig.alt_os_path;
        Serial.println(F("\r\n[BOOTLOADER] Spouštím Alternative OS...\r"));
        break;
      case 3: // Settings
        Bootloader::showBootloaderSettings(bootConfig);
        // Po nastavení spusť výchozí OS
        bootScriptPath = bootConfig.os_path;
        Serial.println(F("\r\n[BOOTLOADER] Spouštím Main OS...\r"));
        break;
      case 4: // System Info
        Bootloader::printSystemInfo();
        // Po info spusť výchozí OS
        bootScriptPath = bootConfig.os_path;
        Serial.println(F("\r\n[BOOTLOADER] Spouštím Main OS...\r"));
        break;
      default:
        bootScriptPath = bootConfig.os_path;
        break;
    }
  } else {
    Serial.println(F("[BOOTLOADER] Připojena SD karta\r"));
    Serial.printf("[BOOTLOADER] OS nalezen: %s\r\n", bootScriptPath);
    Serial.println(F("[BOOTLOADER] Zavádím spuštění systému...\r"));
  }

  // Zkontroluj, zda boot script existuje
  if (!SD.exists(bootScriptPath)) {
    Serial.printf("[BOOTLOADER][ERROR] Boot script nenalezen: %s\r\n", bootScriptPath);
    
    if (bootConfig.auto_recovery && strcmp(bootScriptPath, bootConfig.recovery_path) != 0) {
      Serial.println(F("[BOOTLOADER] Aktivuji automatický recovery mode...\r"));
      bootScriptPath = bootConfig.recovery_path;
      
      if (!SD.exists(bootScriptPath)) {
        Serial.println(F("[BOOTLOADER][FATAL] Recovery script také nenalezen!\r"));
        while (true) {
          delay(1000);
        }
      }
    } else {
      Serial.println(F("[BOOTLOADER][FATAL] Nelze pokračovat bez boot scriptu.\r"));
      while (true) {
        delay(1000);
      }
    }
  }

  if (!initLua()) {
    while (true) {
      delay(1000);
    }
  }

  Serial.printf("[BOOT] Spouštím %s\r\n", bootScriptPath);
  if (!executeLuaScriptFromFile(g_luaState, bootScriptPath)) {
    Serial.println(F("[BOOT][ERROR] Boot Lua script selhal.\r"));
    
    // Pokus o recovery
    if (bootConfig.auto_recovery && strcmp(bootScriptPath, bootConfig.recovery_path) != 0) {
      Serial.println(F("[BOOT] Pokus o spuštění recovery mode...\r"));
      if (SD.exists(bootConfig.recovery_path)) {
        if (executeLuaScriptFromFile(g_luaState, bootConfig.recovery_path)) {
          Serial.println(F("[BOOT] Recovery mode úspěšně spuštěn.\r"));
          return;
        }
      }
    }
    
    Serial.println(F("[FATAL] Boot selhal a recovery není dostupný.\r"));
    while (true) {
      delay(1000);
    }
  }

  Serial.println(F("[BOOT] Převzetí řízení Lua kernelu dokončeno.\r"));
}

void loop() {
  // Hlavní smyčka je řízená Lua skripty.
  delay(50);
}
