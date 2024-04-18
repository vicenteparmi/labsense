import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            subtitle: Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.developedby),
            subtitle: Text('To be added'),
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
          )
        ],
      ),
    );
  }
}
