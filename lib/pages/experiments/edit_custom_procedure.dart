import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCustomProcedure extends StatefulWidget {
  final Map<String, Object?> procedure;
  final int index;
  final Function removeThis;
  final Function updateThis;

  const EditCustomProcedure(
      {super.key,
      required this.procedure,
      required this.index,
      required this.removeThis,
      required this.updateThis});

  @override
  State<EditCustomProcedure> createState() => _EditCustomProcedureState();
}

class _EditCustomProcedureState extends State<EditCustomProcedure> {
  Map<String, Object?> _updatedProcedure = {};

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _initialPotentialController =
      TextEditingController();
  final TextEditingController _finalPotentialController =
      TextEditingController();
  final TextEditingController _scanRateController = TextEditingController();
  final TextEditingController _cycleCountController = TextEditingController();
  bool _sweepDirection = false;

  @override
  void initState() {
    _updatedProcedure = Map<String, Object?>.from(widget.procedure);
    _descriptionController.text =
        widget.procedure['brief_description'].toString();
    _titleController.text = widget.procedure['title'].toString();

    if (widget.procedure['model_type'] == 'cyclic_voltammetry') {
      _initialPotentialController.text =
          widget.procedure['initial_potential'].toString();
      _finalPotentialController.text =
          widget.procedure['final_potential'].toString();
      _scanRateController.text = widget.procedure['scan_rate'].toString();
      _cycleCountController.text = widget.procedure['cycle_count'].toString();
      _sweepDirection = widget.procedure['sweep_direction'] == 0 ? false : true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: GestureDetector(
            onTap: () {
              // Open dialog to edit text
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.experimentTitle),
                    content: TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          // Update the procedure with the new name
                          _updatedProcedure['title'] =
                              _descriptionController.text;
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ],
                  );
                },
              ).then((value) {
                setState(() {});
              });
            },
            child: Text(
              widget.procedure['title'].toString(),
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
          ),
          subtitle: GestureDetector(
              onTap: () {
                // Open dialog to edit text
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                          AppLocalizations.of(context)!.experimentBriefDesc),
                      content: TextField(
                        controller: _descriptionController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        FilledButton(
                          onPressed: () {
                            // Update the procedure with the new description
                            _updatedProcedure['brief_description'] =
                                _descriptionController.text;
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  setState(() {});
                });
              },
              child: Text(
                widget.procedure['brief_description'].toString(),
                maxLines: 5,
                overflow: TextOverflow.fade,
              )),
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              widget.procedure['model_type'] == 'cyclic_voltammetry'
                  ? Icons.restart_alt_rounded
                  : Icons.timeline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        // Change the procedure parameters
        if (widget.procedure['model_type'] == 'cyclic_voltammetry')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0),
                Text(AppLocalizations.of(context)!.experimentData,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.start),
                const SizedBox(height: 12.0),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(
                        '${AppLocalizations.of(context)!.initialPotential} (V)'),
                    icon: const Icon(Icons.swipe_right_alt_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _initialPotentialController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.requiredField;
                    } else if (double.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.invalidNumber;
                    } else if (double.parse(value) < -1 ||
                        double.parse(value) > 1) {
                      return AppLocalizations.of(context)!.outOfRange(1, -1);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(
                        '${AppLocalizations.of(context)!.finalPotential} (V)'),
                    icon: const Icon(Icons.swipe_left_alt_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _finalPotentialController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.requiredField;
                    } else if (double.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.invalidNumber;
                    } else if (double.parse(value) < -1 ||
                        double.parse(value) > 1) {
                      return AppLocalizations.of(context)!.outOfRange(1, -1);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  decoration: InputDecoration(
                    label:
                        Text('${AppLocalizations.of(context)!.scanRate} (V/s)'),
                    icon: const Icon(Icons.speed_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _scanRateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.requiredField;
                    } else if (double.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.invalidNumber;
                    } else if (double.parse(value) < -1 ||
                        double.parse(value) > 1) {
                      return AppLocalizations.of(context)!.outOfRange(0.03, 0);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.cycleCount),
                    icon: const Icon(Icons.loop_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _cycleCountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.requiredField;
                    } else if (double.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.invalidNumber;
                    } else if (double.parse(value) < 1 ||
                        // Check if the value is a positive integer
                        double.parse(value) != double.parse(value).toInt()) {
                      return AppLocalizations.of(context)!
                          .errorNeedsToBeAIntegerPositiveNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.sweepDirection),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  value: _sweepDirection ? 'reverse' : 'forward',
                  items: [
                    DropdownMenuItem(
                      value: 'forward',
                      child: Text(
                          AppLocalizations.of(context)!.sweepDirectionForward),
                    ),
                    DropdownMenuItem(
                      value: 'reverse',
                      child: Text(
                          AppLocalizations.of(context)!.sweepDirectionBackward),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _sweepDirection = value == 'reverse';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.requiredField;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ButtonBar(
            children: [
              IconButton(
                onPressed: () {
                  // Remove the procedure from the experiment
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              Text(AppLocalizations.of(context)!.confirmDelete),
                          content: Text(AppLocalizations.of(context)!
                              .confirmProcedureDelete),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                widget.removeThis(widget.index);
                                Navigator.pop(context);
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onError,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.delete,
                              ),
                            ),
                          ],
                        );
                      });
                },
                icon: Icon(Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.error),
              ),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                onPressed: () {
                  // Update the procedure with the new parameters
                  if (widget.procedure['model_type'] == 'cyclic_voltammetry') {
                    _updatedProcedure['initial_potential'] =
                        double.parse(_initialPotentialController.text);
                    _updatedProcedure['final_potential'] =
                        double.parse(_finalPotentialController.text);
                    _updatedProcedure['scan_rate'] =
                        double.parse(_scanRateController.text);
                    _updatedProcedure['cycle_count'] =
                        int.parse(_cycleCountController.text);
                    _updatedProcedure['sweep_direction'] =
                        _sweepDirection ? 1 : 0;
                  }

                  widget.updateThis(_updatedProcedure);

                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
