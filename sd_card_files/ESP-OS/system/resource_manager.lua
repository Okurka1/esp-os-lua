-- Resource Manager - Správa systémových prostředků (RAM, moduly, HW)
local resource_manager = {}

-- Sledování načtených modulů
local loaded_modules = {}
local module_usage = {}

-- Konfigurace
local config = {
  gc_threshold = 70,  -- Spustit GC při 70% využití RAM
  module_timeout = 300000,  -- Uvolnit nepoužívané moduly po 5 minutách (ms)
  min_free_heap = 50000,  -- Minimální volná RAM (bytes)
}

-- Inicializace
function resource_manager.init()
  loaded_modules = {}
  module_usage = {}
  resource_manager.last_gc = system.millis()
end

-- Registrace modulu
function resource_manager.register_module(name, module_ref)
  loaded_modules[name] = module_ref
  module_usage[name] = system.millis()
end

-- Aktualizace použití modulu
function resource_manager.touch_module(name)
  if loaded_modules[name] then
    module_usage[name] = system.millis()
  end
end

-- Uvolnění nepoužívaných modulů
function resource_manager.cleanup_modules()
  local current_time = system.millis()
  local freed = 0
  
  for name, last_used in pairs(module_usage) do
    if (current_time - last_used) > config.module_timeout then
      -- Neodstraňuj core moduly
      if name ~= "ui" and name ~= "menu" and name ~= "kernel" and name ~= "lang" and name ~= "ansi" then
        loaded_modules[name] = nil
        module_usage[name] = nil
        _G[name] = nil
        freed = freed + 1
      end
    end
  end
  
  if freed > 0 then
    collectgarbage("collect")
  end
  
  return freed
end

-- Kontrola RAM a automatické čištění
function resource_manager.check_memory()
  local free = system.heap()
  local total = system.heapSize()
  local used_percent = ((total - free) / total) * 100
  
  -- Kritická úroveň - okamžité čištění
  if free < config.min_free_heap then
    resource_manager.cleanup_modules()
    collectgarbage("collect")
    return "critical"
  end
  
  -- Vysoké využití - spustit GC
  if used_percent > config.gc_threshold then
    collectgarbage("collect")
    return "high"
  end
  
  return "ok"
end

-- Automatické čištění (volat periodicky)
function resource_manager.auto_cleanup()
  local current_time = system.millis()
  
  -- Kontrola každých 30 sekund
  if (current_time - (resource_manager.last_gc or 0)) > 30000 then
    resource_manager.last_gc = current_time
    
    local status = resource_manager.check_memory()
    if status ~= "ok" then
      resource_manager.cleanup_modules()
    end
  end
end

-- Získání statistik
function resource_manager.get_stats()
  local free = system.heap()
  local total = system.heapSize()
  local used = total - free
  local used_percent = (used / total) * 100
  
  local module_count = 0
  for _ in pairs(loaded_modules) do
    module_count = module_count + 1
  end
  
  return {
    free_heap = free,
    total_heap = total,
    used_heap = used,
    used_percent = used_percent,
    loaded_modules = module_count,
    status = resource_manager.check_memory()
  }
end

-- Vynutit garbage collection
function resource_manager.force_gc()
  collectgarbage("collect")
  local before = system.heap()
  collectgarbage("collect")
  local after = system.heap()
  return after - before  -- Uvolněná paměť
end

-- Vypsat statistiky
function resource_manager.print_stats()
  local stats = resource_manager.get_stats()
  
  print("\n=== Resource Manager Stats ===")
  print(string.format("RAM: %.2f / %.2f KB (%.1f%%)", 
    stats.used_heap / 1024, stats.total_heap / 1024, stats.used_percent))
  print(string.format("Free: %.2f KB", stats.free_heap / 1024))
  print(string.format("Loaded modules: %d", stats.loaded_modules))
  print(string.format("Status: %s", stats.status))
  
  if stats.status == "critical" then
    print("⚠ WARNING: Low memory!")
  elseif stats.status == "high" then
    print("⚠ High memory usage")
  end
end

return resource_manager
