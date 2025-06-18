#!/system/bin/sh
# PushinCharge Pre-installation Check
# This script runs during installation to verify device compatibility

ui_print "- Checking device compatibility..."

handle_failure() {
  mkdir -p /data/local/tmp/PushinCharge
  cp $INSTALLER/common/installation_failed.md /data/local/tmp/PushinCharge/
  
  ERROR_LOG="/data/local/tmp/PushinCharge/install_error.log"
  echo "PushinCharge Installation Failed - $(date)" > $ERROR_LOG
  echo "============================================" >> $ERROR_LOG
  echo "Device: $(getprop ro.product.model)" >> $ERROR_LOG
  echo "Manufacturer: $(getprop ro.product.manufacturer)" >> $ERROR_LOG
  echo "Android Version: $(getprop ro.build.version.release)" >> $ERROR_LOG
  echo "API Level: $(getprop ro.build.version.sdk)" >> $ERROR_LOG
  echo "Kernel: $(uname -r)" >> $ERROR_LOG
  echo "Error: $1" >> $ERROR_LOG
  echo "--------------- Charging Paths ---------------" >> $ERROR_LOG
  
  # Check for common paths and log their existence
  if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ]; then
    echo "[FOUND] /sys/class/power_supply/battery/batt_slate_mode" >> $ERROR_LOG
  else
    echo "[MISSING] /sys/class/power_supply/battery/batt_slate_mode" >> $ERROR_LOG
  fi
  
  if [ -f "/sys/class/power_supply/battery/store_mode" ]; then
    echo "[FOUND] /sys/class/power_supply/battery/store_mode" >> $ERROR_LOG
  else
    echo "[MISSING] /sys/class/power_supply/battery/store_mode" >> $ERROR_LOG
  fi
  
  if [ -f "/sys/class/power_supply/battery/charging_enabled" ]; then
    echo "[FOUND] /sys/class/power_supply/battery/charging_enabled" >> $ERROR_LOG
  else
    echo "[MISSING] /sys/class/power_supply/battery/charging_enabled" >> $ERROR_LOG
  fi
  
  if [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ]; then
    echo "[FOUND] /sys/devices/platform/soc/soc:google,charger/charge_stop_level" >> $ERROR_LOG
  else
    echo "[MISSING] /sys/devices/platform/soc/soc:google,charger/charge_stop_level" >> $ERROR_LOG
  fi
  
  echo "============================================" >> $ERROR_LOG
  echo "See troubleshooting guide at: /data/local/tmp/PushinCharge/installation_failed.md" >> $ERROR_LOG
  
  ui_print "! Installation failed: $1"
  ui_print "! Check /data/local/tmp/PushinCharge/install_error.log for details"
  ui_print "! A troubleshooting guide has been saved to your device"
  
  exit 1
}

# Check Android version
API_LEVEL=$(getprop ro.build.version.sdk)
if [ "$API_LEVEL" -lt "15" ]; then
  handle_failure "Android version too low (API $API_LEVEL). Required: API 15+"
else
  ui_print "- Android version check passed: API $API_LEVEL"
fi

ui_print "- Checking for charging control paths..."
COMPATIBLE=0

# Samsung paths
if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ]; then
  ui_print "- Found Samsung battery control path"
  COMPATIBLE=1
fi
if [ -f "/sys/class/power_supply/battery/store_mode" ]; then
  ui_print "- Found Samsung store_mode path"
  COMPATIBLE=1
fi

# OnePlus and generic paths
if [ -f "/sys/class/power_supply/battery/charging_enabled" ]; then
  ui_print "- Found charging_enabled path"
  COMPATIBLE=1
fi
if [ -f "/sys/class/power_supply/battery/charge_control_limit" ]; then
  ui_print "- Found charge_control_limit path"
  COMPATIBLE=1
fi

# Pixel paths
if [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ]; then
  ui_print "- Found Pixel charge_stop_level path"
  COMPATIBLE=1
fi
if [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
  ui_print "- Found Pixel adaptive_charging path"
  COMPATIBLE=1
fi

# Xiaomi and others
if [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
  ui_print "- Found input_suspend path"
  COMPATIBLE=1
fi

# Generic paths
if [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ]; then
  ui_print "- Found battery_charging_enabled path"
  COMPATIBLE=1
fi
if [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
  ui_print "- Found charge_control_mode path"
  COMPATIBLE=1
fi

if [ "$COMPATIBLE" -eq "0" ]; then
  handle_failure "No compatible charging control paths found"
fi

ui_print "- Device compatibility check passed"
ui_print "- Continuing installation..."
exit 0
