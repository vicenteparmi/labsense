import 'package:flutter/material.dart';
import 'package:labsense/pages/main_pages/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:labsense/theme/color_schemes.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LabSensE',
        theme: ThemeData(
          colorScheme: MaterialTheme.lightScheme().toColorScheme(),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          }),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: MaterialTheme.darkScheme().toColorScheme(),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          }),
          useMaterial3: true,
        ),
        highContrastTheme: ThemeData(
          colorScheme: MaterialTheme.lightHighContrastScheme().toColorScheme(),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          }),
          useMaterial3: true,
        ),
        highContrastDarkTheme: ThemeData(
          colorScheme: MaterialTheme.darkHighContrastScheme().toColorScheme(),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          }),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt'), // Portuguese
          Locale('en'), // English
        ],
        home: const Scaffold(body: Home()));
  }
}
