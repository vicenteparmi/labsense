import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDevicesList extends StatefulWidget {
  final ValueNotifier<bool> isScanning;
  final Function stopScan;
  final Function onConnect;

  const BluetoothDevicesList({
    super.key,
    required this.isScanning,
    required this.stopScan,
    required this.onConnect,
  });

  @override
  BluetoothDevicesListState createState() => BluetoothDevicesListState();
}

class BluetoothDevicesListState extends State<BluetoothDevicesList> {
  final List devices = [];

  Future<bool> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetooth] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<void> bluetoothOn() async {
    QuickBlue.isBluetoothAvailable().then((isAvailable) {
      if (!isAvailable) {
        // Open Bluetooth settings on the device
        if (Theme.of(context).platform == TargetPlatform.android) {
          // Open Bluetooth settings on Android
          Permission.bluetooth.request();
        }
      } else {
        print('Bluetooth is on');
      }
    });
  }

  Future<void> scanDevices() async {
    print('Scanning for devices');
    devices.clear();

    QuickBlue.scanResultStream.listen((result) {
      // Add the device to the list
      setState(() {
        devices.add(result);
      });
    });

    QuickBlue.startScan();

    // Stop scanning after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      QuickBlue.stopScan();
      widget.stopScan();
    });
  }

  @override
  void initState() {
    super.initState();

    // Check if the app has the necessary permissions
    checkPermissions().then((hasPermissions) {
      if (hasPermissions) {
        bluetoothOn();
      }
    });

    // Listen to the isScanning value
    widget.isScanning.addListener(() {
      if (widget.isScanning.value) {
        scanDevices();
      } else {
        QuickBlue.stopScan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isScanning.value)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (devices.isEmpty && !widget.isScanning.value)
          Center(
            child: Text(AppLocalizations.of(context)!.noDevicesFound),
          ),
        for (var device in devices)
          ListTile(
            title: Text(device.name),
            subtitle: Text(device.address),
            onTap: () {
              widget.stopScan();
              widget.onConnect(device);
            },
          ),
      ],
    );
  }
}
