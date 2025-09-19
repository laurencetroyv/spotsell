import 'package:flutter/material.dart';
import 'package:spotsell/src/core/utils/result.dart';

/// Abstract navigation service that defines the contract for navigation
/// Platform-specific implementations will provide the actual navigation logic
abstract class NavigationService {
  /// Navigate to a named route
  Future<Result<T?>> pushNamed<T>(String routeName, {Object? arguments});

  /// Replace current route with a named route
  Future<Result<T?>> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
  });

  /// Navigate and clear the entire navigation stack
  Future<Result<T?>> pushNamedAndClearStack<T>(
    String routeName, {
    Object? arguments,
  });

  /// Pop the current route
  Result<void> pop<T>([T? result]);

  /// Pop until reaching a specific route
  Result<void> popUntil(String routeName);

  /// Check if navigation can pop
  bool canPop();

  /// Get current route name
  String? getCurrentRouteName();

  /// Get route arguments of specified type
  T? getRouteArguments<T>();

  /// Show platform-appropriate dialog
  Future<Result<T?>> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    String? title,
  });

  /// Show platform-appropriate bottom sheet (mobile) or modal (desktop)
  Future<Result<T?>> showModal<T>({
    required Widget child,
    bool isScrollControlled = true,
  });

  /// Show platform-appropriate snackbar/toast
  Result<void> showMessage({
    required String message,
    MessageType type = MessageType.info,
    Duration? duration,
  });

  /// Navigate back to root and push new route (for deep linking recovery)
  Future<Result<T?>> navigateToRootAndPush<T>(
    String routeName, {
    Object? arguments,
  });

  /// Get the current build context (if available)
  BuildContext? getCurrentContext();

  /// Clear any temporary navigation state
  void clearNavigationState();
}

/// Types of messages for platform-appropriate notifications
enum MessageType { info, success, warning, error }

/// Navigation exceptions for error handling
class NavigationException implements Exception {
  final String message;
  final String? routeName;
  final Object? originalError;

  const NavigationException(this.message, {this.routeName, this.originalError});

  @override
  String toString() {
    return 'NavigationException: $message${routeName != null ? ' (route: $routeName)' : ''}';
  }
}

/// Navigation service factory for creating platform-appropriate implementations
abstract class NavigationServiceFactory {
  /// Create a navigation service based on the current platform
  static NavigationService createForCurrentPlatform(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    // This will be implemented after we create platform-specific services
    throw UnimplementedError(
      'Platform-specific navigation services not yet implemented',
    );
  }
}

/// Navigation configuration for platform-specific behavior
class NavigationConfig {
  final Duration defaultTransitionDuration;
  final bool useNativeTransitions;
  final bool enableGestures;
  final bool maintainState;

  const NavigationConfig({
    this.defaultTransitionDuration = const Duration(milliseconds: 300),
    this.useNativeTransitions = true,
    this.enableGestures = true,
    this.maintainState = true,
  });

  /// Default configuration for Material Design (Android)
  static const NavigationConfig material = NavigationConfig(
    defaultTransitionDuration: Duration(milliseconds: 300),
    useNativeTransitions: true,
    enableGestures: true,
  );

  /// Default configuration for Cupertino (iOS/macOS)
  static const NavigationConfig cupertino = NavigationConfig(
    defaultTransitionDuration: Duration(milliseconds: 350),
    useNativeTransitions: true,
    enableGestures: true,
  );

  /// Default configuration for Fluent (Windows)
  static const NavigationConfig fluent = NavigationConfig(
    defaultTransitionDuration: Duration(milliseconds: 250),
    useNativeTransitions: false,
    enableGestures: false,
  );

  /// Default configuration for Yaru (Linux)
  static const NavigationConfig yaru = NavigationConfig(
    defaultTransitionDuration: Duration(milliseconds: 200),
    useNativeTransitions: false,
    enableGestures: true,
  );
}
