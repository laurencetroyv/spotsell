import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/admin/admin_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/buyer_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/pages/manage_store_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/pages/message_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/pages/product_detail_screen.dart';
import 'package:spotsell/src/ui/feature/guests/sign_in/sign_in_screen.dart';
import 'package:spotsell/src/ui/feature/guests/sign_up/sign_up_screen.dart';
import 'package:spotsell/src/ui/feature/guests/welcome/welcome_screen.dart';
import 'package:spotsell/src/ui/feature/navigation_guard.dart';
import 'package:spotsell/src/ui/feature/seller/pages/add_product_screen.dart';
import 'package:spotsell/src/ui/feature/seller/seller_screen.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    debugPrint('Navigating to: $routeName with arguments: $arguments');

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

  static Route<dynamic> _generatePlatformAwareRoute(
    String routeName,
    Object? arguments,
    RouteSettings settings,
  ) {
    if (RouteNames.requiresAuth(routeName)) {
      return _createAuthenticatedRoute(routeName, arguments, settings);
    }

    final widget = _getWidgetForRoute(routeName, arguments);

    if (widget == null) {
      return _createErrorRoute('Screen not found: $routeName');
    }

    return _createPlatformSpecificRoute(widget, settings);
  }

  static Route<dynamic> _createAuthenticatedRoute(
    String routeName,
    Object? arguments,
    RouteSettings settings,
  ) {
    Widget widget;

    try {
      final authService = getService<AuthService>();

      if (!authService.isAuthenticated) {
        widget = const WelcomeScreen();
      } else {
        widget =
            _getAuthenticatedWidget(routeName, authService) ??
            _getWidgetForRole(authService.primaryRole);
      }
    } catch (e) {
      debugPrint('Auth service not available: $e');
      widget = const WelcomeScreen();
    }

    return _createPlatformSpecificRoute(widget, settings);
  }

  static Widget? _getAuthenticatedWidget(
    String routeName,
    AuthService authService,
  ) {
    switch (routeName) {
      case RouteNames.home:
        return const NavigationGuard();

      case RouteNames.manageStores:
        return const ManageStoresScreen();

      case RouteNames.seller:
        return const SellerScreen();

      case RouteNames.addProduct:
        return const AddProductScreen();

      case RouteNames.productDetail:
        return const ProductDetailScreen();

      case RouteNames.message:
        return const MessageScreen();

      default:
        return _ComingSoonScreen(routeName: routeName);
    }
  }

  static Widget _getWidgetForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const AdminScreen();
      default:
        return const BuyerScreen();
    }
  }

  static Widget? _getWidgetForRoute(String routeName, Object? arguments) {
    switch (routeName) {
      case RouteNames.welcome:
        return const WelcomeScreen();

      case RouteNames.signIn:
        return const SignInScreen();

      case RouteNames.signUp:
        return const SignUpScreen();

      case RouteNames.home:
        return const NavigationGuard();

      default:
        return null;
    }
  }

  static Route<dynamic> _createPlatformSpecificRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    if (Platform.isIOS) {
      return _createCupertinoRoute(widget, settings);
    }

    return _createMaterialRoute(widget, settings);
  }

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

  static Route<dynamic> _createErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => _ErrorScreen(message: message),
      settings: const RouteSettings(name: '/error'),
    );
  }

  static bool _isValidRoute(String routeName) {
    return RouteNames.allRoutes.contains(routeName);
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    debugPrint('Unknown route: ${settings.name}');
    return _createErrorRoute('Page not found: ${settings.name}');
  }

  static String getInitialRoute() {
    return RouteNames.home;
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AppBar(title: const Text('Error')),
      child: Center(
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

class _ComingSoonScreen extends StatelessWidget {
  final String routeName;

  const _ComingSoonScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    final featureName = routeName.replaceAll('/', '').toUpperCase();

    return AdaptiveScaffold(
      appBar: AppBar(title: Text(featureName)),
      child: Center(
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
