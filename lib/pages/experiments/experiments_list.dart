import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/components/nothing_found_card.dart';
import 'package:sqflite/sqflite.dart';

import '../../components/experiment_card.dart';
import '../../scripts/database.dart';
import 'create_new_experiment.dart';

class ExperimentsList extends StatelessWidget {
  const ExperimentsList({super.key});

  Future<List<Map<String, dynamic>>> queryExperiments() async {
    Database db = await openMyDatabase();
    List<Map<String, dynamic>> result = await db.query('experiments');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.experiments),
        actions: [
          IconButton(
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const CreateExperiment()),
              );
            },
            tooltip: AppLocalizations.of(context)!.createNewExperiment,
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
                  return ExperimentCard(
                    id: snapshot.data![index]['id'],
                    title: snapshot.data![index]['title'],
                    date: DateTime.parse(snapshot.data![index]['created_time']),
                    description: snapshot.data![index]['brief_description'],
                  );
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
