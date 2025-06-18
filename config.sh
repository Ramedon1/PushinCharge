MODID=PushinCharge
AUTOMOUNT=true

PROPFILE=false

POSTFSDATA=true

LATESTARTSERVICE=true

print_modname() {
  ui_print "*******************************"
  ui_print "         PushinCharge         "
  ui_print "     By Ramedon               "
  ui_print "*******************************"
  ui_print " Switches charging type based  "
  ui_print " on time of day (80% limit    "
  ui_print " during day, adaptive at night)"
  ui_print "*******************************"
}

# Android version check
android_check() {
  ui_print "- Checking Android version..."
  if [ "$API" -lt "15" ]; then
    ui_print "! Unsupported Android version: $API"
    ui_print "! This module requires Android 15 or above"
    ui_print "! Installation aborted"
    exit 1
  fi
  ui_print "- Android $API detected"
}

# Charging control path check
compatibility_check() {
  ui_print "- Checking device compatibility..."
  # Check for common charging control paths
  COMPATIBLE=0
  
  # Samsung
  if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ] || \
     [ -f "/sys/class/power_supply/battery/store_mode" ]; then
    COMPATIBLE=1
  # Pixel
  elif [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ] || \
       [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
    COMPATIBLE=1
  # OnePlus and generic
  elif [ -f "/sys/class/power_supply/battery/charging_enabled" ] || \
       [ -f "/sys/class/power_supply/battery/charge_control_limit" ]; then
    COMPATIBLE=1
  # Xiaomi and others
  elif [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
    COMPATIBLE=1
  # Generic
  elif [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ] || \
       [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
    COMPATIBLE=1
  fi
  
  if [ "$COMPATIBLE" -eq "0" ]; then
    ui_print "! No compatible charging control paths found"
    ui_print "! Your device does not support charging type control"
    ui_print "! Installation aborted"
    exit 1
  fi
  
  ui_print "- Device is compatible"
}


set_permissions() {
  set_perm_recursive  $MODPATH  0  0  0755  0644

  set_perm  $MODPATH/common/service.sh             0       0       0755
  set_perm  $MODPATH/common/post-fs-data.sh        0       0       0755
  set_perm  $MODPATH/common/check_compatibility.sh 0       0       0755
  set_perm  $MODPATH/common/uninstall.sh           0       0       0755
  set_perm  $MODPATH/common/manual_switch.sh       0       0       0755
  set_perm  $MODPATH/common/log_cleanup.sh         0       0       0755
  set_perm  $MODPATH/common/pre_install.sh         0       0       0755
  set_perm  $MODPATH/common/check_android_version.sh 0     0       0755
  
  mkdir -p /data/local/tmp/PushinCharge
  set_perm_recursive /data/local/tmp/PushinCharge 0 0 0755 0644
}
