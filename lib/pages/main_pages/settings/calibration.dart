import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labsense/pages/main_pages/settings/calibration_tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  double slope = 0.0;
  double intercept = 0.0;

  TextEditingController slopeController = TextEditingController();
  TextEditingController interceptController = TextEditingController();

  void getCalibration() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        slope = prefs.getDouble('cal_slope') ?? 1.0;
        intercept = prefs.getDouble('cal_intercept') ?? 0.0;
        slopeController.text = slope.toStringAsExponential();
        interceptController.text = intercept.toStringAsExponential();
      });
    });
  }

  String parseDouble(double value) {
    if (value < 0.1 && value != 0.0) {
      return value.toStringAsExponential(4);
    } else {
      return value.toStringAsFixed(4);
    }
  }

  @override
  void initState() {
    getCalibration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppLocalizations.of(context)!.calibration),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // Latex equation used for calibration
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'y = ${parseDouble(slope)} · x + ${parseDouble(intercept)}',
                    style: GoogleFonts.unna(
                      fontSize: 24.0,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Parameters
                ListTile(
                  title: Text(AppLocalizations.of(context)!.slope),
                  subtitle:
                      Text(AppLocalizations.of(context)!.slopeDescription),
                  trailing: Chip(
                    label: Text(parseDouble(slope)),
                    backgroundColor: Colors.transparent,
                  ),
                  onTap: () {
                    // Show dialog to edit the slope value
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.slope),
                          content: TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              helper: Text(AppLocalizations.of(context)!
                                  .decimalSeparator),
                              border: const OutlineInputBorder(),
                            ),
                            enableSuggestions: false,
                            controller: slopeController,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                double newSlope =
                                    double.parse(slopeController.text);
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setDouble('cal_slope', newSlope);
                                  getCalibration();
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.save),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.intercept),
                  subtitle:
                      Text(AppLocalizations.of(context)!.interceptDescription),
                  trailing: Chip(
                    label: Text(parseDouble(intercept)),
                    backgroundColor: Colors.transparent,
                  ),
                  onTap: () {
                    // Show dialog to edit the intercept value
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.intercept),
                          content: TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              helper: Text(AppLocalizations.of(context)!
                                  .decimalSeparator),
                              border: const OutlineInputBorder(),
                            ),
                            enableSuggestions: false,
                            controller: interceptController,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                double newIntercept =
                                    double.parse(interceptController.text);
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setDouble(
                                      'cal_intercept', newIntercept);
                                  getCalibration();
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.save),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title:
                      Text(AppLocalizations.of(context)!.calibrationTutorial),
                  subtitle: Text(AppLocalizations.of(context)!
                      .calibrationTutorialDescription),
                  leading: const Icon(Icons.live_help_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CalibrationTutorial(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.easeOutCubic;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
