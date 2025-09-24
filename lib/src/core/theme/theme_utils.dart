import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/theme/app_color_schemes.dart' as app;
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';

class ThemeUtils {
  /// Get the current platform's primary color
  static Color getPrimaryColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).primaryColor;
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(
          context,
        ).accentColor.defaultBrushFor(fl.FluentTheme.of(context).brightness);
      }
    }
    return Theme.of(context).colorScheme.primary;
  }

  /// Get the current platform's background color
  static Color getBackgroundColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).scaffoldBackgroundColor;
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).scaffoldBackgroundColor;
      }
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Get the current platform's surface color
  static Color getSurfaceColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).barBackgroundColor;
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).cardColor;
      }
    }
    return Theme.of(context).colorScheme.surface;
  }

  /// Get the current platform's text color
  static Color getTextColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.color ??
            (CupertinoTheme.of(context).brightness == Brightness.light
                ? app.AppColorSchemes.cupertinoLight.label
                : app.AppColorSchemes.cupertinoDark.label);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).typography.body?.color ??
            (fl.FluentTheme.of(context).brightness == Brightness.light
                ? app.AppColorSchemes.fluentLight.neutralPrimary
                : app.AppColorSchemes.fluentDark.neutralPrimary);
      }
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get adaptive padding based on platform and screen size
  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? responsive.horizontalPadding,
      vertical: vertical ?? responsive.verticalPadding,
    );
  }

  /// Get adaptive border radius based on platform and screen size
  static BorderRadius getAdaptiveBorderRadius(
    BuildContext context, {
    double? radius,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);
    final adaptiveRadius = radius ?? responsive.borderRadius;

    // Platform-specific adjustments
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return BorderRadius.circular(
          adaptiveRadius * 0.8,
        ); // Slightly smaller for iOS
      }
      if (Platform.isWindows) {
        return BorderRadius.circular(
          adaptiveRadius * 0.6,
        ); // Smaller for Windows
      }
    }
    return BorderRadius.circular(adaptiveRadius);
  }

  /// Get adaptive elevation based on platform
  static double getAdaptiveElevation(
    BuildContext context, {
    double? elevation,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);
    final baseElevation = elevation ?? responsive.cardElevation;

    // Platform-specific adjustments
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return baseElevation * 0.5; // Lower elevation for iOS
      }
      if (Platform.isWindows) {
        return baseElevation * 0.3; // Much lower for Windows
      }
    }
    return baseElevation;
  }

  /// Create an adaptive button style
  static ButtonStyle? getAdaptiveButtonStyle(
    BuildContext context, {
    ButtonType type = ButtonType.primary,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        // Cupertino buttons don't use ButtonStyle, handle separately
        return null;
      }

      if (Platform.isWindows) {
        // Fluent buttons don't use ButtonStyle, handle separately
        return null;
      }
    }

    // Material button style
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          minimumSize: Size(responsive.buttonMinWidth, responsive.buttonHeight),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.smallSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: getAdaptiveBorderRadius(context),
          ),
          elevation: getAdaptiveElevation(context, elevation: 2),
        );
      case ButtonType.secondary:
        return OutlinedButton.styleFrom(
          minimumSize: Size(responsive.buttonMinWidth, responsive.buttonHeight),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.smallSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: getAdaptiveBorderRadius(context),
          ),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          minimumSize: Size(
            responsive.buttonMinWidth * 0.8,
            responsive.buttonHeight,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.smallSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: getAdaptiveBorderRadius(context),
          ),
        );
    }
  }

  /// Create an adaptive card decoration
  static Decoration getAdaptiveCardDecoration(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return BoxDecoration(
          color: getSurfaceColor(context),
          borderRadius: getAdaptiveBorderRadius(context),
          border: Border.all(
            color: CupertinoTheme.of(
              context,
            ).primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: getAdaptiveElevation(context),
              offset: const Offset(0, 2),
            ),
          ],
        );
      }

      if (Platform.isWindows) {
        return BoxDecoration(
          color: getSurfaceColor(context),
          borderRadius: getAdaptiveBorderRadius(context),
          border: Border.all(
            color: fl.FluentTheme.of(context).resources.cardStrokeColorDefault,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: getAdaptiveElevation(context),
              offset: const Offset(0, 1),
            ),
          ],
        );
      }
    }

    // Material design
    return BoxDecoration(
      color: getSurfaceColor(context),
      borderRadius: getAdaptiveBorderRadius(context),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: getAdaptiveElevation(context),
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get adaptive text style
  static TextStyle? getAdaptiveTextStyle(
    BuildContext context,
    TextStyleType type,
  ) {
    final responsive = ResponsiveBreakpoints.of(context);
    final scaleFactor = responsive.textScaleFactor;

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        final theme = CupertinoTheme.of(context).textTheme;
        switch (type) {
          case TextStyleType.headline:
            return theme.navLargeTitleTextStyle.copyWith(
              fontSize:
                  (theme.navLargeTitleTextStyle.fontSize ?? 32) * scaleFactor,
            );
          case TextStyleType.title:
            return theme.navTitleTextStyle.copyWith(
              fontSize: (theme.navTitleTextStyle.fontSize ?? 17) * scaleFactor,
            );
          case TextStyleType.body:
            return theme.textStyle.copyWith(
              fontSize: (theme.textStyle.fontSize ?? 14) * scaleFactor,
            );
          case TextStyleType.caption:
            return theme.textStyle.copyWith(
              fontSize: (theme.textStyle.fontSize ?? 14) * 0.8 * scaleFactor,
              color: app.AppColorSchemes.cupertinoLight.secondaryLabel,
            );
        }
      }

      if (Platform.isWindows) {
        final theme = fl.FluentTheme.of(context).typography;
        switch (type) {
          case TextStyleType.headline:
            return theme.title?.copyWith(
              fontSize: (theme.title?.fontSize ?? 24) * scaleFactor,
            );
          case TextStyleType.title:
            return theme.subtitle?.copyWith(
              fontSize: (theme.subtitle?.fontSize ?? 18) * scaleFactor,
            );
          case TextStyleType.body:
            return theme.body?.copyWith(
              fontSize: (theme.body?.fontSize ?? 14) * scaleFactor,
            );
          case TextStyleType.caption:
            return theme.caption?.copyWith(
              fontSize: (theme.caption?.fontSize ?? 12) * scaleFactor,
            );
        }
      }
    }

    // Material design
    final theme = Theme.of(context).textTheme;
    switch (type) {
      case TextStyleType.headline:
        return theme.headlineMedium?.copyWith(
          fontSize: (theme.headlineMedium?.fontSize ?? 28) * scaleFactor,
        );
      case TextStyleType.title:
        return theme.titleLarge?.copyWith(
          fontSize: (theme.titleLarge?.fontSize ?? 22) * scaleFactor,
        );
      case TextStyleType.body:
        return theme.bodyLarge?.copyWith(
          fontSize: (theme.bodyLarge?.fontSize ?? 16) * scaleFactor,
        );
      case TextStyleType.caption:
        return theme.bodySmall?.copyWith(
          fontSize: (theme.bodySmall?.fontSize ?? 12) * scaleFactor,
        );
    }
  }

  /// Check if current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).brightness == Brightness.dark;
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).brightness == Brightness.dark;
      }
    }
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get platform-appropriate icon
  static IconData getAdaptiveIcon(AdaptiveIcon icon) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        switch (icon) {
          case AdaptiveIcon.home:
            return CupertinoIcons.home;
          case AdaptiveIcon.search:
            return CupertinoIcons.search;
          case AdaptiveIcon.settings:
            return CupertinoIcons.settings;
          case AdaptiveIcon.profile:
            return CupertinoIcons.person;
          case AdaptiveIcon.favorite:
            return CupertinoIcons.heart;
          case AdaptiveIcon.add:
            return CupertinoIcons.add;
          case AdaptiveIcon.back:
            return CupertinoIcons.back;
          case AdaptiveIcon.close:
            return CupertinoIcons.xmark;
        }
      }

      if (Platform.isWindows) {
        switch (icon) {
          case AdaptiveIcon.home:
            return fl.FluentIcons.home;
          case AdaptiveIcon.search:
            return fl.FluentIcons.search;
          case AdaptiveIcon.settings:
            return fl.FluentIcons.settings;
          case AdaptiveIcon.profile:
            return fl.FluentIcons.contact;
          case AdaptiveIcon.favorite:
            return fl.FluentIcons.heart;
          case AdaptiveIcon.add:
            return fl.FluentIcons.add;
          case AdaptiveIcon.back:
            return fl.FluentIcons.back;
          case AdaptiveIcon.close:
            return fl.FluentIcons.chrome_close;
        }
      }
    }

    // Material icons (default)
    switch (icon) {
      case AdaptiveIcon.home:
        return Icons.home;
      case AdaptiveIcon.search:
        return Icons.search;
      case AdaptiveIcon.settings:
        return Icons.settings;
      case AdaptiveIcon.profile:
        return Icons.person;
      case AdaptiveIcon.favorite:
        return Icons.favorite;
      case AdaptiveIcon.add:
        return Icons.add;
      case AdaptiveIcon.back:
        return Icons.arrow_back;
      case AdaptiveIcon.close:
        return Icons.close;
    }
  }
}

enum ButtonType { primary, secondary, text }

enum TextStyleType { headline, title, body, caption }

enum AdaptiveIcon {
  home,
  search,
  settings,
  profile,
  favorite,
  add,
  back,
  close,
}
