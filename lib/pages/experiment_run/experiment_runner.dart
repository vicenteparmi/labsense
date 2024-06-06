import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/scripts/bluetooth_com.dart';
import 'package:labsense/scripts/calculations.dart';
import 'package:labsense/scripts/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'export_data.dart';

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
  List<List<List<double>>> _data = [];
  int _currentStepController = 0;
  int index = 0;
  bool finished = false;
  double slope = 1.0;
  double intercept = 0.0;

  /// Fetches the steps for the experiment from the database.
  Future<void> _fetchSteps() async {
    // load data from database
    Database db = await openMyDatabase();

    // Get the data from the database
    List<Map<String, dynamic>> value = await db.query('custom_procedures',
        where: 'experiment_id = ?',
        whereArgs: [widget.experimentId],
        orderBy: 'experiment_order');

    // Convert the data to a list of maps
    setState(() {
      steps = value;
    });
  }

  /// Updates the state of the experiment runner.
  void _updateState(String title, double? progress, int step) {
    debugPrint('Title: $title, Progress: $progress, Step: $step');
    setState(() {
      _stepTitle = title;
      _progress = progress;
      _currentStep = step;
      _currentStepController = step > steps.length ? steps.length - 1 : step;
    });
  }

  /// Function to run the experiment, step by step.
  Future<void> _runExperiment() async {
    // For each step in the experiment, send data to the device
    // and ask the device to run it.
    final step = steps[index];

    // Update progress
    _updateState(AppLocalizations.of(context)!.sendingData, null, index);

    // Send data to device
    await sendDataToDevice(
        '\$1!${step['cycle_count']}!${step['initial_potential']}!${step['final_potential']}!${step['start_potential']}!1!${step['scan_rate']}!${step['sweep_direction']}#');

    // Calculate duration of the experiment
    double duration = calculateDuration(
        double.parse(step['initial_potential']),
        double.parse(step['final_potential']),
        double.parse(step['scan_rate']),
        int.parse(step['cycle_count']));

    // Start the experiment
    await Future.delayed(const Duration(seconds: 5), () {
      _updateState(step['title'], 0.0, index);
      debugPrint('Starting the experiment');
      sendDataToDevice('\$2#');
    }).then((_) async {
      // Listen to the data from the device
      await Future.delayed(
          const Duration(seconds: 5), () async => _listenData(index));
    });

    // Animate progress bar
    for (int i = 0; i < 100; i++) {
      await Future.delayed(Duration(seconds: duration.toInt() ~/ 100), () {
        setState(() {
          _progress = i / 100;
        });
      });
    }
  }

  void _shouldRunAgain(int index) {
    // Update state to show that the current step has finished
    _updateState(AppLocalizations.of(context)!.stepFinished, 1.0, index);

    // Move to the next step if there is one
    if (index < steps.length - 1) {
      index++;
      debugPrint('Moving to the next step: $index');
      Future.delayed(const Duration(seconds: 5), () => _runExperiment());
    } else {
      // Finish the experiment
      _updateState(AppLocalizations.of(context)!.experimentFinished, 1.0,
          steps.length - 1);
      setState(() {
        finished = true;
      });
    }
  }

  /// Function to listen the data from the device.
  Future<void> _listenData(int index) async {
    String adress = await getConnectedDevice().then((value) => value[1]);
    BluetoothConnection connection =
        await BluetoothConnection.toAddress(adress);

    String result = '';

    connection.input!.listen((Uint8List data) {
      result += ascii.decode(data);

      // Add data to state
      _handleStreamData(index, result);

      // Close the connection if the data is "END"
      if (ascii.decode(data).contains('E')) {
        connection.finish();
        // Disconnect from the device
        debugPrint('Connection closed onEnd');
        _shouldRunAgain(index);
        return;
      }
    }).onDone(() {
      connection.finish();
      debugPrint('Connection closed onDone');
    });
  }

  Future<void> _handleStreamData(int index, String data) async {
    List<List<String>> parsedValues = data
        .split('\n')
        .map((e) => e.split(';'))
        .where((element) => element.length == 2)
        .toList();

    // Convert the parsed values to a list of doubles
    List<List<double>> values = parsedValues.map((e) {
      try {
        return [double.parse(e[0]), double.parse(e[1])];
      } catch (error) {
        print('Error parsing double: $error, $e');
        return [double.parse(e[0]), double.parse('0')];
      }
    }).toList();

    // Update the graph
    setState(() {
      if (_data.length <= index + 1) {
        _data.add(values);
      } else {
        _data[index] = values;
      }
    });
  }

  @override
  void initState() {
    _fetchSteps().then((_) => _runExperiment());

    // Get calibration values
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        slope = prefs.getDouble('cal_slope') ?? 1.0;
        intercept = prefs.getDouble('cal_intercept') ?? 0.0;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.executing),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
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
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                const SizedBox(height: 16),
                // Space for graph, title and steps.
                _Chart(data: _data, slope: slope, intercept: intercept),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  subtitle: Text(widget.description,
                      maxLines: 5, overflow: TextOverflow.fade),
                ),
                // Steps
                Stepper(
                  connectorThickness: 2.0,
                  physics: const NeverScrollableScrollPhysics(),
                  steps: [
                    for (int i = 0; i < steps.length; i++)
                      Step(
                          title: Text(
                              '${AppLocalizations.of(context)!.step} ${i + 1}: ${steps[i]['title']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium!),
                          content: SizedBox(
                              width: double.infinity,
                              child: Card(
                                color: Color.lerp(
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    0.5),
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!
                                              .runDescription,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!),
                                      Text(steps[i]['brief_description']),
                                    ],
                                  ),
                                ),
                              )),
                          state: i < _currentStep
                              ? StepState.complete
                              : StepState.indexed,
                          isActive: i == _currentStep || i < _currentStep),
                  ],
                  currentStep: _currentStepController,
                  onStepTapped: (value) => setState(() {
                    _currentStepController = value;
                  }),
                  controlsBuilder: (context, details) {
                    return ButtonBar(
                      children: [
                        // Export button
                        OutlinedButton.icon(
                            onPressed: () {
                              // Open a new screen to export the data
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ExportData(
                                            data: _data[index],
                                            procedureName: widget.name)
                                        .animate()
                                        .slideY(
                                          begin: 0.5,
                                          end: 0.0,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        )
                                        .fade(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          begin: 0.0,
                                          end: 1.0,
                                          curve: Curves.easeInOut,
                                        );
                                  });
                            },
                            icon: const Icon(Icons.archive_outlined),
                            label: Text(AppLocalizations.of(context)!.export)),
                      ],
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    required this.slope,
    required this.intercept,
    required this.data,
  });

  final List<List<List<double>>> data;
  final double slope;
  final double intercept;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300.0,
        width: double.infinity,
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: data
                .map((e) => e.map((point) => ScatterSpot(
                      transformPotential(point[0]),
                      transformCurrent(point[1], slope, intercept),
                      show: true,
                      dotPainter: FlDotCirclePainter(
                        color: Theme.of(context).colorScheme.primary,
                        radius: 2.0,
                      ),
                    )))
                .expand((element) => element)
                .toList(),
            scatterTouchData: ScatterTouchData(
              touchTooltipData: ScatterTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return ScatterTooltipItem(
                    '${touchedSpots.x.toInt()} V, ${touchedSpots.y.toInt()} A',
                    bottomMargin: 32.0,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                  );
                },
              ),
            ),
            borderData: FlBorderData(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 1.0,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text(
                  '${AppLocalizations.of(context)!.current} (A)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                sideTitles: const SideTitles(
                  showTitles: true,
                  reservedSize: 52.0,
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  '${AppLocalizations.of(context)!.potential} (V)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                sideTitles: const SideTitles(
                  showTitles: true,
                  reservedSize: 28.0,
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
          swapAnimationDuration: Duration.zero,
        ),
      ),
    );
  }
}
