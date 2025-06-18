# PushinCharge - Smart Battery Charging Module

## Description
PushinCharge is a Magisk module that automatically switches between two charging modes based on the time of day to optimize battery health and charging behavior on Android devices.

### Features:
- **Daytime Mode (4 AM - 11 PM):** Limits battery charging to 80% to preserve battery health during daily use
- **Nighttime Mode (11 PM - 4 AM):** Enables adaptive charging for a full but battery-friendly overnight charge
- **Compatible with Android 15+ devices only**
- **Automatic switching based on time**
- **Manual mode switching available**
- **Battery health preservation**

## How It Works
The module uses system-level controls to modify charging behavior:
1. During daytime hours (4 AM - 11 PM), it activates the 80% charging limit to reduce battery stress
2. During nighttime hours (11 PM - 4 AM), it enables adaptive charging for optimal overnight charging
3. The module checks and updates the charging mode every 15 minutes

## Requirements
- Android 15 or higher (strict requirement)
- Magisk installed (v19.0 or higher)
- Root access
- Device must have compatible charging control paths

# PushinCharge Installation Guide
## Installation via Magisk Manager

1. **Download module from Realeses**

2. **Install via Magisk Manager**
   - Open Magisk Manager on your Android device
   - Tap on the "Modules" section
   - Tap on the "+" button at the bottom
   - Browse and select the `PushinCharge_v1.1.zip` file you created
   - The module will check your device compatibility
   - If compatible, installation will complete
   - Tap "Reboot" when prompted

3. **Verify installation**
   - After reboot, open Magisk Manager
   - Check that "PushinCharge" appears in the Modules list with a checkmark
   - The module will automatically start working

## Compatibility Check

You can manually check if your device is compatible before installation:

1. **Extract the module ZIP file on your computer**

2. **Push the compatibility checker to your device:**
   ```
   adb push common/check_compatibility.sh /sdcard/
   ```
3. **Run the compatibility checker:**
   ```
   adb shell "su -c 'sh /sdcard/check_compatibility.sh'"
   ```

## Manual Mode Switching

You can manually switch charging modes using Terminal Emulator or any terminal app with root access:

```
# Switch to 80% limit mode
su -c /data/adb/modules/PushinCharge/common/manual_switch.sh limit

# Switch to adaptive charging mode
su -c /data/adb/modules/PushinCharge/common/manual_switch.sh adaptive

# Check current charging status
su -c /data/adb/modules/PushinCharge/common/manual_switch.sh status
```

## Troubleshooting

If the module fails to install:

1. **Check Android version:**
   - This module requires Android 15 or higher
   - Check your version in Settings > About phone

2. **Check device compatibility:**
   - Some devices don't have the necessary charging control paths
   - Use the compatibility checker as described above

3. **Check logs:**
   - Install logs in Magisk Manager
   - Compatibility check log: `/data/local/tmp/PushinCharge/compatibility_check.txt`

### Check Device Compatibility
Before installation, you can check if your device meets the requirements:

```
# Check Android version only
su -c /data/adb/modules/PushinCharge/common/check_android_version.sh

# Check complete compatibility (version + charging paths)
su -c /data/adb/modules/PushinCharge/common/check_compatibility.sh
```
   - Open Magisk Manager on your Android device
   - Tap on the "Modules" section
   - Tap on the "+" button at the bottom
   - Browse and select the `PushinCharge.zip` file you created
   - Wait for the installation to complete
   - Tap "Reboot" when prompted

3. **Verify installation**
   - After reboot, open Magisk Manager
   - Check that "PushinCharge" appears in the Modules list with a checkmark
   - The module will automatically start working

## Manual Mode Switching

You can manually switch charging modes using Terminal Emulator or any terminal app with root access:

```
# Switch to 80% limit mode
su -c /data/adb/modules/PushinCharge/common/manual_switch.sh limit

# Switch to adaptive charging mode
su -c /data/adb/modules/PushinCharge/common/manual_switch.sh adaptive

# Check current charging status
su -c /data/adb/modules/PushinCharge/common/manual_switch.sh status
```
## Troubleshooting

If the module doesn't seem to be working:

1. **Check logs**
   ```
   su -c cat /data/local/tmp/PushinCharge/charging_log.txt
   ```

2. **Check compatibility**
   ```
   su -c /data/adb/modules/PushinCharge/common/check_compatibility.sh
   ```


## License
This project is licensed under the MIT License - see the LICENSE file for details.
