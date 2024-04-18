import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/components/blinking_circle.dart';
import 'package:labsense/components/experiment_card_preview.dart';
import 'package:labsense/components/material_you_shape.dart';
import 'package:labsense/pages/experiments/add_new.dart';
import 'package:labsense/pages/main_pages/settings.dart';
import 'package:labsense/scripts/bluetooth.dart';

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

  double scale = 1.0;

  // Animate scale up
  void scaleUp() {
    setState(() {
      scale = 1.2;
    });
  }

  // Animate scale down
  void scaleDown() {
    setState(() {
      scale = 1.0;
    });
  }

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
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const CreateExperiment();
            }));
          },
          label: Text(AppLocalizations.of(context)!.newExperiment),
          icon: const Icon(Icons.add)),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: false,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SettingsPage();
                  }));
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              // Background is a colum with a icon and text below
              background: GestureDetector(
                onTapDown: (details) => scaleUp(),
                onTapCancel: () => scaleDown(),
                onTapUp: (details) => scaleDown(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnectDevice(),
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
                        Stack(alignment: Alignment.center, children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.identity()..scale(scale),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.center,
                            transformAlignment: Alignment.center,
                            child: const MaterialYouShape(),
                          ),
                          // Material You shape
                          Image.asset(
                            'assets/images/potentiostat.png',
                            height: 180.0,
                            fit: BoxFit.contain,
                            semanticLabel: 'Potentiostat picture',
                          ),
                        ]),
                        const SizedBox(
                          height: 8.0,
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
                            BlinkingCircle(
                                color: getConnectedDevice() != ''
                                    ? Colors.green
                                    : Colors.red),
                            const SizedBox(width: 4.0),
                            Text(
                              getConnectedDevice() != ''
                                  ? AppLocalizations.of(context)!.connected
                                  : AppLocalizations.of(context)!.disconnected,
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
            child: Stack(
              children: <Widget>[
                Container(
                  height: 24.0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                Container(
                  height: 24.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.science_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    AppLocalizations.of(context)!.experiments,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
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
                      id: index,
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: ExperimentCard(
                        id: index,
                        title: 'Experimento #$index',
                        date: DateTime.now(),
                        description:
                            'Aqui vai a descrição para o experimento #$index. A descrição é um pouco maior para que possamos ver como o texto se comporta no card. Vamos ver se ele quebra ou se ele se comporta bem.'),
                  );
                },
                childCount: 26,
              ),
            ),
        ],
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
