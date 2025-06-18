#!/system/bin/sh
MODDIR=${0%/*}


LOGDIR=/data/local/tmp/PushinCharge
mkdir -p $LOGDIR

LOG="$LOGDIR/charging_log.txt"

BATTERY_LIMIT_PATH="/sys/class/power_supply/battery/charge_full_design"
ADAPTIVE_CHARGING_PATH="/sys/class/power_supply/battery/charge_control_mode"

# Check Android version
API_LEVEL=$(getprop ro.build.version.sdk)
if [ "$API_LEVEL" -lt 15 ]; then
  echo "$(date) - ERROR: Device API level ($API_LEVEL) is below 15, module won't work" >> $LOG
  exit 1
fi

# Check for compatibility before proceeding
COMPATIBLE=0

# Samsung paths
if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ] || [ -f "/sys/class/power_supply/battery/store_mode" ]; then
  COMPATIBLE=1
fi

# OnePlus and generic paths
if [ -f "/sys/class/power_supply/battery/charging_enabled" ] || [ -f "/sys/class/power_supply/battery/charge_control_limit" ]; then
  COMPATIBLE=1
fi

# Pixel paths
if [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ] || [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
  COMPATIBLE=1
fi

# Xiaomi and others
if [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
  COMPATIBLE=1
fi

# Generic paths
if [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ] || [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
  COMPATIBLE=1
fi

# Exit if no compatible charging control paths found
if [ "$COMPATIBLE" -eq "0" ]; then
  echo "$(date) - ERROR: No compatible charging control paths found. Module cannot function on this device." >> $LOG
  exit 1
fi

if [ ! -f "$LOGDIR/device_info.txt" ]; then
  echo "PushinCharge Device Information" > "$LOGDIR/device_info.txt"
  echo "=============================" >> "$LOGDIR/device_info.txt"
  echo "Device: $(getprop ro.product.model)" >> "$LOGDIR/device_info.txt"
  echo "Manufacturer: $(getprop ro.product.manufacturer)" >> "$LOGDIR/device_info.txt"
  echo "Android Version: $(getprop ro.build.version.release)" >> "$LOGDIR/device_info.txt"
  echo "API Level: $API_LEVEL" >> "$LOGDIR/device_info.txt"
  echo "Kernel: $(uname -r)" >> "$LOGDIR/device_info.txt"
  echo "=============================" >> "$LOGDIR/device_info.txt"
fi

set_80_percent_charging() {
  if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ]; then
    echo "0" > /sys/class/power_supply/battery/batt_slate_mode
    echo "80" > /sys/class/power_supply/battery/store_mode
    success=1
  elif [ -f "/sys/class/power_supply/battery/charging_enabled" ]; then
    echo "1" > /sys/class/power_supply/battery/charging_enabled
    echo "80" > /sys/class/power_supply/battery/charge_control_limit
    success=1
  elif [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ]; then
    echo "80" > /sys/devices/platform/soc/soc:google,charger/charge_stop_level
    success=1
  elif [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
    echo "0" > /sys/class/power_supply/battery/input_suspend
    echo "80" > /sys/class/power_supply/battery/charge_control_limit
    success=1
  elif [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ]; then
    echo "1" > /sys/class/power_supply/battery/battery_charging_enabled
    echo "80" > /sys/class/power_supply/battery/charge_control_limit
    success=1
  else
    success=0
  fi
  
  echo "$(date) - Setting 80% charging limit, success: $success" >> $LOG
}

set_adaptive_charging() {
  success=0
  
  if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ]; then
    echo "0" > /sys/class/power_supply/battery/batt_slate_mode
    echo "0" > /sys/class/power_supply/battery/store_mode
    success=1
  elif [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
    echo "1" > /sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled
    success=1
  elif [ -f "/sys/class/power_supply/battery/charging_enabled" ]; then
    echo "1" > /sys/class/power_supply/battery/charging_enabled
    echo "100" > /sys/class/power_supply/battery/charge_control_limit
    success=1
  elif [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
    echo "1" > /sys/class/power_supply/battery/charge_control_mode
    success=1
  else
    success=0
  fi
  
  echo "$(date) - Setting adaptive charging, success: $success" >> $LOG
}

apply_time_based_charging() {
  HOUR=$(date +%H)
  
  HOUR_INT=$(($HOUR + 0))
  
  if [ "$HOUR_INT" -ge 23 ] || [ "$HOUR_INT" -lt 4 ]; then
    echo "$(date) - Nighttime detected (hour: $HOUR_INT), setting adaptive charging" >> $LOG
    set_adaptive_charging
  else
    echo "$(date) - Daytime detected (hour: $HOUR_INT), setting 80% charging limit" >> $LOG
    set_80_percent_charging
  fi
}

echo "$(date) - PushinCharge service started" >> $LOG
apply_time_based_charging

(
  while true; do
    apply_time_based_charging
    
    sleep 900
  done
) &
