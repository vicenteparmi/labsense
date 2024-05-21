import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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
  final StreamController<String> _streamController = StreamController<String>();
  List<List<double>> _data = [];
  List<NumericGroup> _groupList = [];

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
      }).then((_) => Future.delayed(
          const Duration(seconds: 3), () => _handleStreamData()));

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

  /// Function to listen the data from the device.
  Future<void> _listenData() async {
    String adress = await getConnectedDevice().then((value) => value[1]);
    BluetoothConnection connection =
        await BluetoothConnection.toAddress(adress);

    String result = '';

    connection.input!.listen((Uint8List data) {
      result += ascii.decode(data);

      // Send data to the stream controller every 2 seconds to update the graph
      Future.delayed(const Duration(seconds: 3), () {
        _streamController.add(result);
      });

      // Close the connection if the data is "END"
      if (ascii.decode(data).contains('END')) {
        connection.finish();
        // Disconnect from the device
        debugPrint('Connection closed');
        return;
      }
    }).onDone(() {
      connection.finish();
      debugPrint('Connection closed');
    });
  }

  Future<void> _handleStreamData() async {
    await _listenData();

    _streamController.stream.listen((data) {
      // Parse data and update the graph
      // The data is a list of "\n" separated values
      // Each value is separated by ";", with two values per line
      // The first value is the potential and the second value is the current
      List<List<String>> parsedValues = data
          .split('\n')
          .map((e) => e.split(';'))
          .where((element) => element.length == 2)
          .toList();

      // Convert the parsed values to a list of doubles
      List<List<double>> values = parsedValues
          .map((e) => [double.parse(e[0]), double.parse(e[1])])
          .toList();

      _groupList = [
        NumericGroup(
            id: 'Dados',
            color: Theme.of(context).colorScheme.primary,
            seriesCategory: 'Dados',
            data: _data.map((e) {
              return NumericData(domain: e[0], measure: e[1]);
            }).toList()),
      ];

      // Update the graph
      setState(() {
        _data = values;
      });
    });
  }

  @override
  void initState() {
    _fetchSteps();
    // Wait 1 second before running the experiment
    Future.delayed(const Duration(milliseconds: 100), () {
      _runExperiment();
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
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DChartScatterN(
                      groupList: _groupList,
                      layoutMargin: LayoutMargin(16, 16, 16, 16),
                      measureAxis: MeasureAxis(
                        numericViewport: NumericViewport(
                          // Minimum value on _data
                          _data.isNotEmpty
                              ? _data.map((e) => e[1]).reduce(min)
                              : 0,
                          // Maximum value on _data
                          _data.isNotEmpty
                              ? _data.map((e) => e[1]).reduce(max)
                              : 1,
                        ),
                      ),
                      domainAxis: DomainAxis(
                        numericViewport: NumericViewport(
                          // Minimum value on _data
                          _data.isNotEmpty
                              ? _data.map((e) => e[0]).reduce(min)
                              : 0,
                          // Maximum value on _data
                          _data.isNotEmpty
                              ? _data.map((e) => e[0]).reduce(max)
                              : 1,
                        ),
                      ),
                    ),
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
