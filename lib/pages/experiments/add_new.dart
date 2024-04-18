import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateExperiment extends StatelessWidget {
  const CreateExperiment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createNewExperiment),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                  child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        label:
                            Text(AppLocalizations.of(context)!.experimentTitle),
                        icon: const Icon(Icons.title_rounded)),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text(
                          AppLocalizations.of(context)!.experimentBriefDesc),
                      icon: const Icon(Icons.description_rounded),
                    ),
                  )
                ],
              ))
            ],
          ),
        ));
  }
}
