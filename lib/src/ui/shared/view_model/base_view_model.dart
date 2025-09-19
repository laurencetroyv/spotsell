import 'package:flutter/foundation.dart';
import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';
import 'package:spotsell/src/ui/shared/mixins/navigation_mixin.dart';

/// Base class for all ViewModels in the application
/// Provides common functionality like loading states, error handling, and lifecycle management
abstract class BaseViewModel extends ChangeNotifier with NavigationMixin {
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;

  /// Whether the ViewModel is currently loading
  bool get isLoading => _isLoading;

  /// Current error message, if any
  String? get errorMessage => _errorMessage;

  /// Whether there's currently an error
  bool get hasError => _errorMessage != null;

  /// Constructor that automatically initializes navigation
  BaseViewModel() {
    // Initialize navigation service from service locator
    try {
      final navigationService = getService<NavigationService>();
      initializeNavigation(navigationService);
    } catch (e) {
      debugPrint(
        'Warning: NavigationService not available in ServiceLocator: $e',
      );
    }
  }

  /// Set loading state
  @protected
  void setLoading(bool loading) {
    if (_isDisposed) return;

    _isLoading = loading;

    // Clear error when starting to load
    if (loading) {
      _errorMessage = null;
    }

    notifyListeners();
  }

  /// Set error message
  @protected
  void setError(String? error) {
    if (_isDisposed) return;

    _errorMessage = error;
    _isLoading = false; // Stop loading when error occurs
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    if (_isDisposed) return;

    _errorMessage = null;
    notifyListeners();
  }

  /// Execute an async operation with automatic loading state management
  @protected
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showLoading = true,
  }) async {
    if (_isDisposed) return null;

    try {
      if (showLoading) setLoading(true);

      final result = await operation();

      if (showLoading) setLoading(false);
      return result;
    } catch (error) {
      setError(errorMessage ?? error.toString());
      if (kDebugMode) {
        print('ViewModel error: $error');
      }
      return null;
    }
  }

  /// Execute an async operation that returns a Result<T>
  @protected
  Future<bool> executeAsyncResult<T>(
    Future<Result<T>> Function() operation, {
    String? errorMessage,
    bool showLoading = true,
    Function(T)? onSuccess,
  }) async {
    if (_isDisposed) return false;

    try {
      if (showLoading) setLoading(true);

      final result = await operation();

      switch (result) {
        case Ok<T>():
          if (showLoading) setLoading(false);
          onSuccess?.call(result.value);
          return true;
        case Error<T>():
          setError(errorMessage ?? result.error.toString());
          return false;
      }
    } catch (error) {
      setError(errorMessage ?? error.toString());
      if (kDebugMode) {
        print('ViewModel error: $error');
      }
      return false;
    }
  }

  /// Called when the ViewModel is initialized
  @mustCallSuper
  void initialize() {
    // Override in subclasses for initialization logic
  }

  /// Called when the ViewModel is being disposed
  @mustCallSuper
  @override
  void dispose() {
    _isDisposed = true;
    disposeNavigation(); // Clean up navigation resources
    super.dispose();
  }

  /// Safely notify listeners only if not disposed
  @protected
  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
