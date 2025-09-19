import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
// TODO: Import other screens when created
import 'package:spotsell/src/ui/feature/auth/sign_in_screen.dart';
import 'package:spotsell/src/ui/feature/auth/sign_up_screen.dart';
import 'package:spotsell/src/ui/feature/welcome/welcome_screen.dart';

/// Central router configuration for the application
/// Handles platform-aware route generation and navigation transitions
class AppRouter {
  /// Generate routes based on route settings
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    // Log navigation for debugging
    debugPrint('Navigating to: $routeName with arguments: $arguments');

    // Validate route
    if (routeName == null || !_isValidRoute(routeName)) {
      return _createErrorRoute('Invalid route: $routeName');
    }

    try {
      return _generatePlatformAwareRoute(routeName, arguments, settings);
    } catch (e) {
      debugPrint('Error generating route for $routeName: $e');
      return _createErrorRoute('Failed to load $routeName');
    }
  }

  /// Generate platform-appropriate route based on current platform
  static Route<dynamic> _generatePlatformAwareRoute(
    String routeName,
    Object? arguments,
    RouteSettings settings,
  ) {
    final widget = _getWidgetForRoute(routeName, arguments);

    if (widget == null) {
      return _createErrorRoute('Screen not found: $routeName');
    }

    // Create platform-specific route
    if (Platform.isMacOS || Platform.isIOS) {
      return _createCupertinoRoute(widget, settings);
    }

    if (Platform.isWindows) {
      return _createFluentRoute(widget, settings);
    }

    if (Platform.isLinux || Platform.isFuchsia) {
      return _createYaruRoute(widget, settings);
    }

    // Default to Material (Android and fallback)
    return _createMaterialRoute(widget, settings);
  }

  /// Get the appropriate widget for a route
  static Widget? _getWidgetForRoute(String routeName, Object? arguments) {
    switch (routeName) {
      case RouteNames.welcome:
        return const WelcomeScreen();

      case RouteNames.signIn:
        return const SignInScreen();

      case RouteNames.signUp:
        return const SignUpScreen();

      // TODO: Add other routes when screens are created
      // case AppRoutes.home:
      //   return const HomeScreen();

      // case AppRoutes.profile:
      //   return const ProfileScreen();

      // case AppRoutes.settings:
      //   return const SettingsScreen();

      default:
        return null;
    }
  }

  /// Create Material Design route (Android)
  static Route<dynamic> _createMaterialRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
      maintainState: true,
    );
  }

  /// Create Cupertino route (iOS/macOS)
  static Route<dynamic> _createCupertinoRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    return CupertinoPageRoute(
      builder: (_) => widget,
      settings: settings,
      maintainState: true,
    );
  }

  /// Create Fluent route (Windows)
  static Route<dynamic> _createFluentRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    return fl.FluentPageRoute(
      builder: (_) => widget,
      settings: settings,
      maintainState: true,
    );
  }

  /// Create Yaru route (Linux/Fuchsia)
  static Route<dynamic> _createYaruRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    // Yaru uses Material routes but with custom transitions
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Ubuntu-style slide transition
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Create error route for invalid navigation
  static Route<dynamic> _createErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => _ErrorScreen(message: message),
      settings: const RouteSettings(name: '/error'),
    );
  }

  /// Validate if route name is in allowed routes
  static bool _isValidRoute(String routeName) {
    return RouteNames.allRoutes.contains(routeName);
  }

  /// Handle unknown routes
  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    debugPrint('Unknown route: ${settings.name}');
    return _createErrorRoute('Page not found: ${settings.name}');
  }

  /// Get initial route based on app state
  static String getInitialRoute() {
    // TODO: Add logic to determine initial route based on:
    // - Authentication state
    // - Onboarding completion
    // - Deep linking
    // - Platform-specific considerations

    return RouteNames.welcome;
  }

  /// Navigate to route with platform-aware transition
  static Future<T?> navigateToRoute<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) async {
    final navigator = Navigator.of(context);

    if (clearStack) {
      return navigator.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    }

    if (replace) {
      return navigator.pushReplacementNamed(routeName, arguments: arguments);
    }

    return navigator.pushNamed(routeName, arguments: arguments);
  }

  /// Pop to specific route
  static void popToRoute(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// Get route arguments safely
  static T? getRouteArguments<T>(BuildContext context) {
    try {
      return ModalRoute.of(context)?.settings.arguments as T?;
    } catch (e) {
      debugPrint('Error getting route arguments: $e');
      return null;
    }
  }

  /// Check if a route can be popped
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Get current route name
  static String? getCurrentRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  /// Create custom transition for specific routes
  static Route<T> createCustomRoute<T>({
    required Widget child,
    required RouteSettings settings,
    Duration? transitionDuration,
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    )?
    transitionsBuilder,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      transitionsBuilder:
          transitionsBuilder ??
          (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
    );
  }

  /// Route observers for analytics and debugging
  static final List<NavigatorObserver> navigatorObservers = [
    _AppRouteObserver(),
  ];
}

/// Error screen for invalid routes
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Navigation Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Try to go back, or go to welcome if can't
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(RouteNames.welcome);
                }
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route observer for logging and analytics
class _AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRouteChange('REPLACE', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logRouteChange('REMOVE', route, previousRoute);
  }

  void _logRouteChange(
    String action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = route?.settings.name ?? 'Unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'None';

    debugPrint('Route $action: $routeName (from: $previousRouteName)');

    // TODO: Add analytics tracking here
    // analytics.trackNavigation(action, routeName, previousRouteName);
  }
}
