import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> sendDataToDevice(String data) async {
  // Get adress from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String adress = prefs.getString('deviceID') ?? '';

  BluetoothConnection.toAddress(adress).then((connection) {
    print('Connected to the device');
    connection = connection;
    connection.output.add(Uint8List.fromList(ascii.encode(data)));
    connection.output.allSent.then((_) {
      connection.finish();
      print('Data sent to the device');
    });
  }).catchError((error) {
    print('Cannot connect, exception occured');
    print(error);
  });
}
