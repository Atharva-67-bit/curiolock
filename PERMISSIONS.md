# BLE permissions for the real (non-mock) build

The proximity scan + pairing needs Bluetooth permissions. In **mock mode**
(`BleService.useMock = true`) none of this matters — it only applies once you
flip to the real ESP32. Add these after `flutter create .`.

## Android — `android/app/src/main/AndroidManifest.xml`
Add inside `<manifest>` (above `<application>`):
```xml
<!-- Android 12+ (API 31+) -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Android 11 and below -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
```
Also set `minSdkVersion 21` (or higher) in `android/app/build.gradle`.

At runtime, request `BLUETOOTH_SCAN` + `BLUETOOTH_CONNECT` before `startScan()`
(use the `permission_handler` package, or flutter_blue_plus's helpers).

## iOS — `ios/Runner/Info.plist`
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>CurioLock uses Bluetooth to find and unlock your Smart Vault.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>CurioLock connects to your Smart Vault over Bluetooth.</string>
```

> Test BLE on a **real phone** — emulators/simulators have no Bluetooth radio.
> Bluetooth must be turned ON; on Android, Location is also required to scan on
> versions ≤ 11.
