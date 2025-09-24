import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/data/entities/user_role.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/admin/admin_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/buyer_screen.dart';
import 'package:spotsell/src/ui/feature/guests/sign_in/sign_in_screen.dart';
import 'package:spotsell/src/ui/feature/guests/sign_up/sign_up_screen.dart';
import 'package:spotsell/src/ui/feature/guests/welcome/welcome_screen.dart';
import 'package:spotsell/src/ui/feature/navigation_guard.dart';
import 'package:spotsell/src/ui/feature/seller/seller_screen.dart';

/// Central router configuration for the application
/// Handles platform-aware route generation, navigation transitions, and authentication guards
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
    // Handle authentication-protected routes
    if (RouteNames.requiresAuth(routeName)) {
      return _createAuthenticatedRoute(routeName, arguments, settings);
    }

    final widget = _getWidgetForRoute(routeName, arguments);

    if (widget == null) {
      return _createErrorRoute('Screen not found: $routeName');
    }

    return _createPlatformSpecificRoute(widget, settings);
  }

  /// Create route for authenticated screens
  static Route<dynamic> _createAuthenticatedRoute(
    String routeName,
    Object? arguments,
    RouteSettings settings,
  ) {
    Widget widget;

    try {
      final authService = getService<AuthService>();

      // Check if user is authenticated
      if (!authService.isAuthenticated) {
        // Redirect to welcome screen if not authenticated
        widget = const WelcomeScreen();
      } else {
        // Get the appropriate widget based on route and user role
        widget =
            _getAuthenticatedWidget(routeName, authService) ??
            _getWidgetForRole(authService.primaryRole);
      }
    } catch (e) {
      // If auth service is not available, redirect to welcome
      debugPrint('Auth service not available: $e');
      widget = const WelcomeScreen();
    }

    return _createPlatformSpecificRoute(widget, settings);
  }

  /// Get widget for authenticated routes based on route name and user permissions
  static Widget? _getAuthenticatedWidget(
    String routeName,
    AuthService authService,
  ) {
    switch (routeName) {
      case RouteNames.home:
        // Home route uses AuthGuard to determine appropriate screen
        return const NavigationGuard();

      case RouteNames.buyer:
        return const BuyerScreen();

      case RouteNames.seller:
        // Check if user has seller role
        if (!authService.isSeller) {
          return _UnauthorizedScreen(
            requiredRole: 'Seller',
            message: 'You need seller permissions to access this area.',
          );
        }
        return const SellerScreen();

      case RouteNames.admin:
        // Check if user has admin role
        if (!authService.isAdmin) {
          return _UnauthorizedScreen(
            requiredRole: 'Admin',
            message: 'You need administrator permissions to access this area.',
          );
        }
        return const AdminScreen();

      // TODO: Add other authenticated routes like profile, settings
      case RouteNames.profile:
      case RouteNames.settings:
        return _ComingSoonScreen(routeName: routeName);

      default:
        return null;
    }
  }

  /// Get widget based on user's primary role
  static Widget _getWidgetForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const AdminScreen();
      case UserRole.seller:
        return const SellerScreen();
      case UserRole.buyer:
        return const BuyerScreen();
    }
  }

  /// Get the appropriate widget for a route (non-authenticated routes)
  static Widget? _getWidgetForRoute(String routeName, Object? arguments) {
    switch (routeName) {
      case RouteNames.welcome:
        return const WelcomeScreen();

      case RouteNames.signIn:
        return const SignInScreen();

      case RouteNames.signUp:
        return const SignUpScreen();

      case RouteNames.home:
        // Home route uses AuthGuard to determine appropriate screen
        return const NavigationGuard();

      default:
        return null;
    }
  }

  /// Create platform-specific route
  static Route<dynamic> _createPlatformSpecificRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return _createCupertinoRoute(widget, settings);
      }

      if (Platform.isWindows) {
        return _createFluentRoute(widget, settings);
      }

      if (Platform.isLinux || Platform.isFuchsia) {
        return _createYaruRoute(widget, settings);
      }
    }

    // Default to Material (Android and fallback)
    return _createMaterialRoute(widget, settings);
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
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    // Always start with AuthGuard which will handle authentication state
    return RouteNames.home;
  }

  /// Route observers for analytics and debugging
  static final List<NavigatorObserver> navigatorObservers = [
    _AppRouteObserver(),
  ];
}

/// Helper screens for error states and unauthorized access

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
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(RouteNames.home);
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

class _UnauthorizedScreen extends StatelessWidget {
  final String requiredRole;
  final String message;

  const _UnauthorizedScreen({
    required this.requiredRole,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(RouteNames.home),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Access Restricted',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Required role: $requiredRole',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(RouteNames.home),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String routeName;

  const _ComingSoonScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    final featureName = routeName.replaceAll('/', '').toUpperCase();

    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The $featureName feature is under development.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

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
