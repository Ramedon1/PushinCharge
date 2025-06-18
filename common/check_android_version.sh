#!/system/bin/sh
# PushinCharge Android Version Checker
# This script helps determine if your device meets the minimum Android version requirement

echo "PushinCharge Android Version Checker"
echo "===================================="
echo ""

API_LEVEL=$(getprop ro.build.version.sdk)
ANDROID_VERSION=$(getprop ro.build.version.release)
DEVICE=$(getprop ro.product.model)
MANUFACTURER=$(getprop ro.product.manufacturer)

echo "Device: $DEVICE"
echo "Manufacturer: $MANUFACTURER"
echo "Android Version: $ANDROID_VERSION"
echo "API Level: $API_LEVEL"
echo ""

if [ "$API_LEVEL" -lt "15" ]; then
    echo "❌ ERROR: Your device does not meet the minimum requirements"
    echo "   PushinCharge requires Android API level 15 or higher"
    echo "   Your device is running API level $API_LEVEL (Android $ANDROID_VERSION)"
    echo ""
    echo "The module will not install on this device."
else
    echo "✓ SUCCESS: Your device meets the Android version requirement"
    echo "  PushinCharge requires Android API level 15 or higher"
    echo "  Your device is running API level $API_LEVEL (Android $ANDROID_VERSION)"
    echo ""
    echo "Note: The module will still check for compatible charging control paths"
    echo "during installation. This is just the version check."
fi

echo ""
echo "To check full compatibility, run the check_compatibility.sh script."
echo "===================================="
