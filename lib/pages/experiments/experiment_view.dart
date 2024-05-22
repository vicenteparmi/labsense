import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labsense/components/no_connected_devices_dialog.dart';
import 'package:labsense/pages/experiment_run/set_run_info.dart';
import 'package:labsense/pages/main_pages/home.dart';
import 'package:labsense/scripts/bluetooth_com.dart';
import 'package:labsense/scripts/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:step_tracker/step_tracker.dart';

class ExperimentView extends StatefulWidget {
  final int experimentId;

  const ExperimentView({super.key, required this.experimentId});

  @override
  State<ExperimentView> createState() => _ExperimentViewState();
}

class _ExperimentViewState extends State<ExperimentView> {
  Map<String, dynamic> experiment = {
    'title': 'Carregando...',
    'description': '',
    'last_updated': '',
    'created_time': '',
    'icon': '',
    'procedures': [],
  };

  Future<void> queryExperimentData() async {
    Database db = await openMyDatabase();
    List<Map<String, dynamic>> result = await db.query(
      'experiments',
      where: 'id = ?',
      whereArgs: [widget.experimentId.toString()],
    );

    if (result.isNotEmpty) {
      setState(() {
        experiment = result.first;
      });
    }

    // Query the associated procedures from the 'custom_procedures' table
    List<Map<String, dynamic>> procedureResult = await db.query(
      'custom_procedures',
      where: 'experiment_id = ?',
      whereArgs: [widget.experimentId.toString()],
      orderBy:
          'experiment_order ASC', // Order the results by the 'order' column
    );

    if (procedureResult.isNotEmpty) {
      setState(() {
        experiment = Map<String, dynamic>.from(experiment);
        experiment['procedures'] =
            List<Map<String, dynamic>>.from(procedureResult);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    queryExperimentData();
  }

  @override
  Widget build(BuildContext context) {
    if (experiment['title'] == 'Carregando...') {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.loading),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return _ExperimentViewContent(
        experimentId: widget.experimentId,
        title: experiment['title'] ?? '',
        description: experiment['brief_description'] ?? '',
        lastUpdated: experiment['last_updated'] ?? '',
        createdTime: experiment['created_time'] ?? '',
        icon: IconData(int.parse(experiment['icon'] ?? '0xe5c4'),
            fontFamily: 'MaterialIcons'),
        steps: experiment['procedures'] ?? [],
      );
    }
  }
}

class _ExperimentViewContent extends StatelessWidget {
  final int experimentId;
  final String title;
  final String description;
  final String lastUpdated;
  final String createdTime;
  final IconData icon;
  final List<Map<String, dynamic>> steps;

  const _ExperimentViewContent(
      {required this.experimentId,
      required this.title,
      required this.description,
      required this.lastUpdated,
      required this.createdTime,
      required this.icon,
      required this.steps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check if the device is connected
          getConnectedDevice().then((value) {
            print("Connected devices: $value");
            if (value.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const NoConnectedDevicesDialog();
                  });
              return;
            }
          });

          // Navigate to the experiment procedure page
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SetRunInfo(experimentId: experimentId),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = const Offset(1.0, 0.0);
                var end = Offset.zero;
                var tween = Tween(begin: begin, end: end);

                var curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );

                return SlideTransition(
                  position: tween.animate(curvedAnimation),
                  child: child,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.play_arrow_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  // Delete this record from the database
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            Text(AppLocalizations.of(context)!.confirmDelete),
                        content: Text(AppLocalizations.of(context)!
                            .confirmExperimentDelete),
                        actions: <Widget>[
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onError,
                                backgroundColor:
                                    Theme.of(context).colorScheme.error),
                            child: Text(AppLocalizations.of(context)!.delete),
                            onPressed: () {
                              openMyDatabase().then((value) => value.delete(
                                    'experiments',
                                    where: 'id = ?',
                                    whereArgs: [experimentId.toString()],
                                  ));
                              Navigator.of(context).pop();
                              // Push and remove all previous routes
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete_forever_rounded)),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_rounded),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 225.0,
            flexibleSpace: FlexibleSpaceBar(
              title: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontSize: 16.0),
                      ),
                      TextSpan(
                        text:
                            '\n${AppLocalizations.of(context)!.lastUpdated(DateFormat('dd/MM/yyyy').format(DateTime.parse(createdTime)))}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 10.0),
                      ),
                    ],
                  )),
              background: Padding(
                padding: const EdgeInsets.all(92.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 48.0,
                  child: Icon(
                    icon,
                    size: 48.0, // Reduced size
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              titlePadding: const EdgeInsetsDirectional.only(bottom: 16.0),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ExpansionTile(
                  title: Text(
                    AppLocalizations.of(context)!.experimentBriefDesc,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.clickToAlternate,
                  ),
                  leading: const Icon(Icons.description_outlined),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  childrenPadding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, bottom: 24.0),
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                // Creation date
                ListTile(
                  title: Text(AppLocalizations.of(context)!.creationDate),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(createdTime)),
                  ),
                  leading: const Icon(Icons.access_time_rounded),
                  titleTextStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(context)!.procedures,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StepTracker(
                dotSize: 15.0,
                selectedColor: Theme.of(context).colorScheme.primary,
                steps: [
                  for (var step in steps)
                    Steps(
                      title: Text(step['title']),
                      description: step['brief_description'].length > 120
                          ? step['brief_description'].substring(0, 120) + '...'
                          : step['brief_description'],
                      state: TrackerState.complete,
                    )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(context)!.results,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
