import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:labsense/components/material_you_shape.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/scripts/bluetooth_com.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/blinking_circle.dart';
import 'bluetooth_device_list_entry.dart';

class ConnectDevice extends StatefulWidget {
  const ConnectDevice({super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  // Controller for the menu
  final MenuController _menuController = MenuController();

  // Scan results
  late StreamSubscription _subscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isScanning = true;
  bool isConnected = false;
  String deviceID = '';

  double scale = 1.0;

  // Animate scale up
  void scaleUp() {
    setState(() {
      scale = 1.2;
    });
  }

  // Animate scale down
  void scaleDown() {
    setState(() {
      scale = 1.0;
    });
  }

  // Discovery handlers
  void _restartDiscovery() {
    setState(() {
      results.clear();
      isScanning = true;
    });
    _startDiscovery();
  }

  void _startDiscovery() {
    _subscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else {
          results.add(r);
        }
      });
    });

    _subscription!.onDone(() {
      setState(() {
        isScanning = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Start discovery
    _startDiscovery();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.connectDevice),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (!isScanning) {
              // Clear the list of scan results
              _restartDiscovery();
            } else {
              // Stop the discovery
              _subscription.cancel();
              setState(() {
                isScanning = false;
              });
            }
          });
        },
        child: isScanning
            ? SizedBox(
                width: 24.0, // specify the width
                height: 24.0, // specify the height
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  strokeWidth: 2.0,
                ),
              )
            : const Icon(Icons.refresh_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomBluetoothBar(
          menuController: _menuController,
          disconnect: () {
            setState(() {
              isConnected = false;
            });
          }),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            GestureDetector(
              onTapDown: (details) => scaleUp(),
              onTapCancel: () => scaleDown(),
              onTapUp: (details) => scaleDown(),
              child: Hero(
                tag: 'potentiostat_headline',
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 24.0),
                      // Image
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.identity()..scale(scale),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.center,
                            transformAlignment: Alignment.center,
                            child: const MaterialYouShape(),
                          ),
                          Image.asset(
                            'assets/images/potentiostat.png',
                            height: 180.0,
                            fit: BoxFit.contain,
                            semanticLabel: 'Potentiostat picture',
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        AppLocalizations.of(context)!.potentiostat,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Dot
                          BlinkingCircle(
                            color: isConnected ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            isConnected
                                ? AppLocalizations.of(context)!.connected
                                : AppLocalizations.of(context)!.disconnected,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(AppLocalizations.of(context)!.availableDevices,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 16.0),
            // Build the list of available devices
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (BuildContext context, index) {
                  BluetoothDiscoveryResult result = results[index];
                  final device = result.device;
                  final address = device.address;
                  return BluetoothDeviceListEntry(
                    device: device,
                    rssi: result.rssi,
                    onTap: () async {
                      try {
                        bool bonded = false;
                        if (device.isBonded) {
                          debugPrint('Unbonding from ${device.address}...');
                          await FlutterBluetoothSerial.instance
                              .removeDeviceBondWithAddress(address);
                          debugPrint(
                              'Unbonding from ${device.address} has succed');
                          setState(() {
                            isConnected = false;
                          });
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('deviceID', '');
                          });
                        } else {
                          debugPrint('Bonding with ${device.address}...');
                          bonded = (await FlutterBluetoothSerial.instance
                              .bondDeviceAtAddress(address))!;
                          debugPrint(
                              'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
                          setState(() {
                            isConnected = bonded;
                          });

                          // Save to shared preferences
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('deviceID', bonded ? address : '');
                          });
                        }
                        setState(() {
                          results[results.indexOf(result)] =
                              BluetoothDiscoveryResult(
                                  device: BluetoothDevice(
                                    name: device.name ?? '',
                                    address: address,
                                    type: device.type,
                                    bondState: bonded
                                        ? BluetoothBondState.bonded
                                        : BluetoothBondState.none,
                                  ),
                                  rssi: result.rssi);
                        });
                      } catch (ex) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error occured while bonding'),
                              content: Text(ex.toString()),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBluetoothBar extends StatelessWidget {
  const BottomBluetoothBar({
    super.key,
    required MenuController menuController,
    required this.disconnect,
  }) : _menuController = menuController;

  final MenuController _menuController;
  final Function disconnect;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Three dots menu
          MenuAnchor(
              controller: _menuController,
              menuChildren: <PopupMenuEntry>[
                PopupMenuItem(
                  onTap: () {
                    // Send data to the device
                    sendDataToDevice('Hello from Labsense!');
                  },
                  child: ListTile(
                    leading: const Icon(Icons.bluetooth_rounded),
                    title: Text(
                        AppLocalizations.of(context)!.openBluetoothSettings),
                  ),
                ),
              ],
              child: IconButton(
                onPressed: () {
                  _menuController.open();
                },
                icon: const Icon(Icons.more_vert_rounded),
              )),
          // Disconnect button
          IconButton(
              onPressed: () {
                // Show popup to confirm disconnection
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                          Text(AppLocalizations.of(context)!.disconnectDevice),
                      content: Text(AppLocalizations.of(context)!
                          .disconnectDeviceMessage),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            // // Disconnect from the device
                            // String deviceID = await getConnectedDevice();

                            // if (deviceID.isNotEmpty) {
                            //   disconnectFromDevice(deviceID);
                            //   disconnect();
                            // } else {
                            //   // Show error message as snackbar
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text(AppLocalizations.of(context)!
                            //           .noDevicesConnected),
                            //     ),
                            //   );
                            // }

                            // // ignore: use_build_context_synchronously
                            // Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.disconnect),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.bluetooth_disabled_rounded)),
        ],
      ),
    );
  }
}
