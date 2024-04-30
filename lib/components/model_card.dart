import 'package:flutter/material.dart';
import 'package:labsense/pages/experiment_models/model_view.dart';

class ModelCard extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final String type;

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
              builder: (context) => ModelView(
                    modelId: id,
                  )));
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.0,
                backgroundColor: Theme.of(context).primaryColor,
                child: type == 'cyclic_voltammetry'
                    ? const Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.white,
                        size: 24.0,
                      )
                    : const Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 24.0,
                      ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
