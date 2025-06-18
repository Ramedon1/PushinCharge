#!/system/bin/sh
# PushinCharge Uninstall Script

LOGDIR=/data/local/tmp/PushinCharge
mkdir -p $LOGDIR
echo "$(date) - PushinCharge module uninstalled" > "$LOGDIR/uninstall_log.txt"


if [ -f "/sys/class/power_supply/battery/batt_slate_mode" ]; then
  echo "0" > /sys/class/power_supply/battery/batt_slate_mode
  echo "0" > /sys/class/power_supply/battery/store_mode 2>/dev/null
fi

if [ -f "/sys/class/power_supply/battery/charging_enabled" ]; then
  echo "1" > /sys/class/power_supply/battery/charging_enabled
  echo "100" > /sys/class/power_supply/battery/charge_control_limit 2>/dev/null
fi

if [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ]; then
  echo "100" > /sys/devices/platform/soc/soc:google,charger/charge_stop_level 2>/dev/null
fi

if [ -f "/sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled" ]; then
  echo "0" > /sys/devices/platform/soc/soc:google,charger/adaptive_charging_enabled 2>/dev/null
fi

if [ -f "/sys/class/power_supply/battery/input_suspend" ]; then
  echo "0" > /sys/class/power_supply/battery/input_suspend 2>/dev/null
  echo "100" > /sys/class/power_supply/battery/charge_control_limit 2>/dev/null
fi

if [ -f "/sys/class/power_supply/battery/battery_charging_enabled" ]; then
  echo "1" > /sys/class/power_supply/battery/battery_charging_enabled 2>/dev/null
  echo "100" > /sys/class/power_supply/battery/charge_control_limit 2>/dev/null
fi

if [ -f "/sys/class/power_supply/battery/charge_control_mode" ]; then
  echo "0" > /sys/class/power_supply/battery/charge_control_mode 2>/dev/null
fi

echo "$(date) - Attempted to reset charging settings to default" >> "$LOGDIR/uninstall_log.txt"

echo "$(date) - Uninstall complete. Logs remain in $LOGDIR for reference" >> "$LOGDIR/uninstall_log.txt"
