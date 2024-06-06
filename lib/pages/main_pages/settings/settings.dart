import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/pages/main_pages/settings/calibration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: <Widget>[
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Text(
              AppLocalizations.of(context)!.calibration,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.calibrationCurve),
            subtitle:
                Text(AppLocalizations.of(context)!.calibrationCurveDescription),
            leading: const Icon(Icons.timeline),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const CalibrationPage(),
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
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Text(
              AppLocalizations.of(context)!.abouttheapp,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.version),
            subtitle: FutureBuilder<String>(
              future:
                  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                return packageInfo.version;
              }),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else {
                  return const Text('...');
                }
              },
            ),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.developedby),
            subtitle: Text(AppLocalizations.of(context)!.developerName),
            leading: const Icon(Icons.code),
            onTap: () {
              // Show dialog with the information from the two developers as
              // list tiles to redirect to their websites
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog.adaptive(
                    title: Text(AppLocalizations.of(context)!.developedby),
                    icon: const Icon(Icons.code_rounded, size: 40),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.developer1),
                          subtitle:
                              const Text('https://linktr.ee/vicenteparmi'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onTap: () => launchUrl(
                              Uri.parse('https://linktr.ee/vicenteparmi')),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.developer2),
                          subtitle: const Text(
                              'https://www.instagram.com/labsense.ufpr/'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onTap: () => launchUrl(Uri.parse(
                              'https://www.instagram.com/labsense.ufpr/')),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.licenses),
            subtitle: Text(AppLocalizations.of(context)!.licensesDescription),
            leading: const Icon(Icons.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'LabSense',
              applicationVersion: '1.0.0',
            ),
          ),
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Text(
              AppLocalizations.of(context)!.dataManagement,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.deleteAllData),
            subtitle:
                Text(AppLocalizations.of(context)!.deleteAllDataDescription),
            leading: const Icon(Icons.delete_forever),
            onTap: () {
              // Show a dialog to confirm the deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.deleteAllData),
                    content: Text(AppLocalizations.of(context)!
                        .deleteAllDataConfirmation),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          // Delete the database
                          deleteDatabase('my_database.db').then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .allDataDeleted),
                              ),
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        child: const Text("Apagar"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
