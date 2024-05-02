import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 225.0,
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
                            title: Text(
                                AppLocalizations.of(context)!.confirmDelete),
                            content: Text(AppLocalizations.of(context)!
                                .confirmExperimentDelete),
                            actions: <Widget>[
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.cancel),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.delete),
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
            flexibleSpace: FlexibleSpaceBar(
              title: RichText(
                  textAlign: TextAlign.center,
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
                padding: const EdgeInsets.all(80.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 48.0,
                  child: Icon(
                    Icons.science_outlined,
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
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.procedures,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    (MediaQuery.of(context).orientation == Orientation.portrait)
                        ? 2
                        : 4,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Card(
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
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
