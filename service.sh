#!/system/bin/sh

PATH=/system/bin:/system/xbin:$PATH

log_tag="PushinCharge"

enable_adaptive() {
    if settings get global adaptive_charging_enabled >/dev/null 2>&1; then
        settings put global adaptive_charging_enabled 1
        log -t "$log_tag" "Adaptive charging enabled via settings"
    fi
    if settings get global charging_limit >/dev/null 2>&1; then
        settings put global charging_limit 100
        log -t "$log_tag" "Charging limit set to 100% via settings"
    fi
    if [ -e /sys/class/power_supply/battery/charge_stop_level ]; then
        echo 100 > /sys/class/power_supply/battery/charge_stop_level
        log -t "$log_tag" "Charge stop level set to 100% via sysfs"
    fi
}

enable_limit80() {
    if settings get global adaptive_charging_enabled >/dev/null 2>&1; then
        settings put global adaptive_charging_enabled 0
        log -t "$log_tag" "Adaptive charging disabled"
    fi
    if settings get global charging_limit >/dev/null 2>&1; then
        settings put global charging_limit 80
        log -t "$log_tag" "Charging limit set to 80% via settings"
    fi
    if [ -e /sys/class/power_supply/battery/charge_stop_level ]; then
        echo 80 > /sys/class/power_supply/battery/charge_stop_level
        log -t "$log_tag" "Charge stop level set to 80% via sysfs"
    fi
}

while true; do
    hour=$(date +%H)
    if [ "$hour" -ge 3 ] && [ "$hour" -lt 10 ]; then
        enable_adaptive
    else
        enable_limit80
    fi
    sleep 3600
done
