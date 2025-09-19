import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';

/// Fluent UI (Windows) implementation of NavigationService
/// Provides Windows-style navigation patterns and transitions
class FluentNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey;
  final NavigationConfig _config;

  FluentNavigationService(this._navigatorKey, {NavigationConfig? config})
    : _config = config ?? NavigationConfig.fluent;

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

      final result = await fl.showDialog<T>(
        context: _context!,
        barrierDismissible: barrierDismissible,
        builder: (context) => fl.ContentDialog(
          title: title != null ? Text(title) : null,
          content: child,
          actions: [
            fl.FilledButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show Fluent dialog', originalError: e),
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

      // Windows uses dialogs instead of bottom sheets
      final result = await fl.showDialog<T>(
        context: _context!,
        builder: (context) => fl.ContentDialog(
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: child,
          ),
          actions: [
            fl.Button(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show Fluent modal', originalError: e),
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

      // Use Fluent InfoBar for messages
      final infoBar = fl.InfoBar(
        title: Text(_getTitleForMessageType(type)),
        content: Text(message),
        severity: _getSeverityForMessageType(type),
        isLong: message.length > 50,
      );

      // Show InfoBar using overlay
      final overlay = Overlay.of(_context!);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 50,
          right: 20,
          left: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: infoBar,
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      // Auto-dismiss after duration
      Future.delayed(
        duration ?? const Duration(seconds: 4),
        () => overlayEntry.remove(),
      );

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
    // Fluent implementation doesn't need to clear additional state
    // This method is available for platform-specific cleanup if needed
  }

  /// Get appropriate title for message type in Fluent style
  String _getTitleForMessageType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return 'Success';
      case MessageType.error:
        return 'Error';
      case MessageType.warning:
        return 'Warning';
      case MessageType.info:
        return 'Information';
    }
  }

  /// Get Fluent InfoBar severity for message type
  fl.InfoBarSeverity _getSeverityForMessageType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return fl.InfoBarSeverity.success;
      case MessageType.error:
        return fl.InfoBarSeverity.error;
      case MessageType.warning:
        return fl.InfoBarSeverity.warning;
      case MessageType.info:
        return fl.InfoBarSeverity.info;
    }
  }

  /// Show Windows-style confirmation dialog
  Future<Result<bool>> showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for confirmation dialog'),
        );
      }

      final result = await fl.showDialog<bool>(
        context: _context!,
        builder: (context) => fl.ContentDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            fl.Button(
              child: Text(cancelText),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            fl.FilledButton(
              child: Text(confirmText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      return Result.ok(result ?? false);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to show confirmation dialog',
          originalError: e,
        ),
      );
    }
  }

  /// Show Fluent input dialog
  Future<Result<String?>> showInputDialog({
    required String title,
    String? placeholder,
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for input dialog'),
        );
      }

      final controller = TextEditingController(text: initialValue);

      final result = await fl.showDialog<String>(
        context: _context!,
        builder: (context) => fl.ContentDialog(
          title: Text(title),
          content: fl.TextBox(
            controller: controller,
            placeholder: placeholder,
            autofocus: true,
          ),
          actions: [
            fl.Button(
              child: Text(cancelText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            fl.FilledButton(
              child: Text(confirmText),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        ),
      );

      controller.dispose();
      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show input dialog', originalError: e),
      );
    }
  }
}
