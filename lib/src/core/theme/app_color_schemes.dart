import 'package:flutter/material.dart';

class AppColorSchemes {
  static const Color primaryColor = Color(0xFFF05F42);

  // Material Design Color Schemes
  static const ColorScheme materialLight = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFDAD4),
    onPrimaryContainer: Color(0xFF3C0A00),
    secondary: Color(0xFF775651),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDAD4),
    onSecondaryContainer: Color(0xFF2C1512),
    tertiary: Color(0xFF6F5B2F),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFBDFA6),
    onTertiaryContainer: Color(0xFF251A00),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF231917),
    surfaceContainerHighest: Color(0xFFF5DDD8),
    onSurfaceVariant: Color(0xFF534340),
    outline: Color(0xFF857370),
    onInverseSurface: Color(0xFFFFEDE8),
    inverseSurface: Color(0xFF382E2B),
    inversePrimary: Color(0xFFFFB4A0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: primaryColor,
  );

  static const ColorScheme materialDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB4A0),
    onPrimary: Color(0xFF5F1600),
    primaryContainer: Color(0xFF7F2E0F),
    onPrimaryContainer: Color(0xFFFFDAD4),
    secondary: Color(0xFFE7BDB5),
    onSecondary: Color(0xFF442A26),
    secondaryContainer: Color(0xFF5D403C),
    onSecondaryContainer: Color(0xFFFFDAD4),
    tertiary: Color(0xFFDEC38B),
    onTertiary: Color(0xFF3E2E04),
    tertiaryContainer: Color(0xFF564419),
    onTertiaryContainer: Color(0xFFFBDFA6),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    onError: Color(0xFF690005),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1A110F),
    onSurface: Color(0xFFF1DDD8),
    surfaceContainerHighest: Color(0xFF534340),
    onSurfaceVariant: Color(0xFFD8C2BC),
    outline: Color(0xFFA08C88),
    onInverseSurface: Color(0xFF1A110F),
    inverseSurface: Color(0xFFF1DDD8),
    inversePrimary: primaryColor,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFFFFB4A0),
  );

  // Cupertino Color Schemes
  static const CupertinoColors cupertinoLight = CupertinoColors(
    label: Color(0xFF000000),
    secondaryLabel: Color(0x993C3C43),
    tertiaryLabel: Color(0x4C3C3C43),
    quaternaryLabel: Color(0x2D3C3C43),
    systemFill: Color(0x33787880),
    secondarySystemFill: Color(0x29787880),
    tertiarySystemFill: Color(0x1F767680),
    quaternarySystemFill: Color(0x14747480),
    placeholderText: Color(0x4C3C3C43),
    systemBackground: Color(0xFFFFFFFF),
    secondarySystemBackground: Color(0xFFF2F2F7),
    tertiarySystemBackground: Color(0xFFFFFFFF),
    systemGroupedBackground: Color(0xFFF2F2F7),
    secondarySystemGroupedBackground: Color(0xFFFFFFFF),
    tertiarySystemGroupedBackground: Color(0xFFF2F2F7),
    separator: Color(0x493C3C43),
    opaqueSeparator: Color(0xFFC6C6C8),
    link: primaryColor,
    destructiveRed: Color(0xFFFF3B30),
    systemBlue: Color(0xFF007AFF),
    systemGreen: Color(0xFF34C759),
    systemIndigo: Color(0xFF5856D6),
    systemOrange: Color(0xFFFF9500),
    systemPink: Color(0xFFFF2D92),
    systemPurple: Color(0xFFAF52DE),
    systemRed: Color(0xFFFF3B30),
    systemTeal: Color(0xFF5AC8FA),
    systemYellow: Color(0xFFFFCC00),
    systemGray: Color(0xFF8E8E93),
    systemGray2: Color(0xFFAEAEB2),
    systemGray3: Color(0xFFC7C7CC),
    systemGray4: Color(0xFFD1D1D6),
    systemGray5: Color(0xFFE5E5EA),
    systemGray6: Color(0xFFF2F2F7),
    inactiveGray: Color(0xFF999999),
    activeBlue: primaryColor,
    activeGreen: Color(0xFF55D787),
    activeOrange: Color(0xFFFF9500),
    barBackgroundColor: Color(0xF0F9F9F9),
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
  );

  static const CupertinoColors cupertinoDark = CupertinoColors(
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0x99EBEBF5),
    tertiaryLabel: Color(0x4CEBEBF5),
    quaternaryLabel: Color(0x29EBEBF5),
    systemFill: Color(0x33787880),
    secondarySystemFill: Color(0x29787880),
    tertiarySystemFill: Color(0x1F767680),
    quaternarySystemFill: Color(0x14747480),
    placeholderText: Color(0x4CEBEBF5),
    systemBackground: Color(0xFF000000),
    secondarySystemBackground: Color(0xFF1C1C1E),
    tertiarySystemBackground: Color(0xFF2C2C2E),
    systemGroupedBackground: Color(0xFF000000),
    secondarySystemGroupedBackground: Color(0xFF1C1C1E),
    tertiarySystemGroupedBackground: Color(0xFF2C2C2E),
    separator: Color(0x59545458),
    opaqueSeparator: Color(0xFF38383A),
    link: Color(0xFFFFB4A0),
    destructiveRed: Color(0xFFFF453A),
    systemBlue: Color(0xFF0A84FF),
    systemGreen: Color(0xFF30D158),
    systemIndigo: Color(0xFF5E5CE6),
    systemOrange: Color(0xFFFF9F0A),
    systemPink: Color(0xFFFF375F),
    systemPurple: Color(0xFFBF5AF2),
    systemRed: Color(0xFFFF453A),
    systemTeal: Color(0xFF64D2FF),
    systemYellow: Color(0xFFFFD60A),
    systemGray: Color(0xFF8E8E93),
    systemGray2: Color(0xFF636366),
    systemGray3: Color(0xFF48484A),
    systemGray4: Color(0xFF3A3A3C),
    systemGray5: Color(0xFF2C2C2E),
    systemGray6: Color(0xFF1C1C1E),
    inactiveGray: Color(0xFF999999),
    activeBlue: Color(0xFFFFB4A0),
    activeGreen: Color(0xFF55D787),
    activeOrange: Color(0xFFFF9F0A),
    barBackgroundColor: Color(0xF01C1C1E),
    scaffoldBackgroundColor: Color(0xFF000000),
  );

  // Fluent UI Color Schemes
  static const FluentColors fluentLight = FluentColors(
    scaffoldBackgroundColor: Color(0xFFFAFAFA),
    cardColor: Color(0xFFFFFFFF),
    navigationPaneBackgroundColor: Color(0xFFF3F2F1),
    accentPrimary: primaryColor,
    accentSecondary: Color(0xFFFF8A73),
    neutralPrimary: Color(0xFF323130),
    neutralSecondary: Color(0xFF605E5C),
    neutralTertiary: Color(0xffA19F9D),
    neutralQuaternary: Color(0xFFD2D0CE),
    neutralQuaternaryAlt: Color(0xFFE1DFDD),
    neutralLight: Color(0xFFEAE8E6),
    neutralLighter: Color(0xFFF3F2F1),
    neutralLighterAlt: Color(0xFFFAF9F8),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
  );

  static const FluentColors fluentDark = FluentColors(
    scaffoldBackgroundColor: Color(0xFF1F1F1F),
    cardColor: Color(0xFF2D2D30),
    navigationPaneBackgroundColor: Color(0xFF252526),
    accentPrimary: primaryColor,
    accentSecondary: Color(0xFFFF8A73),
    neutralPrimary: Color(0xFFFFFFFF),
    neutralSecondary: Color(0xFFD2D0CE),
    neutralTertiary: Color(0xFFA19F9D),
    neutralQuaternary: Color(0xFF605E5C),
    neutralQuaternaryAlt: Color(0xFF484644),
    neutralLight: Color(0xFF3B3A39),
    neutralLighter: Color(0xFF323130),
    neutralLighterAlt: Color(0xFF2B2A29),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
  );
}

// Custom Cupertino Colors class
class CupertinoColors {
  const CupertinoColors({
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.quaternaryLabel,
    required this.systemFill,
    required this.secondarySystemFill,
    required this.tertiarySystemFill,
    required this.quaternarySystemFill,
    required this.placeholderText,
    required this.systemBackground,
    required this.secondarySystemBackground,
    required this.tertiarySystemBackground,
    required this.systemGroupedBackground,
    required this.secondarySystemGroupedBackground,
    required this.tertiarySystemGroupedBackground,
    required this.separator,
    required this.opaqueSeparator,
    required this.link,
    required this.destructiveRed,
    required this.systemBlue,
    required this.systemGreen,
    required this.systemIndigo,
    required this.systemOrange,
    required this.systemPink,
    required this.systemPurple,
    required this.systemRed,
    required this.systemTeal,
    required this.systemYellow,
    required this.systemGray,
    required this.systemGray2,
    required this.systemGray3,
    required this.systemGray4,
    required this.systemGray5,
    required this.systemGray6,
    required this.inactiveGray,
    required this.activeBlue,
    required this.activeGreen,
    required this.activeOrange,
    required this.barBackgroundColor,
    required this.scaffoldBackgroundColor,
  });

  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color quaternaryLabel;
  final Color systemFill;
  final Color secondarySystemFill;
  final Color tertiarySystemFill;
  final Color quaternarySystemFill;
  final Color placeholderText;
  final Color systemBackground;
  final Color secondarySystemBackground;
  final Color tertiarySystemBackground;
  final Color systemGroupedBackground;
  final Color secondarySystemGroupedBackground;
  final Color tertiarySystemGroupedBackground;
  final Color separator;
  final Color opaqueSeparator;
  final Color link;
  final Color destructiveRed;
  final Color systemBlue;
  final Color systemGreen;
  final Color systemIndigo;
  final Color systemOrange;
  final Color systemPink;
  final Color systemPurple;
  final Color systemRed;
  final Color systemTeal;
  final Color systemYellow;
  final Color systemGray;
  final Color systemGray2;
  final Color systemGray3;
  final Color systemGray4;
  final Color systemGray5;
  final Color systemGray6;
  final Color inactiveGray;
  final Color activeBlue;
  final Color activeGreen;
  final Color activeOrange;
  final Color barBackgroundColor;
  final Color scaffoldBackgroundColor;
}

// Custom Fluent Colors class
class FluentColors {
  const FluentColors({
    required this.scaffoldBackgroundColor,
    required this.cardColor,
    required this.navigationPaneBackgroundColor,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.neutralPrimary,
    required this.neutralSecondary,
    required this.neutralTertiary,
    required this.neutralQuaternary,
    required this.neutralQuaternaryAlt,
    required this.neutralLight,
    required this.neutralLighter,
    required this.neutralLighterAlt,
    required this.white,
    required this.black,
  });

  final Color scaffoldBackgroundColor;
  final Color cardColor;
  final Color navigationPaneBackgroundColor;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color neutralPrimary;
  final Color neutralSecondary;
  final Color neutralTertiary;
  final Color neutralQuaternary;
  final Color neutralQuaternaryAlt;
  final Color neutralLight;
  final Color neutralLighter;
  final Color neutralLighterAlt;
  final Color white;
  final Color black;
}
