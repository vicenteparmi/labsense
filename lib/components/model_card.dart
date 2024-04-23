import 'package:flutter/material.dart';
import '../pages/experiments/experiment_view.dart';

class ModelCard extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final List<String> type;

  const ModelCard(
      {super.key,
      required this.id,
      required this.title,
      required this.description,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: InkWell(
        onTap: () {
          // Navigate to the experiment view page
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ExperimentView(
                    experimentId: id,
                  )));
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    // Tags for the type of model
                    children: type
                        .map((e) => Chip(
                            label: Text(e),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2)))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
