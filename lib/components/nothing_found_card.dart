import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NothingFound extends StatelessWidget {
  const NothingFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Text(
                AppLocalizations.of(context)!.nothingFound,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                AppLocalizations.of(context)!.nothingFoundSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
      ),
    );
  }
}
