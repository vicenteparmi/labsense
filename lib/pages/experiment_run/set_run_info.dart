import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/components/no_connected_devices_dialog.dart';
import 'package:labsense/pages/experiment_run/experiment_runner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetRunInfo extends StatefulWidget {
  final int experimentId;

  const SetRunInfo({super.key, required this.experimentId});

  @override
  State<SetRunInfo> createState() => _SetRunInfoState();
}

class _SetRunInfoState extends State<SetRunInfo> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.newExecution),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Validate form
            if (_form.currentState!.validate()) {
              // Check if device is connected via shared preferences
              SharedPreferences.getInstance().then((prefs) {
                if (!prefs.containsKey('connectedDevice') ||
                    prefs.getStringList('connectedDevice')!.isEmpty) {
                  // Show dialog to connect device
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const NoConnectedDevicesDialog();
                    },
                  );
                  return;
                } else {
                  // Device is connected, proceed with experiment
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ExperimentRunner(
                        experimentId: widget.experimentId,
                        name: _nameController.text,
                        description: _descriptionController.text,
                      ),
                    ),
                  );
                }
              });
            }
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(AppLocalizations.of(context)!.start),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          children: [
            // Form to get experiment name and description, with summary at the end
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.runName,
                      border: const OutlineInputBorder(),
                      icon: const Icon(Icons.title_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.errorTitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.runDescription,
                      border: const OutlineInputBorder(),
                      icon: const Icon(Icons.description_rounded),
                    ),
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.errorDescription;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Summary of the entered experiment details
            Card.filled(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48.0,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        "Aqui será adicionado um breve resumo do experimento, com tempo de execução e outros dados que serão salvos. Ainda não implementado.",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      // TODO: Implement the summary of the entered experiment details
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}