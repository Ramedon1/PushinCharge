#!/system/bin/sh
# PushinCharge Manual Mode Switcher
# This script allows manual switching between charging modes

LOGDIR=/data/local/tmp/PushinCharge
mkdir -p $LOGDIR

LOG="$LOGDIR/manual_switch.txt"

usage() {
  echo "PushinCharge Manual Mode Switcher"
  echo "Usage: $0 [mode]"
  echo ""
  echo "Available modes:"
  echo "  adaptive    - Switch to adaptive charging (full charge)"
  echo "  limit       - Switch to 80% charging limit"
  echo "  status      - Show current charging status"
  echo ""
  echo "Example: $0 limit"
}

set_80_percent_charging() {
  success=0
  
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
  
  echo "$(date) - Manual switch: Setting 80% charging limit, success: $success" >> $LOG
  
  if [ "$success" -eq 1 ]; then
    echo "Successfully switched to 80% charging limit mode"
  else
    echo "Failed to switch to 80% charging limit mode"
    echo "Your device may not be compatible with this charging mode"
  fi
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
  
  echo "$(date) - Manual switch: Setting adaptive charging, success: $success" >> $LOG
  
  if [ "$success" -eq 1 ]; then
    echo "Successfully switched to adaptive charging mode"
  else
    echo "Failed to switch to adaptive charging mode"
    echo "Your device may not be compatible with this charging mode"
  fi
}

check_status() {
  echo "Current Battery Status:"
  echo "-----------------------"
  
  if [ -f "/sys/class/power_supply/battery/capacity" ]; then
    BATT_LEVEL=$(cat /sys/class/power_supply/battery/capacity)
    echo "Battery Level: ${BATT_LEVEL}%"
  else
    echo "Battery Level: Unknown"
  fi
  
  if [ -f "/sys/class/power_supply/battery/status" ]; then
    BATT_STATUS=$(cat /sys/class/power_supply/battery/status)
    echo "Charging Status: $BATT_STATUS"
  else
    echo "Charging Status: Unknown"
  fi
 
  LIMIT_MODE="Unknown"
  
  if [ -f "/sys/class/power_supply/battery/store_mode" ]; then
    STORE_MODE=$(cat /sys/class/power_supply/battery/store_mode)
    if [ "$STORE_MODE" = "1" ] || [ "$STORE_MODE" = "80" ]; then
      LIMIT_MODE="80% Limit (Samsung)"
    else
      LIMIT_MODE="Full Charge (Samsung)"
    fi
  elif [ -f "/sys/devices/platform/soc/soc:google,charger/charge_stop_level" ]; then
    STOP_LEVEL=$(cat /sys/devices/platform/soc/soc:google,charger/charge_stop_level)
    if [ "$STOP_LEVEL" = "80" ]; then
      LIMIT_MODE="80% Limit (Pixel)"
    else
      LIMIT_MODE="Full Charge (Pixel)"
    fi
  elif [ -f "/sys/class/power_supply/battery/charge_control_limit" ]; then
    LIMIT=$(cat /sys/class/power_supply/battery/charge_control_limit)
    if [ "$LIMIT" = "80" ]; then
      LIMIT_MODE="80% Limit (Generic)"
    else
      LIMIT_MODE="Full Charge (Generic)"
    fi
  fi
  
  echo "Current Mode: $LIMIT_MODE"
  echo "-----------------------"
  echo "Log location: $LOG"
}

case "$1" in
  "limit")
    set_80_percent_charging
    ;;
  "adaptive")
    set_adaptive_charging
    ;;
  "status")
    check_status
    ;;
  *)
    usage
    ;;
esac
