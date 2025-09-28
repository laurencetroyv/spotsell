import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/theme_manager.dart';
import 'package:spotsell/src/core/utils/constants.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_progress_ring.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';
import 'package:spotsell/src/ui/shell/adaptive_shell.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const String _title = Constants.title;

  // TODO: Responsive Text Direction and Theme
  static const ThemeMode _themeMode = ThemeMode.system;
  static const TextDirection _textDirection = TextDirection.ltr;

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _textDirection,
      child: FutureBuilder<void>(
        future: _initializeServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingApp(context);
          }

          if (snapshot.hasError) {
            return _buildErrorApp(context, snapshot.error.toString());
          }

          return AdaptiveApplication(
            title: _title,
            themeMode: _themeMode,
            navigatorKey: _navigatorKey,
          );
        },
      ),
    );
  }

  Future<void> _initializeServices() async {
    if (!serviceLocator.isInitialized) {
      await serviceLocator.initialize(navigatorKey: _navigatorKey);
    }
  }

  Widget _buildLoadingApp(BuildContext context) {
    return _buildAppShell(
      context: context,
      home: const AdaptiveScaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdaptiveProgressRing(),
              SizedBox(height: 16),
              Text('Initializing SpotSell...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorApp(BuildContext context, String error) {
    return _buildAppShell(
      context: context,
      home: AdaptiveScaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to initialize app'),
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              AdaptiveButton(
                type: AdaptiveButtonType.secondary,
                onPressed: () {
                  serviceLocator.reset();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppShell({required BuildContext context, required Widget home}) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        final themeMode =
            MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeManager.cupertinoDarkTheme(context)
            : ThemeManager.cupertinoLightTheme(context);
        return CupertinoApp(title: _title, home: home, theme: themeMode);
      }

      if (Platform.isLinux || Platform.isFuchsia) {
        return MaterialApp(
          home: home,
          title: _title,
          themeMode: _themeMode,
          theme: ThemeManager.yaruLightTheme(context),
          darkTheme: ThemeManager.yaruDarkTheme(context),
        );
      }

      if (Platform.isWindows) {
        fl.FluentApp(
          home: home,
          themeMode: _themeMode,
          title: _title,
          theme: ThemeManager.fluentLightTheme(context),
          darkTheme: ThemeManager.fluentDarkTheme(context),
        );
      }
    }

    return MaterialApp(
      home: home,
      title: _title,
      themeMode: _themeMode,
      theme: ThemeManager.materialLightTheme(context),
      darkTheme: ThemeManager.materialDarkTheme(context),
    );
  }
}
