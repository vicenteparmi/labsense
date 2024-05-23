import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/pages/experiments/edit_custom_procedure.dart';
import 'package:labsense/scripts/database.dart';
import 'package:reorderables/reorderables.dart';
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
    Icons.filter_vintage_rounded,
    Icons.grass_rounded,
    Icons.eco_rounded,
    Icons.park_rounded,
    Icons.science_outlined,
    Icons.health_and_safety_rounded,
    Icons.psychology_rounded,
    Icons.spa_rounded,
    Icons.solar_power_rounded,
    Icons.water_damage_rounded,
    Icons.fireplace_rounded,
    Icons.reduce_capacity_rounded,
    Icons.cleaning_services_rounded,
    Icons.compost_rounded,
    Icons.coronavirus_rounded,
    Icons.masks_rounded,
    Icons.sanitizer_rounded,
    Icons.soap_rounded,
    Icons.pest_control_rounded,
    Icons.pest_control_rodent_rounded,
  ];

  // Selected icon
  IconData selectedIcon = Icons.science_rounded;

  // Procedures on this experiment
  List<Map<String, Object?>> procedures = [];

  // Add a new procedure
  void _openAddProcedureDialog(BuildContext context) {
    FocusScope.of(context).unfocus();

    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      builder: (BuildContext context) {
        return FutureBuilder(
            future: _proceduresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == snapshot.data!.length) {
                      return Card.filled(
                        margin: const EdgeInsets.only(
                            top: 8.0, left: 24.0, right: 24.0, bottom: 24.0),
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: ListTile(
                          title: Text(
                              AppLocalizations.of(context)!.addProcedureInfo,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer)),
                          leading: Icon(Icons.info_outlined,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer),
                        ),
                      );
                    }
                    if (snapshot.data!.isEmpty || snapshot.data == null) {
                      return ListTile(
                        title: Text(AppLocalizations.of(context)!.noProcedures),
                        subtitle:
                            Text(AppLocalizations.of(context)!.noProcedures),
                      );
                    } else {
                      // Other items
                      return ListTile(
                        title: Text(snapshot.data![index]['title'].toString()),
                        subtitle: Text(
                            snapshot.data![index]['brief_description']
                                .toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(
                            snapshot.data![index]['model_type'] ==
                                    'cyclic_voltammetry'
                                ? Icons.restart_alt_rounded
                                : Icons.timeline,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        onTap: () {
                          // Add the procedure to the experiment after grabbing it from the database
                          openMyDatabase().then((value) {
                            setState(() {
                              procedures.add(snapshot.data![index]);
                            });
                          });

                          setState(() {
                            procedures = procedures;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                );
              }
            });
      },
      showDragHandle: true,
      useSafeArea: true,
    );
  }

  late Future _proceduresFuture;

  Future<bool> _confirmDiscard(BuildContext context) async {
    // Show a dialog to confirm the discard if any changes were made
    if (_titleController.text.isNotEmpty ||
        _briefDescriptionController.text.isNotEmpty ||
        procedures.isNotEmpty ||
        selectedIcon != Icons.science_rounded) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.discardChanges),
              content: Text(AppLocalizations.of(context)!.discardChangesInfo),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  // Red color for the discard button
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: Text(AppLocalizations.of(context)!.discard),
                ),
              ],
            );
          });
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _proceduresFuture =
        openMyDatabase().then((value) => value.query('procedures'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Call your custom back action here
                _confirmDiscard(context);
              },
            ),
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
                Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!
                                      .essentialInformation,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                    label: Text(AppLocalizations.of(context)!
                                        .experimentTitle),
                                    icon: const Icon(Icons.title_rounded),
                                    border: const OutlineInputBorder()),
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12.0),
                              Text(AppLocalizations.of(context)!.experimentIcon,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.normal)),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                        // Scrollable row to select the experiment icon
                        SizedBox(
                          height: 60.0, // Adjust this value as needed
                          child: Scrollbar(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: icons.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return const SizedBox(width: 24.0);
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          selectedIcon == icons[index - 1]
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.transparent,
                                      radius: 28.0,
                                      child: IconButton(
                                        icon: Icon(icons[index - 1],
                                            color:
                                                selectedIcon == icons[index - 1]
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant),
                                        iconSize: 32.0,
                                        onPressed: () {
                                          setState(() {
                                            selectedIcon = icons[index - 1];
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.procedures,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text(AppLocalizations.of(context)!.dragToReorder,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                              const SizedBox(height: 12.0)
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ReorderableWrap(
                spacing: 8.0,
                runSpacing: 8.0,
                maxMainAxisCount: 2,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > procedures.length) {
                      newIndex = procedures.length;
                    }
                    final item = procedures.removeAt(oldIndex);
                    procedures.insert(newIndex, item);
                  });
                },
                children: List.generate(
                  procedures.length,
                  (index) => Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () {
                        // Open modal to change parameters
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          useSafeArea: true,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return EditCustomProcedure(
                              procedure: procedures[index],
                              index: index,
                              removeThis: (int index) {
                                setState(() {
                                  procedures.removeAt(index);
                                });
                              },
                              updateThis:
                                  (Map<String, Object?> updatedProcedure) {
                                setState(() {
                                  procedures[index] = updatedProcedure;
                                });
                              },
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 32.0,
                        height: 130.0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Icon(
                                  procedures[index]['model_type'] ==
                                          'cyclic_voltammetry'
                                      ? Icons.restart_alt_rounded
                                      : Icons.timeline,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                procedures[index]['title'].toString(),
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _openAddProcedureDialog(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  AppLocalizations.of(context)!.addProcedure,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            sliver: SliverToBoxAdapter(
              child: ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      // Call your custom back action here
                      _confirmDiscard(context);
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      // Validate form
                      if (_formKey.currentState!.validate() &&
                          procedures.isNotEmpty) {
                        // Save the experiment
                        saveExperiment(
                            _titleController.text,
                            _briefDescriptionController.text,
                            selectedIcon,
                            procedures);
                        Navigator.pop(context);
                      } else if (procedures.isEmpty &&
                          _formKey.currentState!.validate()) {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 3),
                          content: Text(
                            AppLocalizations.of(context)!
                                .addAtLeastOneProcedure,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)!.add,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              _openAddProcedureDialog(context);
                            },
                          ),
                        ));
                      } else {
                        HapticFeedback.mediumImpact();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> saveExperiment(String title, String briefDescription,
    IconData icon, List<Map<String, Object?>> procedures) async {
  Database db = await openMyDatabase();

  await db.transaction((txn) async {
    try {
      // Insert the experiment and get its ID
      int experimentId = await txn.insert('experiments', {
        'title': title,
        'brief_description': briefDescription,
        'icon': icon.codePoint,
        'created_time': DateTime.now().toString(),
        'last_updated': DateTime.now().toString(),
      });

      // Create procedures list at "custom_procedures"
      for (var i = 0; i < procedures.length; i++) {
        var procedure = Map<String, Object?>.from(procedures[i]);
        procedure.remove('id');
        await txn.insert('custom_procedures', {
          ...procedure,
          'experiment_id': experimentId,
          'experiment_order': i,
        });
      }
    } catch (e) {
      // Handle errors, possibly by showing an error message to the user
      debugPrint("Error saving experiment: $e");
      throw Exception('Failed to save experiment');
    }
  });
}
