import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../pages/experiments/experiment_view.dart';

class ExperimentCard extends StatelessWidget {
  final int id;
  final String title;
  final DateTime date;
  final String description;

  const ExperimentCard(
      {super.key,
      required this.id,
      required this.title,
      required this.date,
      required this.description});

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
                  Text(
                    // Make the date look like "30 de janeiro de 2022"
                    '${date.day} de Abril de ${date.year}',
                    style: Theme.of(context).textTheme.bodySmall,
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
    )
        .animate()
        .fadeIn(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            delay: Duration(milliseconds: 100 * id))
        .scale(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0));
  }
}
