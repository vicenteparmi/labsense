import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    super.key,
    required BluetoothDevice device,
    int? rssi,
    super.onTap,
    super.onLongPress,
    super.enabled,
    required bool selected,
  }) : super(
          leading: const Icon(Icons.devices),
          title: Text(device.name ?? ""),
          subtitle: Text(device.address.toString()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          tileColor: selected ? Colors.red[300] : Colors.transparent,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              device.isConnected
                  ? const Icon(Icons.import_export)
                  : const SizedBox(width: 0, height: 0),
              device.isBonded
                  ? const Icon(Icons.bluetooth_connected_rounded)
                  : const SizedBox(width: 0, height: 0),
              rssi != null
                  ? Container(
                      margin: const EdgeInsets.all(8.0),
                      child: DefaultTextStyle(
                        style: _computeTextStyle(rssi),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(rssi.toString()),
                            const Text('dBm'),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(width: 0, height: 0),
            ],
          ),
        );

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35) {
      return TextStyle(color: Colors.greenAccent[700]);
    } else if (rssi >= -45) {
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    } else if (rssi >= -55) {
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    } else if (rssi >= -65) {
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    } else if (rssi >= -75) {
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    } else if (rssi >= -85) {
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    } else {
      return const TextStyle(color: Colors.redAccent);
    }
  }
}
