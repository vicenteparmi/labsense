import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sends data to a Bluetooth device.
///
/// The [data] parameter represents the data to be sent to the device.
/// This function retrieves the device address from shared preferences,
/// establishes a Bluetooth connection to the device, and sends the data.
/// If the connection is successful, the data is encoded as ASCII and sent
/// to the device. Once all the data has been sent, the connection is closed.
/// If an error occurs during the connection or data sending process,
/// an error message is printed to the console.
Future<void> sendDataToDevice(String data) async {
  // Get address from shared preferences
  String address = await getConnectedDevice().then((value) => value[1]);

  BluetoothConnection.toAddress(address).then((connection) {
    print('Connected to the device');
    connection = connection;
    connection.output.add(Uint8List.fromList(ascii.encode(data)));
    connection.output.allSent.then((_) {
      connection.finish();
      print('Data sent to the device');
    });
  }).catchError((error) {
    print('Cannot connect, exception occurred');
    print(error);
  });
}

Future<List<String>> getConnectedDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> device = prefs.getStringList('connectedDevice') ?? [];
  return device;
}
