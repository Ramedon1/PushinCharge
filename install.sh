#!/system/bin/sh

OUTFD=$2
ZIPFILE=$3
. /data/adb/magisk/util_functions.sh

ui_print "- PushinCharge Installer"

api_level=$(getprop ro.build.version.sdk)
if [ "$api_level" -lt 35 ]; then
    ui_print "- Android 15+ required"
    abort
fi

# Detect capability to switch charging type
has_feature=false
if settings list global | grep -q "adaptive_charging"; then
    has_feature=true
fi
if settings list global | grep -q "charging_limit"; then
    has_feature=true
fi
if [ -e /sys/class/power_supply/battery/charge_stop_level ]; then
    has_feature=true
fi

if [ "$has_feature" = false ]; then
    ui_print "- Unable to detect charging control features"
    abort
fi

ui_print "- Installing PushinCharge"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
ui_print "- Done"
