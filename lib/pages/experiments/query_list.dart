// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/components/model_card.dart';
import 'package:labsense/components/nothing_found_card.dart';
import 'package:labsense/pages/experiment_models/create_new_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../components/experiment_card.dart';
import '../../scripts/database.dart';
import 'create_new_experiment.dart';

class ExperimentsList extends StatefulWidget {
  final String query;

  const ExperimentsList({super.key, required this.query});

  @override
  State<ExperimentsList> createState() => _ExperimentsListState();
}

class _ExperimentsListState extends State<ExperimentsList> {
  List<Map<String, dynamic>> _data = [];
  int _filterOption = 2;
  bool _ascending = false;

  Future<void> queryExperiments() async {
    // Order by
    String orderBy;
    String asc;

    if (_filterOption == 0) {
      orderBy = 'title';
    } else if (_filterOption == 1) {
      orderBy = 'created_time';
    } else {
      orderBy = 'last_updated';
    }

    if (_ascending) {
      asc = 'ASC';
    } else {
      asc = 'DESC';
    }

    orderBy += ' $asc';

    Database db = await openMyDatabase();
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
        await db.query(widget.query, orderBy: orderBy));

    await db.close();
    setState(() {
      _data = result;
    });
  }

  @override
  void initState() {
    super.initState();

    // Set the filter option to title if is querying for procedures
    if (widget.query == 'procedures') {
      _filterOption = 0;
    }

    _ascending = false;
    queryExperiments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.query == 'experiments'
              ? AppLocalizations.of(context)!.experiments
              : AppLocalizations.of(context)!.models,
        ),
        actions: [
          // Filter button
          IconButton(
            icon: Icon(Icons.filter_list,
                color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // mode title
                      Text(
                        AppLocalizations.of(context)!.filterBy,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      // List tiles
                      if (widget.query == 'experiments')
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          leading: const Icon(Icons.title),
                          selected: _filterOption == 0,
                          selectedTileColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          onTap: () {
                            setState(() {
                              _filterOption = 0;
                            });
                            queryExperiments();
                            Navigator.of(context).pop();
                          },
                        ),
                      if (widget.query == 'experiments')
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.creationDate,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          leading: const Icon(Icons.create_new_folder),
                          selected: _filterOption == 1,
                          selectedTileColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          onTap: () {
                            setState(() {
                              _filterOption = 1;
                            });
                            queryExperiments();
                            Navigator.of(context).pop();
                          },
                        ),
                      if (widget.query == 'experiments')
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.editDate,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          leading: const Icon(Icons.edit),
                          selected: _filterOption == 2,
                          selectedTileColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          onTap: () {
                            setState(() {
                              _filterOption = 2;
                            });
                            queryExperiments();
                            Navigator.of(context).pop();
                          },
                        ),
                      // Ascending or descending switch
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context)!.order,
                        ),
                        subtitle: Text(
                          _ascending
                              ? AppLocalizations.of(context)!.ascending
                              : AppLocalizations.of(context)!.descending,
                        ),
                        value: _ascending,
                        onChanged: (value) => setState(() {
                          _ascending = value;
                          Navigator.of(context).pop();
                          queryExperiments();
                        }),
                      ),
                      const SizedBox(height: 16.0)
                    ],
                  );
                },
              );
            },
            tooltip: AppLocalizations.of(context)!.filter,
          ),
          IconButton(
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              Navigator.of(context).push(
                widget.query == 'experiments'
                    ? MaterialPageRoute(
                        builder: (context) => const CreateExperiment(),
                      )
                    : MaterialPageRoute(
                        builder: (context) => const CreateModel(),
                      ),
              );
            },
            tooltip: widget.query == 'experiments'
                ? AppLocalizations.of(context)!.createNewExperiment
                : AppLocalizations.of(context)!.createNewModel,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await queryExperiments();
        },
        child: _data.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: NothingFound(),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  if (widget.query == 'experiments')
                    return ExperimentCard(
                      id: _data[index]['id'],
                      title: _data[index]['title'],
                      date: DateTime.parse(_data[index]['created_time']),
                      description: _data[index]['brief_description'],
                    );
                  else if (widget.query == 'procedures')
                    return ModelCard(
                      id: _data[index]['id'],
                      title: _data[index]['title'],
                      description: _data[index]['brief_description'],
                      type: _data[index]['model_type'],
                    );
                  else
                    return const SizedBox();
                },
              ),
      ),
    );
  }
}
