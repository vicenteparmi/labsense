import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalibrationTutorial extends StatefulWidget {
  const CalibrationTutorial({super.key});

  @override
  State<CalibrationTutorial> createState() => _CalibrationTutorialState();
}

class _CalibrationTutorialState extends State<CalibrationTutorial> {
  final PageController _controller = PageController();

  void navigateNext(
    BuildContext context,
    int index,
  ) {
    if (index < 7) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _controller,
          children: <Widget>[
            // Page 1
            _Page(
              title: '1.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage1,
              icon: Icons.timeline,
              action: () => navigateNext(context, 1),
            ),
            // Page 2
            _Page(
              title: '2.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage2,
              icon: Icons.cable_rounded,
              action: () => navigateNext(context, 2),
            ),
            // Page 3
            _Page(
              title: '3.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage3,
              icon: Icons.power_settings_new_rounded,
              action: () => navigateNext(context, 3),
            ),
            // Page 4
            _Page(
              title: '4.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage4,
              icon: Icons.change_circle_rounded,
              action: () => navigateNext(context, 4),
            ),
            // Page 5
            _Page(
              title: '5.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage5,
              icon: Icons.power_rounded,
              action: () => navigateNext(context, 5),
            ),
            // Page 6
            _Page(
              title: '6.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage6,
              icon: Icons.shape_line_rounded,
              action: () => navigateNext(context, 6),
            ),
            // Page 7
            _Page(
              title: '7.',
              description:
                  AppLocalizations.of(context)!.calibrationTutorialPage7,
              icon: Icons.done_rounded,
              isLastPage: true,
              action: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
    this.isLastPage = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final Function action;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Card.filled(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: 80.0,
                    height: 80.0,
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(icon,
                          size: 40.0,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FilledButton(
                    onPressed: () {
                      action();
                    },
                    child: Text(isLastPage
                        ? AppLocalizations.of(context)!.close
                        : AppLocalizations.of(context)!.next),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
