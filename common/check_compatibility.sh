#!/system/bin/sh
# PushinCharge Device Compatibility Checker
# This script checks if your device has the necessary charging control files

LOGDIR=/data/local/tmp/PushinCharge
mkdir -p $LOGDIR

LOG="$LOGDIR/compatibility_check.txt"

echo "PushinCharge Compatibility Check - $(date)" > $LOG
echo "=========================================" >> $LOG

API_LEVEL=$(getprop ro.build.version.sdk)
echo "Device API level: $API_LEVEL" >> $LOG
if [ "$API_LEVEL" -lt 15 ]; then
  echo "ERROR: Device API level ($API_LEVEL) is below 15" >> $LOG
  echo "This module requires Android 15 or higher" >> $LOG
  echo "=========================================" >> $LOG
  echo "ERROR: Unsupported Android version. Minimum required is Android 15 (API 15)"
  exit 1
fi

DEVICE=$(getprop ro.product.model)
MANUFACTURER=$(getprop ro.product.manufacturer)
echo "Device: $DEVICE" >> $LOG
echo "Manufacturer: $MANUFACTURER" >> $LOG
echo "----------------------------------------" >> $LOG

if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ]; then
  echo "[FOUND] Samsung batt_slate_mode" >> $LOG
else
  echo "[NOT FOUND] Samsung batt_slate_mode" >> $LOG
fi

if [ -f "/sys/class/power_supply/battery/store_mode" ]; then
  echo "[FOUND] Samsung store_mode" >> $LOG
else
  echo "[NOT FOUND] Samsung store_mode" >> $LOG
fi

if [ -f "/sys/class/power_supply/battery/charging_enabled" ]; then
  echo "[FOUND] charging_enabled" >> $LOG
else
  echo "[NOT FOUND] charging_enabled" >> $LOG
fi

if [ -f "/sys/class/power_supply/battery/charge_control_limit" ]; then
  echo "[FOUND] charge_control_limit" >> $LOG
else
  echo "[NOT FOUND] charge_control_limit" >> $LOG
fi

if [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ]; then
  echo "[FOUND] Pixel charge_stop_level" >> $LOG
else
  echo "[NOT FOUND] Pixel charge_stop_level" >> $LOG
fi

if [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
  echo "[FOUND] Pixel adaptive_charging_enabled" >> $LOG
else
  echo "[NOT FOUND] Pixel adaptive_charging_enabled" >> $LOG
fi

if [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
  echo "[FOUND] input_suspend" >> $LOG
else
  echo "[NOT FOUND] input_suspend" >> $LOG
fi

if [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ]; then
  echo "[FOUND] battery_charging_enabled" >> $LOG
else
  echo "[NOT FOUND] battery_charging_enabled" >> $LOG
fi

if [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
  echo "[FOUND] charge_control_mode" >> $LOG
else
  echo "[NOT FOUND] charge_control_mode" >> $LOG
fi

echo "----------------------------------------" >> $LOG

found_count=$(grep -c "\[FOUND\]" $LOG)

if [ "$found_count" -gt 0 ]; then
  echo "RESULT: Found $found_count compatible charging control paths." >> $LOG
  echo "The module has a good chance of working on this device." >> $LOG
else
  echo "RESULT: No compatible charging control paths found." >> $LOG
  echo "The module might not work on this device." >> $LOG
fi

echo "=========================================" >> $LOG
echo "Check complete. Log saved to $LOG" >> $LOG

cat $LOG
