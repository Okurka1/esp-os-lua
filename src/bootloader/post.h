#pragma once

#include <Arduino.h>

namespace Bootloader {
// Provede Power-On Self Test (POST): SD karta, základní HW validace.
bool runPOST(uint8_t sdCsPin);
}
