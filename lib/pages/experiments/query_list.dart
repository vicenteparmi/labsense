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

class ExperimentsList extends StatelessWidget {
  final String query;

  const ExperimentsList({super.key, required this.query});

  Future<List<Map<String, dynamic>>> queryExperiments() async {
    Database db = await openMyDatabase();
    List<Map<String, dynamic>> result = await db.query(query);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          query == 'experiments'
              ? AppLocalizations.of(context)!.experiments
              : AppLocalizations.of(context)!.procedures,
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              Navigator.of(context).push(
                query == 'experiments'
                    ? MaterialPageRoute(
                        builder: (context) => const CreateExperiment(),
                      )
                    : MaterialPageRoute(
                        builder: (context) => const CreateModel(),
                      ),
              );
            },
            tooltip: query == 'experiments'
                ? AppLocalizations.of(context)!.createNewExperiment
                : AppLocalizations.of(context)!.createNewModel,
          ),
        ],
      ),
      body: FutureBuilder(
        future: queryExperiments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  if (query == 'experiments')
                    return ExperimentCard(
                      id: snapshot.data![index]['id'],
                      title: snapshot.data![index]['title'],
                      date:
                          DateTime.parse(snapshot.data![index]['created_time']),
                      description: snapshot.data![index]['brief_description'],
                    );
                  else if (query == 'procedures')
                    return ModelCard(
                      id: snapshot.data![index]['id'],
                      title: snapshot.data![index]['title'],
                      description: snapshot.data![index]['brief_description'],
                      type: snapshot.data![index]['model_type'],
                    );
                  else
                    return const SizedBox();
                },
              );
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: NothingFound(),
              );
            }
          }
        },
      ),
    );
  }
}
