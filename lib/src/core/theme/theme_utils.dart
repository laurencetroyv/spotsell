import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/app_color_schemes.dart' as app;
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';

class ThemeUtils {
  static Color getPrimaryColor(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context).primaryColor;
    }

    return Theme.of(context).colorScheme.primary;
  }

  static Color getBackgroundColor(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context).scaffoldBackgroundColor;
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getSurfaceColor(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context).barBackgroundColor;
    }

    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextColor(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context).textTheme.textStyle.color ??
          (CupertinoTheme.of(context).brightness == Brightness.light
              ? app.AppColorSchemes.cupertinoLight.label
              : app.AppColorSchemes.cupertinoDark.label);
    }

    return Theme.of(context).colorScheme.onSurface;
  }

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

  static BorderRadius getAdaptiveBorderRadius(
    BuildContext context, {
    double? radius,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);
    final adaptiveRadius = radius ?? responsive.borderRadius;

    if (Platform.isIOS) {
      return BorderRadius.circular(adaptiveRadius * 0.8);
    }

    return BorderRadius.circular(adaptiveRadius);
  }

  static double getAdaptiveElevation(
    BuildContext context, {
    double? elevation,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);
    final baseElevation = elevation ?? responsive.cardElevation;

    if (Platform.isIOS) {
      return baseElevation * 0.5;
    }

    return baseElevation;
  }

  static ButtonStyle? getAdaptiveButtonStyle(
    BuildContext context, {
    ButtonType type = ButtonType.primary,
  }) {
    final responsive = ResponsiveBreakpoints.of(context);

    if (Platform.isIOS) {
      return null;
    }

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

  static Decoration getAdaptiveCardDecoration(BuildContext context) {
    if (Platform.isIOS) {
      return BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: getAdaptiveBorderRadius(context),
        border: Border.all(
          color: CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.1),
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

  static TextStyle? getAdaptiveTextStyle(
    BuildContext context,
    TextStyleType type,
  ) {
    final responsive = ResponsiveBreakpoints.of(context);
    final scaleFactor = responsive.textScaleFactor;

    if (Platform.isIOS) {
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

  static bool isDarkMode(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context).brightness == Brightness.dark;
    }

    return Theme.of(context).brightness == Brightness.dark;
  }

  static IconData getAdaptiveIcon(AdaptiveIcon icon) {
    if (Platform.isIOS) {
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
        case AdaptiveIcon.signOut:
          return CupertinoIcons.arrow_right_square;
        case AdaptiveIcon.messages:
          return CupertinoIcons.chat_bubble;
        case AdaptiveIcon.store:
          return CupertinoIcons.bag;
        case AdaptiveIcon.error:
          return CupertinoIcons.exclamationmark_triangle;
        case AdaptiveIcon.send:
          return CupertinoIcons.paperplane;
        case AdaptiveIcon.call:
          return CupertinoIcons.phone;
      }
    }

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
      case AdaptiveIcon.signOut:
        return Icons.logout;
      case AdaptiveIcon.messages:
        return Icons.chat;
      case AdaptiveIcon.store:
        return Icons.storefront;
      case AdaptiveIcon.error:
        return Icons.error;
      case AdaptiveIcon.send:
        return Icons.send;
      case AdaptiveIcon.call:
        return Icons.phone;
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
  signOut,
  messages,
  store,
  error,
  send,
  call,
}
