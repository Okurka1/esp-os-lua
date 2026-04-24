-- Česká lokalizace
return {
  -- Menu
  menu_title = "ESP-OS v0.0.3.1",
  menu_system_info = "Systémové Info",
  menu_wifi_manager = "WiFi Manager",
  menu_gpio_manager = "GPIO Manager",
  menu_settings = "Nastavení",
  menu_restart = "Restart",
  menu_cmd = "CMD Konzole",
  menu_select = "Vyber položku",

  -- Common
  back = "Zpět",
  cancel = "Zrušit",
  confirm = "Potvrdit",
  yes = "Ano",
  no = "Ne",
  press_key = "Stiskni libovolnou klávesu",
  press_key_back = "Stiskni libovolnou klávesu pro návrat",

  -- Errors
  error_invalid_choice = "Neplatná volba!",
  error_sd_not_connected = "SD karta není připojena!",
  error_file_not_found = "Soubor nenalezen",
  error_invalid_pin = "Neplatný pin",
  error_invalid_value = "Neplatná hodnota",

  -- System Info
  sysinfo_title = "SYSTÉMOVÉ INFO",
  sysinfo_chip = "Chip model",
  sysinfo_revision = "Revize",
  sysinfo_cores = "CPU jádra",
  sysinfo_frequency = "Frekvence",
  sysinfo_uptime = "Uptime",
  sysinfo_ram = "RAM",
  sysinfo_flash = "Flash",
  sysinfo_sd_card = "SD karta",
  sysinfo_sd_total = "SD celkem",
  sysinfo_sd_free = "SD volné",
  sysinfo_sd_retry = "Vlož SD kartu a zkus to znovu.",

  -- WiFi Manager
  wifi_title = "WIFI MANAGER",
  wifi_scan = "Skenovat sítě",
  wifi_connect = "Připojit k síti",
  wifi_disconnect = "Odpojit",
  wifi_ap_mode = "AP režim",
  wifi_saved = "Uložené sítě",
  wifi_auto_reconnect = "Auto-reconnect",
  wifi_info = "WiFi Informace",

  wifi_scanning = "Skenuji WiFi sítě...",
  wifi_found = "Nalezeno sítí",
  wifi_connecting = "Připojuji se k",
  wifi_connected = "Připojeno!",
  wifi_disconnected = "Odpojeno",
  wifi_failed = "Připojení selhalo",

  wifi_enter_ssid = "Zadej SSID",
  wifi_enter_password = "Zadej heslo",
  wifi_password_min = "Heslo musí mít min 8 znaků!",
  wifi_status = "Stav",
  wifi_no_networks = "Nebyla nalezena žádná síť.",
  wifi_select_network = "Vyber číslo sítě pro připojení (Enter = zpět): ",
  wifi_saved_list = "Uložené sítě:",

  wifi_info_status = "Stav",
  wifi_info_ssid = "SSID",
  wifi_info_ip = "IP adresa",
  wifi_info_gateway = "Gateway",
  wifi_info_dns = "DNS",
  wifi_info_mac = "MAC adresa",
  wifi_info_rssi = "Síla signálu",
  wifi_info_channel = "Kanál",
  wifi_info_phy_mode = "Rychlost",
  wifi_info_connection_type = "Typ připojení",

  -- GPIO Manager
  gpio_title = "GPIO MANAGER",
  gpio_overview = "Pin Overview",
  gpio_digital = "Digital Control",
  gpio_pwm = "PWM Control",
  gpio_analog = "Analog Read (ADC)",
  gpio_config = "Konfigurace",

  gpio_enter_pin = "Zadej GPIO pin (např. 2)",
  gpio_set_output = "Nastavit pin jako OUTPUT?",
  gpio_set_state = "Nastavit stav [0/1]",
  gpio_enter_pwm = "Zadej PWM hodnotu [0-255]",
  gpio_adc_pins = "ADC piny",

  gpio_warning_reserved = "VAROVÁNÍ: Pin %d je rezervovaný!",
  gpio_warning_damage = "Může způsobit nevratné poškození HW!",
  gpio_warning_continue = "Pokračovat?",

  -- CMD Console
  cmd_title = "ESP-OS CMD Console",
  cmd_help_prompt = "Zadej 'help' pro nápovědu",
  cmd_prompt = "ESP-OS>",
  cmd_unknown = "Neznámý příkaz",
  cmd_help_text = "Zadej 'help' pro seznam příkazů",

  cmd_available = "Dostupné příkazy:",
  cmd_help_desc = "Tato nápověda",
  cmd_ls_desc = "Seznam souborů",
  cmd_cat_desc = "Zobrazit soubor",
  cmd_free_desc = "RAM info",
  cmd_uptime_desc = "Čas běhu",
  cmd_wifi_desc = "WiFi info",
  cmd_gpio_desc = "GPIO info",
  cmd_clear_desc = "Vyčistit obrazovku",
  cmd_reboot_desc = "Restart systému",
  cmd_shutdown_desc = "Vypnout zařízení",
  cmd_exit_desc = "Návrat do menu",

  -- Settings
  settings_title = "NASTAVENÍ",
  settings_language = "Jazyk / Language",
  settings_device_name = "Název zařízení",
  settings_auto_start = "Auto-start",
  settings_debug = "Debug režim",
  settings_lang_changed_cs = "✓ Jazyk změněn na češtinu",
  settings_lang_changed_en = "✓ Jazyk změněn na angličtinu",
  settings_enter_device_name = "Zadej nový název zařízení",
  settings_saved = "Nastavení uloženo",

  -- System
  system_restarting = "Restartuji...",
  system_shutting_down = "Vypínám zařízení...",
  system_press_boot = "Stiskni BOOT tlačítko pro probuzení",
}
