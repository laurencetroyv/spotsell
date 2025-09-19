import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/app_router.dart';
import 'package:spotsell/src/core/theme/theme_manager.dart';
import 'package:spotsell/src/core/utils/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const String title = Constants.title;

  // TODO: Responsive Text Direction and Theme
  static const ThemeMode themeMode = ThemeMode.system;
  static const TextDirection textDirection = TextDirection.ltr;

  // Global navigator key for navigation service
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: FutureBuilder<void>(
        future: _initializeServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingApp();
          }

          if (snapshot.hasError) {
            return _buildErrorApp(snapshot.error.toString());
          }

          return _buildPlatformAwareApp(context);
        },
      ),
    );
  }

  /// Initialize all services asynchronously
  Future<void> _initializeServices() async {
    if (!serviceLocator.isInitialized) {
      await serviceLocator.initialize(navigatorKey: navigatorKey);
    }
  }

  /// Build loading screen while services initialize
  Widget _buildLoadingApp() {
    return MaterialApp(
      title: title,
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing SpotSell...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error screen if service initialization fails
  Widget _buildErrorApp(String error) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to initialize app'),
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Reset service locator and try again
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
    return Builder(
      builder: (context) => MaterialApp(
        title: title,
        navigatorKey: navigatorKey,
        initialRoute: AppRouter.getInitialRoute(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        navigatorObservers: AppRouter.navigatorObservers,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        theme: ThemeManager.materialLightTheme(context),
        darkTheme: ThemeManager.materialDarkTheme(context),
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context), child: child!);
        },
      ),
    );
  }

  Widget _buildCupertinoApp(BuildContext context) {
    return Builder(
      builder: (context) => CupertinoApp(
        title: title,
        navigatorKey: navigatorKey,
        initialRoute: AppRouter.getInitialRoute(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        navigatorObservers: AppRouter.navigatorObservers,
        debugShowCheckedModeBanner: false,
        theme: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeManager.cupertinoDarkTheme(context)
            : ThemeManager.cupertinoLightTheme(context),
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context), child: child!);
        },
      ),
    );
  }

  Widget _buildYaruApp(BuildContext context) {
    return Builder(
      builder: (context) => MaterialApp(
        title: title,
        navigatorKey: navigatorKey,
        initialRoute: AppRouter.getInitialRoute(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        navigatorObservers: AppRouter.navigatorObservers,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        theme: ThemeManager.yaruLightTheme(context),
        darkTheme: ThemeManager.yaruDarkTheme(context),
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context), child: child!);
        },
      ),
    );
  }

  Widget _buildFluentApp(BuildContext context) {
    return Builder(
      builder: (context) => fl.FluentApp(
        title: title,
        navigatorKey: navigatorKey,
        initialRoute: AppRouter.getInitialRoute(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        navigatorObservers: AppRouter.navigatorObservers,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        theme: ThemeManager.fluentLightTheme(context),
        darkTheme: ThemeManager.fluentDarkTheme(context),
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context), child: child!);
        },
      ),
    );
  }
}
