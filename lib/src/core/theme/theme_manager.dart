import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:yaru/yaru.dart';

import 'package:spotsell/src/core/theme/app_color_schemes.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';

class ThemeManager {
  static const Color primaryColor = Color(0xFFF05F42);

  // Material Theme
  static ThemeData materialLightTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.materialLight,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: responsive.isDesktop ? 1 : 0,
        toolbarHeight: responsive.isDesktop ? 64 : 56,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            responsive.isDesktop ? 120 : 100,
            responsive.isDesktop ? 48 : 44,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.isDesktop ? 24 : 16,
            vertical: responsive.isDesktop ? 12 : 8,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: responsive.isDesktop ? 2 : 1,
        margin: EdgeInsets.all(responsive.isDesktop ? 16 : 8),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.isDesktop ? 24 : 16,
          vertical: responsive.isDesktop ? 8 : 4,
        ),
      ),
      textTheme: _buildResponsiveTextTheme(context, Brightness.light),
    );
  }

  static ThemeData materialDarkTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.materialDark,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: responsive.isDesktop ? 1 : 0,
        toolbarHeight: responsive.isDesktop ? 64 : 56,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            responsive.isDesktop ? 120 : 100,
            responsive.isDesktop ? 48 : 44,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.isDesktop ? 24 : 16,
            vertical: responsive.isDesktop ? 12 : 8,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: responsive.isDesktop ? 2 : 1,
        margin: EdgeInsets.all(responsive.isDesktop ? 16 : 8),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.isDesktop ? 24 : 16,
          vertical: responsive.isDesktop ? 8 : 4,
        ),
      ),
      textTheme: _buildResponsiveTextTheme(context, Brightness.dark),
    );
  }

  // Cupertino Theme
  static CupertinoThemeData cupertinoLightTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return CupertinoThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor:
          AppColorSchemes.cupertinoLight.scaffoldBackgroundColor,
      barBackgroundColor: AppColorSchemes.cupertinoLight.barBackgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColorSchemes.cupertinoLight.label,
        textStyle: TextStyle(
          fontSize: responsive.isDesktop ? 16 : 14,
          color: AppColorSchemes.cupertinoLight.label,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: responsive.isDesktop ? 20 : 17,
          fontWeight: FontWeight.w600,
          color: AppColorSchemes.cupertinoLight.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: responsive.isDesktop ? 36 : 32,
          fontWeight: FontWeight.bold,
          color: AppColorSchemes.cupertinoLight.label,
        ),
      ),
    );
  }

  static CupertinoThemeData cupertinoDarkTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return CupertinoThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          AppColorSchemes.cupertinoDark.scaffoldBackgroundColor,
      barBackgroundColor: AppColorSchemes.cupertinoDark.barBackgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColorSchemes.cupertinoDark.label,
        textStyle: TextStyle(
          fontSize: responsive.isDesktop ? 16 : 14,
          color: AppColorSchemes.cupertinoDark.label,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: responsive.isDesktop ? 20 : 17,
          fontWeight: FontWeight.w600,
          color: AppColorSchemes.cupertinoDark.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: responsive.isDesktop ? 36 : 32,
          fontWeight: FontWeight.bold,
          color: AppColorSchemes.cupertinoDark.label,
        ),
      ),
    );
  }

  // Fluent Theme
  static fl.FluentThemeData fluentLightTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return fl.FluentThemeData.light().copyWith(
      accentColor: fl.AccentColor.swatch({
        'darkest': const Color(0xFF8B2914),
        'darker': const Color(0xFFA8311A),
        'dark': const Color(0xFFC63820),
        'normal': primaryColor,
        'light': const Color(0xFFF37A62),
        'lighter': const Color(0xFFF69582),
        'lightest': const Color(0xFFF8B0A2),
      }),
      scaffoldBackgroundColor:
          AppColorSchemes.fluentLight.scaffoldBackgroundColor,
      cardColor: AppColorSchemes.fluentLight.cardColor,
      typography: fl.Typography.fromBrightness(brightness: Brightness.light)
          .apply(
            fontFamily: Platform.isWindows ? 'Segoe UI' : null,

            // bodyLarge: TextStyle(fontSize: responsive.isDesktop ? 16 : 14),
            // bodyMedium: TextStyle(fontSize: responsive.isDesktop ? 14 : 12),
            // headlineLarge: TextStyle(
            //   fontSize: responsive.isDesktop ? 32 : 28,
            //   fontWeight: FontWeight.w600,
            // ),
          ),
      navigationPaneTheme: fl.NavigationPaneThemeData(
        backgroundColor:
            AppColorSchemes.fluentLight.navigationPaneBackgroundColor,
      ),
    );
  }

  static fl.FluentThemeData fluentDarkTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return fl.FluentThemeData.dark().copyWith(
      accentColor: fl.AccentColor.swatch({
        'darkest': const Color(0xFF8B2914),
        'darker': const Color(0xFFA8311A),
        'dark': const Color(0xFFC63820),
        'normal': primaryColor,
        'light': const Color(0xFFF37A62),
        'lighter': const Color(0xFFF69582),
        'lightest': const Color(0xFFF8B0A2),
      }),
      scaffoldBackgroundColor:
          AppColorSchemes.fluentDark.scaffoldBackgroundColor,
      cardColor: AppColorSchemes.fluentDark.cardColor,
      typography: fl.Typography.fromBrightness(brightness: Brightness.dark)
          .apply(
            fontFamily: Platform.isWindows ? 'Segoe UI' : null,
            // bodyLarge: TextStyle(fontSize: responsive.isDesktop ? 16 : 14),
            // bodyMedium: TextStyle(fontSize: responsive.isDesktop ? 14 : 12),
            // headlineLarge: TextStyle(
            //   fontSize: responsive.isDesktop ? 32 : 28,
            //   fontWeight: FontWeight.w600,
            // ),
          ),
      navigationPaneTheme: fl.NavigationPaneThemeData(
        backgroundColor:
            AppColorSchemes.fluentDark.navigationPaneBackgroundColor,
      ),
    );
  }

  // Yaru Theme (Linux/Fuchsia)
  static ThemeData yaruLightTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return yaruLight.copyWith(
      colorScheme: AppColorSchemes.materialLight,
      appBarTheme: yaruLight.appBarTheme.copyWith(
        toolbarHeight: responsive.isDesktop ? 64 : 56,
      ),
      textTheme: _buildResponsiveTextTheme(context, Brightness.light),
    );
  }

  static ThemeData yaruDarkTheme(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return yaruDark.copyWith(
      colorScheme: AppColorSchemes.materialDark,
      appBarTheme: yaruDark.appBarTheme.copyWith(
        toolbarHeight: responsive.isDesktop ? 64 : 56,
      ),
      textTheme: _buildResponsiveTextTheme(context, Brightness.dark),
    );
  }

  // Helper method for responsive text themes
  static TextTheme _buildResponsiveTextTheme(
    BuildContext context,
    Brightness brightness,
  ) {
    final responsive = ResponsiveBreakpoints.of(context);
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    final scaleFactor = responsive.isDesktop ? 1.1 : 1.0;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: (baseTheme.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: (baseTheme.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: (baseTheme.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: (baseTheme.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: (baseTheme.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * scaleFactor,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * scaleFactor,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * scaleFactor,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * scaleFactor,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * scaleFactor,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * scaleFactor,
      ),
    );
  }
}
