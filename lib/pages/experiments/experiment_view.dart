import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labsense/pages/main_pages/home.dart';
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
    'steps': [],
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
        steps: experiment['steps'] ?? [],
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
  final List<Map<String, dynamic>> steps;

  const _ExperimentViewContent(
      {required this.experimentId,
      required this.title,
      required this.description,
      required this.lastUpdated,
      required this.createdTime,
      required this.steps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          Text(AppLocalizations.of(context)!.experimentTitle),
                      content: Text(title),
                      actions: <Widget>[
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.lastUpdated(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(createdTime))),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text(AppLocalizations.of(context)!.edit),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(AppLocalizations.of(context)!.delete),
                onTap: () {
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
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                // Navigate to the edit page
              } else if (value == 2) {
                // Delete the experiment
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Experiment description
            Card.outlined(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.experimentBriefDesc,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Procedures
            Card.outlined(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.procedures,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add_box_outlined)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    StepTracker(
                      unSelectedColor: Theme.of(context).colorScheme.primary,
                      dotSize: 12.0,
                      stepTrackerType: StepTrackerType.indexedVertical,
                      steps: steps
                          .map(
                            (step) => Steps(
                              title: step['title'],
                              description: step['brief_description'],
                            ),
                          )
                          .toList(),
                    ),
                    if (steps.isEmpty)
                      Text(
                        AppLocalizations.of(context)!.noProcedures,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
            // Results
            Card.outlined(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.results,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    // List of results
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Result $index',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Result description',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
