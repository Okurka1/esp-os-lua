-- English localization
return {
  -- Menu
  menu_title = "ESP-OS v0.0.3.1",
  menu_system_info = "System Info",
  menu_wifi_manager = "WiFi Manager",
  menu_gpio_manager = "GPIO Manager",
  menu_settings = "Settings",
  menu_restart = "Restart",
  menu_cmd = "CMD Console",
  menu_select = "Select item",

  -- Common
  back = "Back",
  cancel = "Cancel",
  confirm = "Confirm",
  yes = "Yes",
  no = "No",
  press_key = "Press any key",
  press_key_back = "Press any key to return",

  -- Errors
  error_invalid_choice = "Invalid choice!",
  error_sd_not_connected = "SD card not connected!",
  error_file_not_found = "File not found",
  error_invalid_pin = "Invalid pin",
  error_invalid_value = "Invalid value",

  -- System Info
  sysinfo_title = "SYSTEM INFO",
  sysinfo_chip = "Chip model",
  sysinfo_revision = "Revision",
  sysinfo_cores = "CPU cores",
  sysinfo_frequency = "Frequency",
  sysinfo_uptime = "Uptime",
  sysinfo_ram = "RAM",
  sysinfo_flash = "Flash",
  sysinfo_sd_card = "SD card",
  sysinfo_sd_total = "SD total",
  sysinfo_sd_free = "SD free",
  sysinfo_sd_retry = "Insert SD card and try again.",

  -- WiFi Manager
  wifi_title = "WIFI MANAGER",
  wifi_scan = "Scan Networks",
  wifi_connect = "Connect to Network",
  wifi_disconnect = "Disconnect",
  wifi_ap_mode = "AP Mode",
  wifi_saved = "Saved Networks",
  wifi_auto_reconnect = "Auto-reconnect",
  wifi_info = "WiFi Information",

  wifi_scanning = "Scanning WiFi networks...",
  wifi_found = "Networks found",
  wifi_connecting = "Connecting to",
  wifi_connected = "Connected!",
  wifi_disconnected = "Disconnected",
  wifi_failed = "Connection failed",

  wifi_enter_ssid = "Enter SSID",
  wifi_enter_password = "Enter password",
  wifi_password_min = "Password must be at least 8 characters!",
  wifi_status = "Status",
  wifi_no_networks = "No networks found.",
  wifi_select_network = "Select network number to connect (Enter = back): ",
  wifi_saved_list = "Saved networks:",

  wifi_info_status = "Status",
  wifi_info_ssid = "SSID",
  wifi_info_ip = "IP address",
  wifi_info_gateway = "Gateway",
  wifi_info_dns = "DNS",
  wifi_info_mac = "MAC address",
  wifi_info_rssi = "Signal strength",
  wifi_info_channel = "Channel",
  wifi_info_phy_mode = "Speed",
  wifi_info_connection_type = "Connection type",

  -- GPIO Manager
  gpio_title = "GPIO MANAGER",
  gpio_overview = "Pin Overview",
  gpio_digital = "Digital Control",
  gpio_pwm = "PWM Control",
  gpio_analog = "Analog Read (ADC)",
  gpio_config = "Configuration",

  gpio_enter_pin = "Enter GPIO pin (e.g. 2)",
  gpio_set_output = "Set pin as OUTPUT?",
  gpio_set_state = "Set state [0/1]",
  gpio_enter_pwm = "Enter PWM value [0-255]",
  gpio_adc_pins = "ADC pins",

  gpio_warning_reserved = "WARNING: Pin %d is reserved!",
  gpio_warning_damage = "May cause irreversible HW damage!",
  gpio_warning_continue = "Continue?",

  -- CMD Console
  cmd_title = "ESP-OS CMD Console",
  cmd_help_prompt = "Type 'help' for help",
  cmd_prompt = "ESP-OS>",
  cmd_unknown = "Unknown command",
  cmd_help_text = "Type 'help' for list of commands",

  cmd_available = "Available commands:",
  cmd_help_desc = "This help",
  cmd_ls_desc = "List files",
  cmd_cat_desc = "Display file",
  cmd_free_desc = "RAM info",
  cmd_uptime_desc = "System uptime",
  cmd_wifi_desc = "WiFi info",
  cmd_gpio_desc = "GPIO info",
  cmd_clear_desc = "Clear screen",
  cmd_reboot_desc = "Restart system",
  cmd_shutdown_desc = "Shutdown device",
  cmd_exit_desc = "Return to menu",

  -- Settings
  settings_title = "SETTINGS",
  settings_language = "Language / Jazyk",
  settings_device_name = "Device name",
  settings_auto_start = "Auto-start",
  settings_debug = "Debug mode",
  settings_lang_changed_cs = "✓ Language changed to Czech",
  settings_lang_changed_en = "✓ Language changed to English",
  settings_enter_device_name = "Enter new device name",
  settings_saved = "Settings saved",

  -- System
  system_restarting = "Restarting...",
  system_shutting_down = "Shutting down device...",
  system_press_boot = "Press BOOT button to wake up",
}
