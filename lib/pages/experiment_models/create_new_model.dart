import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labsense/scripts/calculations.dart';
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
  final TextEditingController _initialPotentialController =
      TextEditingController();
  final TextEditingController _finalPotentialController =
      TextEditingController();
  final TextEditingController _startPotentialController =
      TextEditingController();
  final TextEditingController _scanRateController = TextEditingController();
  final TextEditingController _cycleCountController = TextEditingController();

  String _modelType = '';
  bool _sweepDirection = false; // false: forward, true: reverse

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Compute the duration and potential interval of the experiment
  String duration = '0.00 s';
  String potentialInterval = '0.00 s';

  String computeDuration() {
    // Compute the duration of the experiment
    double initialPotential =
        double.tryParse(_initialPotentialController.text) ?? 0.0;
    double finalPotential =
        double.tryParse(_finalPotentialController.text) ?? 0.0;
    double scanRate = double.tryParse(_scanRateController.text) ?? 0.0;
    int cycleCount = int.tryParse(_cycleCountController.text) ?? 0;

    if (initialPotential == 0.0 || finalPotential == 0.0 || scanRate == 0.0) {
      return '0.00 s';
    }

    double duration = calculateDuration(
        initialPotential, finalPotential, scanRate, cycleCount);
    duration *= cycleCount;

    return duration > 60
        ? '${(duration / 60).toStringAsFixed(0)} min ${(duration % 60).toStringAsFixed(0)} s'
        : '${duration.toStringAsFixed(2)} s';
  }

  String computeInterval() {
    // Compute the interval between each potential
    double initialPotential =
        double.tryParse(_initialPotentialController.text) ?? 0.0;
    double finalPotential =
        double.tryParse(_finalPotentialController.text) ?? 0.0;
    double scanRate = double.tryParse(_scanRateController.text) ?? 0.0;

    if (initialPotential == 0.0 || finalPotential == 0.0 || scanRate == 0.0) {
      return '0.00 s';
    }

    return '${((finalPotential - initialPotential) / scanRate).toStringAsFixed(2)} s';
  }

  @override
  void initState() {
    // Compute the duration of the experiment when the required fields are filled
    _initialPotentialController.addListener(() {
      setState(() {
        duration = computeDuration();
        potentialInterval = computeInterval();
      });
    });
    _finalPotentialController.addListener(() {
      setState(() {
        duration = computeDuration();
        potentialInterval = computeInterval();
      });
    });
    _scanRateController.addListener(() {
      setState(() {
        duration = computeDuration();
        potentialInterval = computeInterval();
      });
    });
    _cycleCountController.addListener(() {
      setState(() {
        duration = computeDuration();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context)!.createNewModel,
                  style: Theme.of(context).textTheme.titleLarge),
              background: Icon(Icons.grid_view_rounded,
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
                                label: Text(
                                    AppLocalizations.of(context)!.modelTitle),
                                icon: const Icon(Icons.title_rounded),
                                border: const OutlineInputBorder()),
                            textInputAction: TextInputAction.next,
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
                            keyboardType: TextInputType.multiline,
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
                          Text(AppLocalizations.of(context)!.experimentType,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12.0),
                          // Selector for the model type with two options
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              label: Text(
                                  AppLocalizations.of(context)!.experimentType),
                              icon: const Icon(Icons.category_rounded),
                              border: const OutlineInputBorder(),
                              helperText:
                                  "Novos tipos de procedimento serão adicionados futuramente",
                              helperMaxLines: 2,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'cyclic_voltammetry',
                                child: Text(AppLocalizations.of(context)!
                                    .cyclicVoltammetry),
                              ),
                              DropdownMenuItem(
                                value: 'linear_sweep_voltammetry',
                                enabled: false, // TODO: Implement this model
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .linearSweepVoltammetry,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'chronoamperometry',
                                enabled: false, // TODO: Implement this model
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .chronoamperometry,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _modelType = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12.0),
                          // Case: cyclic_voltametry
                          if (_modelType == 'cyclic_voltammetry')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card to explain the experiment, with image representing the graph
                                Card.filled(
                                  margin: EdgeInsets.zero,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display the image
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/CV.svg',
                                                  height: 120.0,
                                                  colorFilter: ColorFilter.mode(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      BlendMode.srcIn),
                                                ),
                                              ]),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .howToCyclicVoltammetry,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .cyclicVoltammetryExplanation,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeOut)
                                    .slideY(
                                        begin: 60.0,
                                        end: 0.0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeOutCubic),
                                const SizedBox(height: 24.0),
                                Text(
                                    AppLocalizations.of(context)!
                                        .experimentData,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.start),
                                const SizedBox(height: 12.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    label: Text(
                                        '${AppLocalizations.of(context)!.initialPotential} (V)'),
                                    icon: const Icon(
                                        Icons.swipe_right_alt_rounded),
                                    border: const OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  controller: _initialPotentialController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    } else if (double.tryParse(value) == null) {
                                      return AppLocalizations.of(context)!
                                          .invalidNumber;
                                    } else if (double.parse(value) < -1 ||
                                        double.parse(value) > 1) {
                                      return AppLocalizations.of(context)!
                                          .outOfRange(1, -1);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    label: Text(
                                        '${AppLocalizations.of(context)!.finalPotential} (V)'),
                                    icon: const Icon(
                                        Icons.swipe_left_alt_rounded),
                                    border: const OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  controller: _finalPotentialController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    } else if (double.tryParse(value) == null) {
                                      return AppLocalizations.of(context)!
                                          .invalidNumber;
                                    } else if (double.parse(value) < -1 ||
                                        double.parse(value) > 1) {
                                      return AppLocalizations.of(context)!
                                          .outOfRange(1, -1);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    label: Text(
                                        '${AppLocalizations.of(context)!.startPotential} (V)'),
                                    icon: const Icon(Icons.start_rounded),
                                    border: const OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  controller: _startPotentialController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    } else if (double.tryParse(value) == null) {
                                      return AppLocalizations.of(context)!
                                          .invalidNumber;
                                    } else if (double.parse(value) < -1 ||
                                        double.parse(value) > 1) {
                                      return AppLocalizations.of(context)!
                                          .outOfRange(1, -1);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    label: Text(
                                        '${AppLocalizations.of(context)!.scanRate} (V/s)'),
                                    icon: const Icon(Icons.speed_rounded),
                                    border: const OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  controller: _scanRateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    } else if (double.tryParse(value) == null) {
                                      return AppLocalizations.of(context)!
                                          .invalidNumber;
                                    } else if (double.parse(value) <= 0 ||
                                        double.parse(value) > 0.250) {
                                      return AppLocalizations.of(context)!
                                          .outOfRange(0.250, 0);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    label: Text(AppLocalizations.of(context)!
                                        .cycleCount),
                                    icon: const Icon(Icons.loop_rounded),
                                    border: const OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  controller: _cycleCountController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    } else if (double.tryParse(value) == null) {
                                      return AppLocalizations.of(context)!
                                          .invalidNumber;
                                    } else if (double.parse(value) < 1 ||
                                        // Check if the value is a positive integer
                                        double.parse(value) !=
                                            double.parse(value).toInt()) {
                                      return AppLocalizations.of(context)!
                                          .errorNeedsToBeAIntegerPositiveNumber;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    label: Text(AppLocalizations.of(context)!
                                        .sweepDirection),
                                    icon: const Icon(Icons.swap_horiz_rounded),
                                    border: const OutlineInputBorder(),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'forward',
                                      child: Text(AppLocalizations.of(context)!
                                          .sweepDirectionForward),
                                    ),
                                    DropdownMenuItem(
                                      value: 'reverse',
                                      child: Text(AppLocalizations.of(context)!
                                          .sweepDirectionBackward),
                                    ),
                                  ],
                                  onChanged: (String? value) {
                                    setState(() {
                                      _sweepDirection = value == 'reverse';
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          // Card with summary of the experiment
                          if (_modelType.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Card.outlined(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!.summary,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                      if (_modelType == 'cyclic_voltammetry')
                                        Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .estimatedDuration),
                                              subtitle: Text(duration),
                                              leading: const Icon(
                                                  Icons.timer_rounded),
                                            ),
                                            ListTile(
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .potentialInterval),
                                              subtitle: Text(potentialInterval),
                                              leading: const Icon(
                                                  Icons.timelapse_rounded),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
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
                                    saveModel(
                                        _titleController.text,
                                        _briefDescriptionController.text,
                                        _modelType,
                                        _initialPotentialController.text,
                                        _finalPotentialController.text,
                                        _startPotentialController.text,
                                        _scanRateController.text,
                                        _cycleCountController.text,
                                        _sweepDirection);
                                    // Close the dialog
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
          ),
        ],
      ),
    );
  }
}

Future<void> saveModel(
    String title,
    String briefDescription,
    String modelType,
    String initialPotential,
    String finalPotential,
    String startPotential,
    String scanRate,
    String cycleCount,
    bool sweepDirection) async {
  // Open the database
  openMyDatabase().then((db) => db.insert(
        'procedures',
        {
          'title': title,
          'brief_description': briefDescription,
          'model_type': modelType,
          'initial_potential': initialPotential,
          'final_potential': finalPotential,
          'start_potential': startPotential,
          'scan_rate': scanRate,
          'cycle_count': cycleCount,
          'sweep_direction': sweepDirection ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      ));
}
