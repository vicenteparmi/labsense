import 'package:flutter/material.dart';
import 'package:labsense/scripts/bluetooth.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/blinking_circle.dart';

class ConnectDevice extends StatefulWidget {
  const ConnectDevice({super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  // Controller for the menu
  final MenuController _menuController = MenuController();

  bool isScanning = false;

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
          });
        },
        child: isScanning
            ? const Icon(Icons.stop_rounded)
            : const Icon(Icons.refresh_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
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
                      if (Theme.of(context).platform ==
                          TargetPlatform.android) {
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
                onPressed: () {},
                icon: const Icon(Icons.bluetooth_disabled_rounded)),
          ],
        ),
      ),
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
                        const BlinkingCircle(),
                        const SizedBox(width: 4.0),
                        Text(
                          AppLocalizations.of(context)!.connected,
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
            BluetoothDevicesList(
                isScanning: ValueNotifier<bool>(isScanning),
                stopScan: () {
                  setState(() {
                    isScanning = false;
                  });
                },
                onConnect: () {}),
          ],
        );
      }),
    );
  }
}
