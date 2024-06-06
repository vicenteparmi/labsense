import 'package:flutter/material.dart';
import 'package:labsense/pages/main_pages/home.dart';
import 'package:labsense/scripts/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This page displays the details of a model, including its title, description, and procedure.
class ModelView extends StatefulWidget {
  final int modelId;

  const ModelView({super.key, required this.modelId});

  @override
  State<ModelView> createState() => _ModelViewState();
}

class _ModelViewState extends State<ModelView> {
  Map<String, dynamic> model = {
    'title': 'Carregando...',
    'description': '',
    'type': '',
  };

  Future<void> queryProcedureData() async {
    Database db = await openMyDatabase();
    List<Map<String, dynamic>> result = await db.query(
      'procedures',
      where: 'id = ?',
      whereArgs: [widget.modelId.toString()],
    );

    if (result.isNotEmpty) {
      setState(() {
        model = result.first;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    queryProcedureData();
  }

  @override
  Widget build(BuildContext context) {
    if (model['title'] == 'Carregando...') {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.loading),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return _ModelViewContent(model);
    }
  }
}

class _ModelViewContent extends StatelessWidget {
  const _ModelViewContent(
    this.model,
  );

  final Map<String, dynamic> model;

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
                      content: Text(model['title']),
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
                model['title'],
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              // PopupMenuItem(
              //   value: 1,
              //   child: Text(AppLocalizations.of(context)!.edit),
              // ),
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
                              // Delete the experiment from the database
                              openMyDatabase().then((db) {
                                db.delete(
                                  'procedures',
                                  where: 'id = ?',
                                  whereArgs: [model['id']],
                                );
                              });

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
              if (value == 2) {
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
                        model['brief_description'],
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
                          AppLocalizations.of(context)!.data,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        // IconButton(
                        //     onPressed: () {},
                        //     icon: const Icon(Icons.add_box_outlined)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Card with list tiles for every propertie
                    ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.initialPotential,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(model['initial_potential']),
                        leading: const Icon(
                          Icons.vertical_align_bottom_rounded,
                        )),
                    ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.finalPotential,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(model['final_potential']),
                        leading: const Icon(
                          Icons.vertical_align_top_rounded,
                        )),
                    ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.startPotential,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(model['start_potential']),
                        leading: const Icon(
                          Icons.start_rounded,
                        )),
                    ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.scanRate,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(model['scan_rate']),
                        leading: const Icon(
                          Icons.speed_rounded,
                        )),
                    ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.cycleCount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(model['cycle_count']),
                        leading: const Icon(
                          Icons.loop_rounded,
                        )),
                    ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.sweepDirection,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(model['sweep_direction'] == 1
                            ? AppLocalizations.of(context)!
                                .sweepDirectionForward
                            : AppLocalizations.of(context)!
                                .sweepDirectionBackward),
                        leading: const Icon(
                          Icons.swap_horiz_rounded,
                        )),
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

// Procedure list item
class _ProcedureListItem extends StatelessWidget {
  const _ProcedureListItem({
    required this.content,
    required this.onTap,
  });

  final Map<String, dynamic> content;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content['title'],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                content['brief_description'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12.0),
              // Table with parameters
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                border: TableBorder.all(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                children: [
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context)!.initialPotential),
                      Text(content['initial_potential']),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context)!.finalPotential),
                      Text(content['final_potential']),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context)!.scanRate),
                      Text(content['scan_rate']),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context)!.cycleCount),
                      Text(content['cycle_count']),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context)!.sweepDirection),
                      Text(content['sweep_direction'] == 1
                          ? AppLocalizations.of(context)!.sweepDirectionForward
                          : AppLocalizations.of(context)!
                              .sweepDirectionBackward),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
