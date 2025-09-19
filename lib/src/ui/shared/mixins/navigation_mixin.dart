import 'package:flutter/material.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';

/// Mixin that provides navigation capabilities to ViewModels
/// This allows ViewModels to handle navigation without being tightly coupled to the UI
mixin NavigationMixin {
  NavigationService? _navigationService;

  /// Initialize the navigation service (should be called in ViewModel constructor)
  void initializeNavigation(NavigationService navigationService) {
    _navigationService = navigationService;
  }

  /// Get the navigation service (throws if not initialized)
  NavigationService get navigationService {
    if (_navigationService == null) {
      throw StateError(
        'NavigationService not initialized. Call initializeNavigation() in your ViewModel constructor.',
      );
    }
    return _navigationService!;
  }

  /// Navigate to a named route with error handling
  Future<bool> navigateTo(
    String routeName, {
    Object? arguments,
    String? errorMessage,
  }) async {
    final result = await navigationService.pushNamed(
      routeName,
      arguments: arguments,
    );

    switch (result) {
      case Ok():
        return true;
      case Error():
        _handleNavigationError(result.error, errorMessage);
        return false;
    }
  }

  /// Replace current route with error handling
  Future<bool> navigateToReplacement(
    String routeName, {
    Object? arguments,
    Object? result,
    String? errorMessage,
  }) async {
    final navigationResult = await navigationService.pushReplacementNamed(
      routeName,
      arguments: arguments,
      result: result,
    );

    switch (navigationResult) {
      case Ok():
        return true;
      case Error():
        _handleNavigationError(navigationResult.error, errorMessage);
        return false;
    }
  }

  /// Navigate and clear entire stack with error handling
  Future<bool> navigateToAndClearStack(
    String routeName, {
    Object? arguments,
    String? errorMessage,
  }) async {
    final result = await navigationService.pushNamedAndClearStack(
      routeName,
      arguments: arguments,
    );

    switch (result) {
      case Ok():
        return true;
      case Error():
        _handleNavigationError(result.error, errorMessage);
        return false;
    }
  }

  /// Go back with error handling
  bool goBack([Object? result]) {
    final navigationResult = navigationService.pop(result);

    switch (navigationResult) {
      case Ok():
        return true;
      case Error():
        _handleNavigationError(navigationResult.error);
        return false;
    }
  }

  /// Go back to a specific route
  bool goBackTo(String routeName) {
    final result = navigationService.popUntil(routeName);

    switch (result) {
      case Ok():
        return true;
      case Error():
        _handleNavigationError(result.error);
        return false;
    }
  }

  /// Check if can go back
  bool canGoBack() {
    return navigationService.canPop();
  }

  /// Get current route name
  String? getCurrentRoute() {
    return navigationService.getCurrentRouteName();
  }

  /// Get route arguments safely
  T? getRouteArguments<T>() {
    try {
      return navigationService.getRouteArguments<T>();
    } catch (e) {
      debugPrint('Error getting route arguments: $e');
      return null;
    }
  }

  /// Show platform-appropriate dialog
  Future<T?> showPlatformDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    String? title,
  }) async {
    final result = await navigationService.showDialog<T>(
      child: child,
      barrierDismissible: barrierDismissible,
      title: title,
    );

    switch (result) {
      case Ok():
        return result.value;
      case Error():
        _handleNavigationError(result.error);
        return null;
    }
  }

  /// Show platform-appropriate modal/bottom sheet
  Future<T?> showPlatformModal<T>({
    required Widget child,
    bool isScrollControlled = true,
  }) async {
    final result = await navigationService.showModal<T>(
      child: child,
      isScrollControlled: isScrollControlled,
    );

    switch (result) {
      case Ok():
        return result.value;
      case Error():
        _handleNavigationError(result.error);
        return null;
    }
  }

  /// Show platform-appropriate message
  void showMessage({
    required String message,
    MessageType type = MessageType.info,
    Duration? duration,
  }) {
    final result = navigationService.showMessage(
      message: message,
      type: type,
      duration: duration,
    );

    if (result is Error) {
      _handleNavigationError(result.error);
    }
  }

  /// Show success message
  void showSuccessMessage(String message) {
    showMessage(message: message, type: MessageType.success);
  }

  /// Show error message
  void showErrorMessage(String message) {
    showMessage(message: message, type: MessageType.error);
  }

  /// Show info message
  void showInfoMessage(String message) {
    showMessage(message: message, type: MessageType.info);
  }

  /// Show warning message
  void showWarningMessage(String message) {
    showMessage(message: message, type: MessageType.warning);
  }

  /// Handle navigation errors (can be overridden in ViewModels)
  void _handleNavigationError(Exception error, [String? customMessage]) {
    final message = customMessage ?? 'Navigation failed: ${error.toString()}';
    debugPrint('Navigation error: $message');

    // ViewModels can override this method to handle errors differently
    // For example, showing error messages in the UI
    onNavigationError(error, message);
  }

  /// Override this method in ViewModels to handle navigation errors
  void onNavigationError(Exception error, String message) {
    // Default implementation just prints to debug console
    // ViewModels can override this to show UI feedback
  }

  /// Clean up navigation resources
  void disposeNavigation() {
    _navigationService = null;
  }
}
