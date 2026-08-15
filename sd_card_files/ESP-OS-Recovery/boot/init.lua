-- ESP-OS Recovery Mode
serial.print("\n[RECOVERY] ESP-OS Recovery Mode starting...\n")

-- Override global print() to use serial.print for proper line endings
_G.print = function(...)
  local args = {...}
  local output = ""
  for i, v in ipairs(args) do
    if i > 1 then
      output = output .. "\t"
    end
    output = output .. tostring(v)
  end
  serial.print(output .. "\n")
end

print("╔════════════════════════════════════════╗")
print("║     ESP-OS RECOVERY MODE v0.1.0        ║")
print("╠════════════════════════════════════════╣")
print("║  Minimální systém pro obnovu OS        ║")
print("╚════════════════════════════════════════╝")
print("")

-- Základní funkce pro recovery
local function recovery_menu()
  while true do
    print("\n╔════════════════════════════════════════╗")
    print("║        Recovery Menu                   ║")
    print("╠════════════════════════════════════════╣")
    print("║  [1] Zobrazit soubory na SD kartě      ║")
    print("║  [2] Zkontrolovat hlavní OS            ║")
    print("║  [3] Systémové informace               ║")
    print("║  [4] Restartovat do hlavního OS        ║")
    print("║  [5] Restartovat zařízení              ║")
    print("╚════════════════════════════════════════╝")
    print("\nVyberte volbu [1-5]: ")
    
    local choice = serial.readKey()
    
    if choice == "1" then
      print("\n=== Soubory na SD kartě ===")
      if sd.available() then
        local entries = sd.list("/")
        if entries then
          for _, entry in ipairs(entries) do
            if entry.isDir then
              print(string.format("  [DIR]  %s", entry.name))
            else
              print(string.format("  %6d B  %s", entry.size, entry.name))
            end
          end
        else
          print("[ERROR] Nelze načíst obsah SD karty")
        end
      else
        print("[ERROR] SD karta není dostupná")
      end
      print("\nStiskněte libovolnou klávesu...")
      serial.readKey()
      
    elseif choice == "2" then
      print("\n=== Kontrola hlavního OS ===")
      local main_os_path = "/ESP-OS/boot/init.lua"
      if sd.exists(main_os_path) then
        print("✓ Hlavní OS nalezen: " .. main_os_path)
        
        -- Zkontroluj další kritické soubory
        local critical_files = {
          "/ESP-OS/system/kernel.lua",
          "/ESP-OS/system/menu.lua",
          "/ESP-OS/lang/init.lua"
        }
        
        local all_ok = true
        for _, file in ipairs(critical_files) do
          if sd.exists(file) then
            print("✓ " .. file)
          else
            print("✗ CHYBÍ: " .. file)
            all_ok = false
          end
        end
        
        if all_ok then
          print("\n[SUCCESS] Všechny kritické soubory jsou přítomny.")
        else
          print("\n[WARNING] Některé kritické soubory chybí!")
        end
      else
        print("✗ Hlavní OS nenalezen!")
        print("[ERROR] Soubor " .. main_os_path .. " neexistuje")
      end
      print("\nStiskněte libovolnou klávesu...")
      serial.readKey()
      
    elseif choice == "3" then
      print("\n=== Systémové informace ===")
      print("Chip: " .. system.chipModel())
      print("CPU Freq: " .. system.cpuFreq() .. " MHz")
      print("Flash: " .. string.format("%.2f MB", system.flashSize() / (1024 * 1024)))
      print("Free Heap: " .. string.format("%.2f KB", system.heap() / 1024))
      
      if sd.available() then
        print("SD Card: " .. string.format("%.2f MB", sd.size() / (1024 * 1024)))
        print("SD Free: " .. string.format("%.2f MB", sd.free() / (1024 * 1024)))
      else
        print("SD Card: Not available")
      end
      
      print("\nStiskněte libovolnou klávesu...")
      serial.readKey()
      
    elseif choice == "4" then
      print("\n[RECOVERY] Restartování do hlavního OS...")
      system.delay(1000)
      system.restart()
      
    elseif choice == "5" then
      print("\n[RECOVERY] Restartování zařízení...")
      system.delay(1000)
      system.restart()
      
    else
      print("\n[ERROR] Neplatná volba!")
      system.delay(1000)
    end
  end
end

-- Spusť recovery menu
recovery_menu()
