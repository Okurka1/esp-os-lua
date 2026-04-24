#include "post.h"

#include <SD.h>
#include <SPI.h>

#include "config.h"

namespace Bootloader {

bool runPOST(uint8_t sdCsPin) {
  Serial.println(F("[POST] Spouštím Power-On Self Test..."));

  bool sdReady = false;
  for (uint32_t attempt = 1; attempt <= Config::SD_INIT_RETRIES; ++attempt) {
    Serial.printf("[POST] SD init pokus %lu/%lu (CS=%u)\n", attempt, Config::SD_INIT_RETRIES, sdCsPin);

    // Ujistíme se, že SPI i SD jsou v čistém stavu.
    SD.end();
    SPI.end();
    SPI.begin();

    if (SD.begin(sdCsPin)) {
      sdReady = true;
      break;
    }

    delay(Config::SD_INIT_RETRY_DELAY_MS);
  }

  if (!sdReady) {
    Serial.println(F("[POST][ERROR] SD karta není dostupná."));
    return false;
  }

  const uint64_t cardSizeMb = SD.cardSize() / (1024ULL * 1024ULL);
  Serial.printf("[POST] SD karta OK, velikost ~%llu MB\n", cardSizeMb);
  Serial.println(F("[POST] POST dokončen úspěšně."));

  return true;
}

}  // namespace Bootloader
