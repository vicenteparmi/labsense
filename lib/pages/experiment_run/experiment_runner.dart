import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/scripts/bluetooth_com.dart';
import 'package:labsense/scripts/database.dart';
import 'package:step_tracker/step_tracker.dart';

class ExperimentRunner extends StatefulWidget {
  final int experimentId;
  final String name;
  final String description;

  const ExperimentRunner(
      {super.key,
      required this.experimentId,
      required this.name,
      required this.description});

  @override
  State<ExperimentRunner> createState() => _ExperimentRunnerState();
}

class _ExperimentRunnerState extends State<ExperimentRunner> {
  List<Map<String, dynamic>> steps = [];

  void _fetchSteps() {
    // load data from database
    openMyDatabase().then((db) {
      db
          .query('custom_procedures',
              where: 'experiment_id = ?',
              whereArgs: [widget.experimentId],
              orderBy: 'experiment_order')
          .then((value) {
        setState(() {
          steps = value;
        });
      });
    });
  }

  @override
  void initState() {
    _fetchSteps();

    // DEBUG: Send data to device
    debugPrint('Sending data to device');
    sendDataToDevice('\$1!3!-1!1!0!1!100!200!600#');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.executing),
        automaticallyImplyLeading: false,
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () {
              // Show not implemented snackbar
              sendDataToDevice('\$2#');
            },
          ),
          // Stop button
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () {
              // Confirm stop
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.stopExecution),
                    content:
                        Text(AppLocalizations.of(context)!.stopExecutionMsg),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Close dialog
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          // Close dialog and go back to experiment list
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          // Show not implemented snackbar
                          // TODO: Implement stop execution
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Stop execution not implemented yet."),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        child: Text(AppLocalizations.of(context)!.stop),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          const LinearProgressIndicator(),
          // Display experiment name and description
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              children: [
                // Space for graph, title and steps.
                // Graph placeholder
                Card.filled(
                  margin: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Graph placeholder
                      Container(
                        height: 200,
                        // Add border radius to all corners
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  title: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  subtitle: Text(widget.description,
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 16.0),
                // Steps
                StepTracker(steps: [
                  for (final step in steps)
                    Steps(
                      title: Text(step['title']),
                      description: step['brief_description'],
                    ),
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
