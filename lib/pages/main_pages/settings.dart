import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite/sqflite.dart';

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
              AppLocalizations.of(context)!.abouttheapp,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.version),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.developedby),
            subtitle: const Text('To be added'),
            leading: const Icon(Icons.code),
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
          if (kDebugMode)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    "Opções de depruração",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  title: const Text("Apagar banco de dados"),
                  subtitle: const Text(
                      "Apaga todos os dados de experimentos e modelos"),
                  leading: const Icon(Icons.delete_forever),
                  onTap: () {
                    // Show a dialog to confirm the deletion
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Apagar banco de dados"),
                          content: const Text(
                              "Tem certeza que deseja apagar todos os dados?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Delete the database
                                deleteDatabase('my_database.db').then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Banco de dados apagado"),
                                    ),
                                  );
                                });
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
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
        ],
      ),
    );
  }
}
