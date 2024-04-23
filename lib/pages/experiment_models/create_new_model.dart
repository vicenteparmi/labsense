import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/scripts/database.dart';
import 'package:sqflite/sqflite.dart';

class CreateModel extends StatefulWidget {
  const CreateModel({super.key});

  @override
  State<CreateModel> createState() => _CreateModelState();
}

class _CreateModelState extends State<CreateModel> {
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _briefDescriptionController =
      TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createNewExperiment),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.essentialInformation,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                            label: Text(
                                AppLocalizations.of(context)!.experimentTitle),
                            icon: const Icon(Icons.title_rounded),
                            border: const OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: _briefDescriptionController,
                        decoration: InputDecoration(
                          label: Text(AppLocalizations.of(context)!
                              .experimentBriefDesc),
                          icon: const Icon(Icons.description_rounded),
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        },
                      ),
                      ButtonBar(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          FilledButton(
                            onPressed: () {
                              // Validate form
                              if (_formKey.currentState!.validate()) {
                                // Save the experiment
                                saveExperiment(_titleController.text,
                                    _briefDescriptionController.text);
                                Navigator.pop(context);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.save),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ));
  }
}

Future<void> saveExperiment(String title, String briefDescription) async {
  // Save the experiment to the database
  Database db = await openMyDatabase();

  await db.insert('experiments', {
    'title': title,
    'brief_description': briefDescription,
    'created_time': DateTime.now().toString(),
    'last_updated': DateTime.now().toString(),
  });
}
