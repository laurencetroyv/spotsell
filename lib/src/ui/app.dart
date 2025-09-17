import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotsell/src/ui/feature/home.dart';
import 'package:yaru/yaru.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final String title = 'SpotSell';

  // TODO: Responsive Text Direction and Theme
  static final ThemeMode themeMode = ThemeMode.system;
  static final TextDirection textDirection = TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: _buildPlatformAwareApp(context),
    );
  }

  Widget _buildPlatformAwareApp(BuildContext context) {
    if (Platform.isMacOS || Platform.isIOS) {
      return _buildCupertinoApp(context);
    }

    if (Platform.isLinux || Platform.isFuchsia) {
      return _buildYaruApp(context);
    }

    if (Platform.isWindows) {
      return _buildFluentApp(context);
    }

    return _buildMaterialApp(context);
  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp(
      title: title,
      home: const Home(),
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }

  Widget _buildCupertinoApp(BuildContext context) {
    return CupertinoApp(
      title: title,
      home: Home(),
      theme: CupertinoThemeData(
        primaryColor: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ).primary,
      ),
    );
  }

  Widget _buildYaruApp(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: yaruLight,
      home: const Home(),
      darkTheme: yaruDark,
      themeMode: themeMode,
    );
  }

  Widget _buildFluentApp(BuildContext context) {
    return fl.FluentApp(
      title: title,
      home: Home(),
      themeMode: themeMode,
      darkTheme: fl.FluentThemeData.dark(),
      theme: fl.FluentThemeData.light(),
    );
  }
}
