import 'package:flutter/material.dart';

class ExperimentCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String description;

  const ExperimentCard(
      {super.key,
      required this.title,
      required this.date,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(// Format the date
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
      ),
    );
  }
}