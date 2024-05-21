import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/scripts/bluetooth_com.dart';
import 'package:labsense/scripts/calculate_duration.dart';
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
  String _stepTitle = 'Carregando dados...';
  double? _progress;
  int _currentStep = 0;

  /// Fetches the steps for the experiment from the database.
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

  /// Updates the state of the experiment runner.
  void _updateState(String title, double? progress, int step) {
    debugPrint('Title: $title, Progress: $progress, Step: $step');
    setState(() {
      _stepTitle = title;
      _progress = progress;
      _currentStep = step;
    });
  }

  /// Function to run the experiment, step by step.
  Future<void> _runExperiment() async {
    // For each step in the experiment, send data to the device
    // and ask the device to run it.
    for (int index = 0; index < steps.length; index++) {
      final step = steps[index];

      // Update progress
      _updateState(AppLocalizations.of(context)!.sendingData, null, index + 1);

      // Send data to device
      await sendDataToDevice(
          '\$1!${step['cycle_count']}!${step['initial_potential']}!${step['final_potential']}!${step['start_potential']}!1!${step['scan_rate']}!${step['sweep_direction']}#');

      _updateState(step['title'], 0.0, index + 2);

      // Calculate duration of the experiment
      double duration = calculateDuration(
          double.parse(step['initial_potential']),
          double.parse(step['final_potential']),
          double.parse(step['scan_rate']),
          int.parse(step['cycle_count']));

      // Start the experiment
      Future.delayed(const Duration(seconds: 3), () {
        debugPrint('Starting the experiment');
        sendDataToDevice('\$2#');
      });

      // Animate progress bar
      for (int i = 0; i < 100; i++) {
        await Future.delayed(Duration(seconds: duration.toInt() ~/ 100), () {
          setState(() {
            _progress = i / 100;
          });
        });
      }

      // Update state to show that the current step has finished
      _updateState(AppLocalizations.of(context)!.stepFinished, 1.0, index + 2);
    }

    // Update state to show that the experiment has finished
    _updateState(AppLocalizations.of(context)!.experimentFinished, 1.0,
        steps.length + 1);
  }

  @override
  void initState() {
    _fetchSteps();
    // Wait 1 second before running the experiment
    Future.delayed(const Duration(milliseconds: 100), () {
      _runExperiment();
    });

    // Listen for data from the device
    _dataStreamController.stream.listen((data) {
      debugPrint('Data received: $data');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.executing),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _stepTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.normal),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
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
          LinearProgressIndicator(
            value: _progress,
          ),
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
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
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
