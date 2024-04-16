import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/components/blinking_circle.dart';
import 'package:labsense/components/experiment_card_preview.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../connect_device/device_connection.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // This will display a parlax effect on the background header, with a
  // card sliding on top on scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Text(AppLocalizations.of(context)!.newExperiment),
          icon: const Icon(Icons.add)),
      body: DynMouseScroll(
        durationMS: 150,
        scrollSpeed: 1,
        animationCurve: Curves.easeOutQuad,
        builder: (context, controller, physics) => CustomScrollView(
          controller: controller,
          physics: physics,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 280.0,
              floating: false,
              pinned: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                // Background is a colum with a icon and text below
                background: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectDevice(),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'potentiostat_headline',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 24.0),
                          // Image
                          Image.asset(
                            'assets/images/potentiostat.png',
                            height: 180.0,
                            fit: BoxFit.contain,
                            semanticLabel: 'Potentiostat picture',
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            AppLocalizations.of(context)!.potentiostat,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // Dot
                              const BlinkingCircle(),
                              const SizedBox(width: 4.0),
                              Text(
                                AppLocalizations.of(context)!.connected,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 24.0,
                  bottom: 8.0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.experiments,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            if (MediaQuery.of(context).size.width > 600)
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ExperimentCard(
                        title: 'Item $index',
                        date: DateTime.now(),
                        description: 'Description');
                  },
                  childCount: 26,
                ),
              ),
            if (MediaQuery.of(context).size.width <= 600)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ExperimentCard(
                        title: 'Item $index',
                        date: DateTime.now(),
                        description: 'Description');
                  },
                  childCount: 26,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}
