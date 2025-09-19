import 'package:flutter/material.dart' as m3;
import 'package:flutter/widgets.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';

/// Yaru (Ubuntu/Linux) implementation of NavigationService
/// Provides Ubuntu-style navigation patterns and transitions
class YaruNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey;
  final NavigationConfig _config;

  YaruNavigationService(this._navigatorKey, {NavigationConfig? config})
    : _config = config ?? NavigationConfig.yaru;

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
            borderRadius: BorderRadius.circular(
              8,
            ), // Ubuntu-style rounded corners
          ),
          actions: [
            m3.TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show Yaru dialog', originalError: e),
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

      // Ubuntu/Linux uses bottom sheets similar to Material, but with Yaru styling
      final result = await m3.showModalBottomSheet<T>(
        context: _context!,
        isScrollControlled: isScrollControlled,
        backgroundColor: m3.Theme.of(_context!).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: m3.Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: m3.Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: child,
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show Yaru modal', originalError: e),
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

      // Use Ubuntu-style snackbar with custom styling
      final messenger = m3.ScaffoldMessenger.of(_context!);
      final snackBar = m3.SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForMessageType(type),
              color: m3.Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: m3.Colors.white),
              ),
            ),
          ],
        ),
        duration: duration ?? const Duration(seconds: 4),
        backgroundColor: _getBackgroundColorForMessageType(type),
        behavior: m3.SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
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
    // Yaru implementation doesn't need to clear additional state
    // This method is available for platform-specific cleanup if needed
  }

  /// Get appropriate icon for message type in Ubuntu style
  IconData _getIconForMessageType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return m3.Icons.check_circle;
      case MessageType.error:
        return m3.Icons.error;
      case MessageType.warning:
        return m3.Icons.warning;
      case MessageType.info:
        return m3.Icons.info;
    }
  }

  /// Get appropriate background color for message type in Ubuntu style
  Color _getBackgroundColorForMessageType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return const Color(0xFF4CAF50); // Ubuntu green
      case MessageType.error:
        return const Color(0xFFE53935); // Ubuntu red
      case MessageType.warning:
        return const Color(0xFFFF9800); // Ubuntu orange
      case MessageType.info:
        return const Color(0xFF2196F3); // Ubuntu blue
    }
  }

  /// Show Ubuntu-style confirmation dialog
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

      final result = await m3.showDialog<bool>(
        context: _context!,
        builder: (context) => m3.AlertDialog(
          title: Text(title),
          content: Text(content),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: [
            m3.TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            m3.ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: m3.ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(confirmText),
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

  /// Show Ubuntu-style input dialog
  Future<Result<String?>> showInputDialog({
    required String title,
    String? hintText,
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

      final result = await m3.showDialog<String>(
        context: _context!,
        builder: (context) => m3.AlertDialog(
          title: Text(title),
          content: m3.TextField(
            controller: controller,
            decoration: m3.InputDecoration(
              hintText: hintText,
              border: m3.OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            autofocus: true,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: [
            m3.TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            m3.ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              style: m3.ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(confirmText),
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

  /// Show Ubuntu-style progress dialog
  Future<Result<void>> showProgressDialog({
    required String title,
    String? message,
    bool isDismissible = false,
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for progress dialog'),
        );
      }

      m3.showDialog(
        context: _context!,
        barrierDismissible: isDismissible,
        builder: (context) => m3.AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const m3.CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show progress dialog', originalError: e),
      );
    }
  }

  /// Hide progress dialog
  void hideProgressDialog() {
    if (_navigator?.canPop() == true) {
      _navigator!.pop();
    }
  }

  /// Show Ubuntu-style toast notification (using overlay)
  void showToast({
    required String message,
    MessageType type = MessageType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      if (_context == null) return;

      final overlay = Overlay.of(_context!);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          child: m3.Material(
            color: m3.Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColorForMessageType(type),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: m3.Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForMessageType(type),
                    color: m3.Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: m3.Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      // Auto-dismiss after duration
      Future.delayed(duration, () => overlayEntry.remove());
    } catch (e) {
      debugPrint('Failed to show toast: $e');
    }
  }
}
