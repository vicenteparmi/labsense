import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/components/blinking_circle.dart';
import 'package:labsense/components/experiment_card_preview.dart';
import 'package:labsense/components/material_you_shape.dart';
import 'package:labsense/pages/experiments/add_new.dart';
import 'package:labsense/pages/main_pages/settings.dart';
import 'package:labsense/scripts/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connect_device/device_connection.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isConnected = false;
  String connectedDeviceName = '';

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

  Future<void> updateConnection(status, name) async {
    setState(() {
      isConnected = status;
      connectedDeviceName = name;
    });
  }

  @override
  void initState() {
    super.initState();

    // Clear shared preferences device tag
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('connectedDevice');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const CreateExperiment();
            }));
          },
          label: Text(AppLocalizations.of(context)!.newExperiment),
          icon: const Icon(Icons.add)),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: false,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SettingsPage();
                  }));
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              // Background is a colum with a icon and text below
              background: GestureDetector(
                onTapDown: (details) => scaleUp(),
                onTapCancel: () => scaleDown(),
                onTapUp: (details) => scaleDown(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConnectDevice(
                        updateConnection: (status, name) {
                          updateConnection(status, name);
                        },
                        oldName: connectedDeviceName,
                        oldStatus: isConnected,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'potentiostat_headline',
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 24.0),
                        // Image
                        Stack(alignment: Alignment.center, children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.identity()..scale(scale),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.center,
                            transformAlignment: Alignment.center,
                            child: const MaterialYouShape(),
                          ),
                          // Material You shape
                          Image.asset(
                            'assets/images/potentiostat.png',
                            height: 180.0,
                            fit: BoxFit.contain,
                            semanticLabel: 'Potentiostat picture',
                          ),
                        ]),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              size: 24.0,
                            ),
                          ],
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
                                  ? '${AppLocalizations.of(context)!.connected} ($connectedDeviceName)'
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
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: <Widget>[
                Container(
                  height: 24.0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                Container(
                  height: 24.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.science_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    AppLocalizations.of(context)!.experiments,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: openMyDatabase().then((value) {
              return value.query('experiments',
                  orderBy: 'last_updated DESC', limit: 3);
            }),
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                    child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                    child: Text('Error: ${snapshot.error}'));
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Map<String, dynamic> experiment = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: ExperimentCard(
                          id: experiment['id'],
                          title: experiment['title'],
                          date: DateTime.parse(experiment['created_time']),
                          description: experiment['brief_description'],
                        ),
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    AppLocalizations.of(context)!.models,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
