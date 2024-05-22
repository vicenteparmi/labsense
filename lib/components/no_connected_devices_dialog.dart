import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoConnectedDevicesDialog extends StatelessWidget {
  const NoConnectedDevicesDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.noDevicesConnected),
      content: Text(AppLocalizations.of(context)!.noDevicesConnectedMessage),
      icon: const Icon(
        Icons.power_off_rounded,
        size: 48.0,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    );
  }
}
