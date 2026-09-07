#pragma once

#include <Arduino.h>
#include <freertos/FreeRTOS.h>
#include <freertos/semphr.h>

namespace Config {
// Základní konfigurace zařízení
static constexpr uint32_t SERIAL_BAUD = 115200;
static constexpr uint8_t SD_CS_PIN = 5;

// Cesty na SD kartě
static constexpr const char* BOOT_SCRIPT_PATH = "/ESP-OS/boot/init.lua";

// Timeouty
static constexpr uint32_t SD_INIT_RETRIES = 3;
static constexpr uint32_t SD_INIT_RETRY_DELAY_MS = 500;
static constexpr uint32_t LUA_API_LOCK_TIMEOUT_MS = 5000;  // Increased from 2s to 5s for SD stability
static constexpr uint32_t WIFI_CONNECT_TIMEOUT_MS = 20000;

// PWM defaulty (ESP32 LEDC)
static constexpr uint32_t PWM_FREQ = 5000;
static constexpr uint8_t PWM_RESOLUTION_BITS = 8;

// Memory limits
static constexpr size_t MAX_LUA_SCRIPT_SIZE = 65536;    // 64 KB
static constexpr size_t MAX_SD_READ_SIZE = 32768;       // 32 KB
static constexpr size_t MAX_SERIAL_INPUT_SIZE = 256;    // 256 B for serial input
}

// Sdílený mutex pro thread-safe přístup z Lua API
extern SemaphoreHandle_t g_luaMutex;
