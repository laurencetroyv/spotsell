import 'dart:io';

import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double wideBreakpoint = 1600;

  static ResponsiveBreakpoints of(BuildContext context) {
    return ResponsiveBreakpoints._(MediaQuery.of(context).size.width);
  }

  const ResponsiveBreakpoints._(this.screenWidth);

  final double screenWidth;

  bool get isMobile => screenWidth < mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
  bool get isDesktop => screenWidth >= desktopBreakpoint;
  bool get isWide => screenWidth >= wideBreakpoint;

  // Platform-aware responsive helpers
  bool get isDesktopPlatform =>
      Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isLinux ||
      Platform.isFuchsia;
  bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;

  // Responsive layout helpers
  double get horizontalPadding {
    if (isMobile) return 16.0;
    if (isTablet) return 24.0;
    if (isDesktop) return 32.0;
    return 48.0; // wide
  }

  double get verticalPadding {
    if (isMobile) return 16.0;
    if (isTablet) return 20.0;
    if (isDesktop) return 24.0;
    return 32.0; // wide
  }

  double get cardElevation {
    if (isMobile) return 2.0;
    if (isTablet) return 4.0;
    return 8.0; // desktop and wide
  }

  double get borderRadius {
    if (isMobile) return 8.0;
    if (isTablet) return 12.0;
    return 16.0; // desktop and wide
  }

  int get gridCrossAxisCount {
    if (isMobile) return 1;
    if (isTablet) return 2;
    if (isDesktop) return 3;
    return 4; // wide
  }

  double get maxContentWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 800;
    if (isDesktop) return 1200;
    return 1600; // wide
  }

  // Navigation helpers
  bool get shouldShowNavigationRail => isTablet || isDesktop;
  bool get shouldShowDrawer => isMobile;
  bool get shouldShowBottomNavigation => isMobile;

  // Typography scale factors
  double get textScaleFactor {
    if (isMobile) return 1.0;
    if (isTablet) return 1.05;
    if (isDesktop) return 1.1;
    return 1.15; // wide
  }

  // Component sizing
  double get buttonHeight {
    if (isMobile) return 48.0;
    if (isTablet) return 52.0;
    return 56.0; // desktop and wide
  }

  double get buttonMinWidth {
    if (isMobile) return 88.0;
    if (isTablet) return 120.0;
    return 140.0; // desktop and wide
  }

  double get iconSize {
    if (isMobile) return 24.0;
    if (isTablet) return 28.0;
    return 32.0; // desktop and wide
  }

  double get appBarHeight {
    if (isMobile) return kToolbarHeight; // 56.0
    if (isTablet) return 64.0;
    return 72.0; // desktop and wide
  }

  // Spacing helpers
  double get smallSpacing => isMobile ? 8.0 : 12.0;
  double get mediumSpacing => isMobile ? 16.0 : 24.0;
  double get largeSpacing => isMobile ? 24.0 : 32.0;
  double get extraLargeSpacing => isMobile ? 32.0 : 48.0;

  // Animation durations (responsive animations)
  Duration get shortAnimationDuration => isMobile
      ? const Duration(milliseconds: 200)
      : const Duration(milliseconds: 150);

  Duration get mediumAnimationDuration => isMobile
      ? const Duration(milliseconds: 300)
      : const Duration(milliseconds: 250);

  Duration get longAnimationDuration => isMobile
      ? const Duration(milliseconds: 500)
      : const Duration(milliseconds: 400);
}
