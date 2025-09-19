import 'package:flutter/material.dart';

/// Extensions to make navigation more convenient and type-safe
extension NavigationExtensions on BuildContext {
  /// Navigate to a named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate and clear the entire stack
  Future<T?> pushNamedAndClearStack<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  bool canPop() {
    return Navigator.of(this).canPop();
  }

  /// Get current route name
  String? get currentRouteName {
    return ModalRoute.of(this)?.settings.name;
  }

  /// Get route arguments
  T? getRouteArguments<T>() {
    return ModalRoute.of(this)?.settings.arguments as T?;
  }
}

/// Extension for route validation
extension RouteValidation on String {
  /// Check if route name is valid
  bool get isValidRoute {
    return startsWith('/') && isNotEmpty;
  }

  /// Normalize route name (ensure it starts with /)
  String get normalizedRoute {
    return startsWith('/') ? this : '/$this';
  }
}

/// Extension for safe navigation with error handling
extension SafeNavigation on NavigatorState {
  /// Safely push a route with error handling
  Future<T?> safePushNamed<T>(
    String routeName, {
    Object? arguments,
    VoidCallback? onError,
  }) async {
    try {
      return await pushNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      debugPrint('Navigation error pushing to $routeName: $e');
      onError?.call();
      return null;
    }
  }

  /// Safely pop with error handling
  void safePop<T>([T? result, VoidCallback? onError]) {
    try {
      if (canPop()) {
        pop<T>(result);
      } else {
        onError?.call();
      }
    } catch (e) {
      debugPrint('Navigation error popping: $e');
      onError?.call();
    }
  }
}
