import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/navigation/app_router.dart';
import 'package:spotsell/src/core/theme/theme_manager.dart';

class AdaptiveApplication extends StatelessWidget {
  const AdaptiveApplication({
    super.key,
    required this.title,
    required this.themeMode,
    required this.navigatorKey,
  });

  final String title;

  final GlobalKey<NavigatorState> navigatorKey;

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS || Platform.isIOS) {
      return _buildCupertinoApp(context);
    }

    return _buildMaterialApp(context);
  }

  Widget _buildMaterialApp(BuildContext context) {
    return Builder(
      builder: (context) => MaterialApp(
        title: title,
        themeMode: themeMode,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        onUnknownRoute: AppRouter.onUnknownRoute,
        initialRoute: AppRouter.getInitialRoute(),
        onGenerateRoute: AppRouter.onGenerateRoute,
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
        debugShowCheckedModeBanner: false,
        onUnknownRoute: AppRouter.onUnknownRoute,
        initialRoute: AppRouter.getInitialRoute(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeManager.cupertinoDarkTheme(context)
            : ThemeManager.cupertinoLightTheme(context),
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context), child: child!);
        },
      ),
    );
  }
}
