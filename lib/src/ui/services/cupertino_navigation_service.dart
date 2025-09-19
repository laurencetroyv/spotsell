import 'package:flutter/cupertino.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';

/// Cupertino (iOS/macOS) implementation of NavigationService
/// Provides iOS-style navigation patterns and transitions
class CupertinoNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey;
  final NavigationConfig _config;

  CupertinoNavigationService(this._navigatorKey, {NavigationConfig? config})
    : _config = config ?? NavigationConfig.cupertino;

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

      final result = await showCupertinoDialog<T>(
        context: _context!,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: title != null ? Text(title) : null,
          content: child,
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException(
          'Failed to show Cupertino dialog',
          originalError: e,
        ),
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

      // On iOS/macOS, use CupertinoModalPopup instead of bottom sheet
      final result = await showCupertinoModalPopup<T>(
        context: _context!,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.only(top: 16),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(child: child),
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show Cupertino modal', originalError: e),
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

      // Use Cupertino-style alert for messages
      showCupertinoDialog(
        context: _context!,
        builder: (context) => CupertinoAlertDialog(
          title: Text(_getTitleForMessageType(type)),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
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
    // Cupertino implementation doesn't need to clear additional state
    // This method is available for platform-specific cleanup if needed
  }

  /// Get appropriate title for message type in Cupertino style
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

  /// Show iOS-style action sheet
  Future<Result<T?>> showActionSheet<T>({
    required List<CupertinoActionSheetAction> actions,
    String? title,
    String? message,
    Widget? cancelButton,
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for action sheet'),
        );
      }

      final result = await showCupertinoModalPopup<T>(
        context: _context!,
        builder: (context) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          message: message != null ? Text(message) : null,
          actions: actions,
          cancelButton:
              cancelButton ??
              CupertinoActionSheetAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show action sheet', originalError: e),
      );
    }
  }

  /// Show Cupertino date picker
  Future<Result<DateTime?>> showDatePicker({
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  }) async {
    try {
      if (_context == null) {
        return Result.error(
          NavigationException('Context not available for date picker'),
        );
      }

      DateTime selectedDate = initialDate;

      final result = await showCupertinoModalPopup<DateTime>(
        context: _context!,
        builder: (context) => Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 50,
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(selectedDate),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: initialDate,
                  minimumDate: minimumDate,
                  maximumDate: maximumDate,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        ),
      );

      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(
        NavigationException('Failed to show date picker', originalError: e),
      );
    }
  }
}
