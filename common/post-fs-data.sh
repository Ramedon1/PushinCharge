#!/system/bin/sh
MODDIR=${0%/*}


LOGDIR=/data/local/tmp/PushinCharge
mkdir -p $LOGDIR

LOG="$LOGDIR/charging_log.txt"
echo "$(date) - PushinCharge module initialized" > $LOG

API_LEVEL=$(getprop ro.build.version.sdk)
echo "$(date) - Device API level: $API_LEVEL" >> $LOG

if [ "$API_LEVEL" -lt "15" ]; then
  echo "$(date) - ERROR: Unsupported Android version. Minimum required is Android 15 (API 15)" >> $LOG
  exit 1
fi

COMPATIBLE=0

# Samsung paths
if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ] || [ -f "/sys/class/power_supply/battery/store_mode" ]; then
  COMPATIBLE=1
  chmod 0666 /sys/class/power_supply/battery/batt_slate_mode 2>/dev/null
  chmod 0666 /sys/class/power_supply/battery/store_mode 2>/dev/null
fi

# OnePlus and generic paths
if [ -f "/sys/class/power_supply/battery/charging_enabled" ] || [ -f "/sys/class/power_supply/battery/charge_control_limit" ]; then
  COMPATIBLE=1
  chmod 0666 /sys/class/power_supply/battery/charging_enabled 2>/dev/null
  chmod 0666 /sys/class/power_supply/battery/charge_control_limit 2>/dev/null
fi

# Pixel paths
if [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ] || [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
  COMPATIBLE=1
  chmod 0666 /sys/devices/platform/soc/soc:google,charger/charge_stop_level 2>/dev/null
  chmod 0666 /sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled 2>/dev/null
fi

# Xiaomi and others
if [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
  COMPATIBLE=1
  chmod 0666 /sys/class/power_supply/battery/input_suspend 2>/dev/null
fi

# Generic paths
if [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ] || [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
  COMPATIBLE=1
  chmod 0666 /sys/class/power_supply/battery/battery_charging_enabled 2>/dev/null
  chmod 0666 /sys/class/power_supply/battery/charge_control_mode 2>/dev/null
fi

if [ "$COMPATIBLE" -eq "0" ]; then
  echo "$(date) - ERROR: No compatible charging control paths found. Module will not work on this device." >> $LOG
  exit 1
fi

echo "$(date) - Device compatibility check passed" >> $LOG

echo "$(date) - Set permissions for battery control paths" >> $LOG
