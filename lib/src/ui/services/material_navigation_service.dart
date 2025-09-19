import 'package:flutter/material.dart' as m3;
import 'package:flutter/widgets.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';

/// Material Design implementation of NavigationService
/// Provides Android-style navigation patterns and transitions
class MaterialNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey;
  final NavigationConfig _config;

  MaterialNavigationService(this._navigatorKey, {NavigationConfig? config})
    : _config = config ?? NavigationConfig.material;

  NavigatorState? get _navigator => _navigatorKey.currentState;
  BuildContext? get _context => _navigatorKey.currentContext;

  @override
  Future<Result<T?>> pushNamed<T>(String routeName, {Object? arguments}) async {
    try {
      if (_navigator == null) {
        return Result.error(
          NavigationException('Navigator not available', routeName: routeName),
        );
      }

      final result = await _navigator!.pushNamed<T>(
        routeName,
        arguments: arguments,
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to navigate to route',
          routeName: routeName,
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<T?>> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    try {
      if (_navigator == null) {
        return Result.error(
          NavigationException('Navigator not available', routeName: routeName),
        );
      }

      final navigationResult = await _navigator!.pushReplacementNamed<T, TO>(
        routeName,
        arguments: arguments,
        result: result,
      );

      return Result.ok(navigationResult);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to replace route',
          routeName: routeName,
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<T?>> pushNamedAndClearStack<T>(
    String routeName, {
    Object? arguments,
  }) async {
    try {
      if (_navigator == null) {
        return Result.error(
          NavigationException('Navigator not available', routeName: routeName),
        );
      }

      final result = await _navigator!.pushNamedAndRemoveUntil<T>(
        routeName,
        (route) => false,
        arguments: arguments,
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to navigate and clear stack',
          routeName: routeName,
          originalError: e,
        ),
      );
    }
  }

  @override
  Result<void> pop<T>([T? result]) {
    try {
      if (_navigator == null || !_navigator!.canPop()) {
        return Result.error(
          NavigationException(
            'Cannot pop: no routes to pop or navigator unavailable',
          ),
        );
      }

      _navigator!.pop<T>(result);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to pop route', originalError: e),
      );
    }
  }

  @override
  Result<void> popUntil(String routeName) {
    try {
      if (_navigator == null) {
        return Result.error(NavigationException('Navigator not available'));
      }

      _navigator!.popUntil(ModalRoute.withName(routeName));
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to pop until route',
          routeName: routeName,
          originalError: e,
        ),
      );
    }
  }

  @override
  bool canPop() {
    return _navigator?.canPop() ?? false;
  }

  @override
  String? getCurrentRouteName() {
    return ModalRoute.of(_context!)?.settings.name;
  }

  @override
  T? getRouteArguments<T>() {
    return ModalRoute.of(_context!)?.settings.arguments as T?;
  }

  @override
  Future<Result<T?>> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    String? title,
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for dialog'),
        );
      }

      final result = await m3.showDialog<T>(
        context: _context!,
        barrierDismissible: barrierDismissible,
        builder: (context) => m3.AlertDialog(
          title: title != null ? Text(title) : null,
          content: child,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show dialog', originalError: e),
      );
    }
  }

  @override
  Future<Result<T?>> showModal<T>({
    required Widget child,
    bool isScrollControlled = true,
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for modal'),
        );
      }

      final result = await m3.showModalBottomSheet<T>(
        context: _context!,
        isScrollControlled: isScrollControlled,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => child,
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to show modal bottom sheet',
          originalError: e,
        ),
      );
    }
  }

  @override
  Result<void> showMessage({
    required String message,
    MessageType type = MessageType.info,
    Duration? duration,
  }) {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for message'),
        );
      }

      final messenger = m3.ScaffoldMessenger.of(_context!);
      final snackBar = m3.SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 4),
        backgroundColor: _getBackgroundColorForMessageType(type),
        behavior: m3.SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: type == MessageType.error
            ? m3.SnackBarAction(
                label: 'Dismiss',
                textColor: m3.Colors.white,
                onPressed: () => messenger.hideCurrentSnackBar(),
              )
            : null,
      );

      messenger.showSnackBar(snackBar);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show message', originalError: e),
      );
    }
  }

  @override
  Future<Result<T?>> navigateToRootAndPush<T>(
    String routeName, {
    Object? arguments,
  }) async {
    // First clear the stack, then navigate
    await pushNamedAndClearStack('/', arguments: null);

    // Then navigate to the desired route
    return pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  BuildContext? getCurrentContext() {
    return _context;
  }

  @override
  void clearNavigationState() {
    // Material implementation doesn't need to clear additional state
    // This method is available for platform-specific cleanup if needed
  }

  /// Get appropriate background color for message type
  Color? _getBackgroundColorForMessageType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return m3.Colors.green;
      case MessageType.error:
        return m3.Colors.red;
      case MessageType.warning:
        return m3.Colors.orange;
      case MessageType.info:
        return null; // Use default theme color
    }
  }
}
