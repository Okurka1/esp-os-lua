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
static constexpr uint32_t LUA_API_LOCK_TIMEOUT_MS = 2000;
static constexpr uint32_t WIFI_CONNECT_TIMEOUT_MS = 20000;

// PWM defaulty (ESP32 LEDC)
static constexpr uint32_t PWM_FREQ = 5000;
static constexpr uint8_t PWM_RESOLUTION_BITS = 8;
}

// Sdílený mutex pro thread-safe přístup z Lua API
extern SemaphoreHandle_t g_luaMutex;
