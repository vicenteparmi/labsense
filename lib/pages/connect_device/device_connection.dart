import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/blinking_circle.dart';
import '../../scripts/bluetooth.dart';

class ConnectDevice extends StatefulWidget {
  const ConnectDevice({super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  // Controller for the menu
  final MenuController _menuController = MenuController();
  StreamSubscription<BlueScanResult>? _subscription;
  final List<BlueScanResult> _scanResults = [];
  bool isScanning = false;
  bool isConnected = false;
  String deviceID = '';

  @override
  void initState() {
    super.initState();
    _subscription = QuickBlue.scanResultStream.listen((result) {
      if (!_scanResults.any((r) => r.deviceId == result.deviceId)) {
        setState(() => _scanResults.add(result));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
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
            isScanning = !isScanning;
            if (isScanning) {
              // Clear the list of scan results
              setState(() {
                _scanResults.clear();
              });
              // Start scanning for devices
              scanForDevices();
              // Stop scanning after 10 seconds
              Future.delayed(const Duration(seconds: 10), () {
                stopScanning();
                setState(() {
                  isScanning = false;
                });
              });
            } else {
              stopScanning();
            }
          });
        },
        child: isScanning
            ? const Icon(Icons.stop_rounded)
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
      body: DynMouseScroll(builder: (context, controller, physics) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          physics: physics,
          children: [
            Hero(
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
                    Image.asset(
                      'assets/images/potentiostat.png',
                      height: 180.0,
                      fit: BoxFit.contain,
                      semanticLabel: 'Potentiostat picture',
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      AppLocalizations.of(context)!.potentiostat,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
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
            const SizedBox(height: 24.0),
            Text(AppLocalizations.of(context)!.availableDevices,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 16.0),
            // Build the list of available devices
            LayoutBuilder(builder: (context, constraints) {
              if (_scanResults.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noDevicesFound,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              } else {
                return Column(
                  children: _scanResults
                      .map((result) => ListTile(
                            title: Text('${result.name}(${result.rssi})'),
                            subtitle: Text(result.deviceId),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Connect to the device
                                connectToDevice(result.deviceId);
                                setState(() {
                                  isConnected = true;
                                  deviceID = result.deviceId;
                                });
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.connect),
                            ),
                          ))
                      .toList(),
                );
              }
            }),
          ],
        );
      }),
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
                    // Open Bluetooth settings on the device
                    if (Theme.of(context).platform == TargetPlatform.android) {
                      // Open Bluetooth settings on Android
                    }
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
                            // Disconnect from the device
                            String deviceID = await getConnectedDevice();

                            if (deviceID.isNotEmpty) {
                              disconnectFromDevice(deviceID);
                              disconnect();
                            } else {
                              // Show error message as snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .noDevicesConnected),
                                ),
                              );
                            }

                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
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
