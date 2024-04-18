// Check bluetooth permissions
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkBluetoothPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();

  bool allGranted = statuses.values.every((status) => status.isGranted);

  return allGranted;
}

// Scan for devices
Future<void> scanForDevices() async {
  QuickBlue.startScan();
}

// Stop scanning for devices
void stopScanning() {
  QuickBlue.stopScan();
}

// Connect to bluetooth device
Future<void> connectToDevice(deviceId) async {
  // Save to shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('connectedDevice', deviceId);

  return QuickBlue.connect(deviceId);
}

// Disconnect from bluetooth device
void disconnectFromDevice(deviceId) {
  // Remove from shared preferences
  SharedPreferences.getInstance().then((prefs) {
    prefs.setString('connectedDevice', '');
  });
  return QuickBlue.disconnect(deviceId);
}

// Get connected device from shared preferences
Future<String> getConnectedDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('connectedDevice') ?? '';
}
