import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/scripts/database.dart';
import 'package:sqflite/sqflite.dart';

class CreateExperiment extends StatefulWidget {
  const CreateExperiment({super.key});

  @override
  State<CreateExperiment> createState() => _CreateExperimentState();
}

class _CreateExperimentState extends State<CreateExperiment> {
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _briefDescriptionController =
      TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // List of icons to choose from
  final List<IconData> icons = [
    Icons.science_rounded,
    Icons.biotech_rounded,
    Icons.microwave_rounded,
    Icons.lightbulb_rounded,
    Icons.bolt_rounded,
    Icons.bubble_chart_rounded,
    Icons.bug_report_rounded,
    Icons.water_drop_rounded,
    Icons.air_rounded,
    Icons.thermostat_rounded,
    Icons.waves_rounded,
    Icons.wb_sunny_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
    Icons.support,
    Icons.emoji_objects_rounded,
    Icons.emoji_nature_rounded,
    Icons.emoji_food_beverage_rounded,
  ];

  // Selected icon
  IconData selectedIcon = Icons.science_rounded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context)!.createNewExperiment,
                  style: Theme.of(context).textTheme.titleLarge),
              background: Icon(selectedIcon,
                  size: 92.0, color: Theme.of(context).colorScheme.primary),
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              titlePadding: const EdgeInsetsDirectional.only(
                bottom: 16.0,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .essentialInformation,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12.0),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                                label: Text(AppLocalizations.of(context)!
                                    .experimentTitle),
                                icon: const Icon(Icons.title_rounded),
                                border: const OutlineInputBorder()),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .requiredField;
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
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24.0),
                          Text(AppLocalizations.of(context)!.customization,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12.0),
                          Text(AppLocalizations.of(context)!.experimentIcon,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.normal)),
                          const SizedBox(height: 8.0),
                          // Scrollable row to select the experiment icon
                          SizedBox(
                            height: 60.0, // Adjust this value as needed
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: icons.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: CircleAvatar(
                                    backgroundColor: selectedIcon ==
                                            icons[index]
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    radius: 28.0,
                                    child: IconButton(
                                      icon: Icon(icons[index],
                                          color: selectedIcon == icons[index]
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant),
                                      iconSize: 32.0,
                                      onPressed: () {
                                        setState(() {
                                          selectedIcon = icons[index];
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          ButtonBar(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child:
                                    Text(AppLocalizations.of(context)!.cancel),
                              ),
                              FilledButton(
                                onPressed: () {
                                  // Validate form
                                  if (_formKey.currentState!.validate()) {
                                    // Save the experiment
                                    saveExperiment(_titleController.text,
                                        _briefDescriptionController.text);
                                    Navigator.pop(context);
                                  } else {
                                    HapticFeedback.mediumImpact();
                                  }
                                },
                                child: Text(AppLocalizations.of(context)!.save),
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
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
