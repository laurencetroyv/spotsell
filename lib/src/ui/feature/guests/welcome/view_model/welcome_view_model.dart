import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/utils/constants.dart';
import 'package:spotsell/src/ui/feature/guests/welcome/domain/entity/carousel_item.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

/// ViewModel for the Welcome Screen
/// Manages carousel auto-play, navigation, and user interactions
class WelcomeViewModel extends BaseViewModel {
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  bool _isAutoPlayActive = true;
  bool _isDisposed = false;

  /// Current carousel index
  int get currentIndex => _currentIndex;

  /// List of carousel items from constants
  List<CarouselItem> get carouselItems => Constants.carouselItems;

  /// Whether auto-play is currently active
  bool get isAutoPlayActive => _isAutoPlayActive;

  @override
  void initialize() {
    super.initialize();
    _startAutoPlay();
  }

  /// Start auto-play functionality
  void _startAutoPlay() {
    if (_isDisposed || !_isAutoPlayActive) return;

    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isDisposed || !_isAutoPlayActive) {
        timer.cancel();
        return;
      }
      nextPage();
    });
  }

  /// Stop auto-play functionality
  void stopAutoPlay() {
    _isAutoPlayActive = false;
    _autoPlayTimer?.cancel();
    safeNotifyListeners();
  }

  /// Resume auto-play functionality
  void resumeAutoPlay() {
    _isAutoPlayActive = true;
    _startAutoPlay();
    safeNotifyListeners();
  }

  /// Navigate to next carousel page
  void nextPage() {
    _currentIndex = (_currentIndex + 1) % carouselItems.length;
    safeNotifyListeners();
  }

  /// Navigate to previous carousel page
  void previousPage() {
    _currentIndex = _currentIndex > 0
        ? _currentIndex - 1
        : carouselItems.length - 1;
    safeNotifyListeners();
  }

  /// Set specific carousel page
  void setCurrentIndex(int index) {
    if (index >= 0 && index < carouselItems.length) {
      _currentIndex = index;
      safeNotifyListeners();
    }
  }

  /// Handle continue with email button press
  Future<void> handleContinueWithEmail() async {
    await executeAsync<void>(
      () async {
        final success = await navigateTo(RouteNames.signUp);
        if (!success) {
          throw Exception('Failed to navigate to sign up');
        }
      },
      errorMessage: 'Unable to continue with email. Please try again.',
      showLoading: false, // No loading indicator for navigation
    );
  }

  /// Handle sign in button press
  Future<void> handleSignIn() async {
    await executeAsync<void>(
      () async {
        final success = await navigateTo(RouteNames.signIn);
        if (!success) {
          throw Exception('Failed to navigate to sign in');
        }
      },
      errorMessage: 'Unable to sign in. Please try again.',
      showLoading: false, // No loading indicator for navigation
    );
  }

  /// Handle user interaction with carousel (pause auto-play temporarily)
  void onUserInteraction() {
    if (_isAutoPlayActive) {
      _autoPlayTimer?.cancel();

      // Resume auto-play after 5 seconds of no interaction
      Timer(const Duration(seconds: 5), () {
        if (_isAutoPlayActive && !_isDisposed) {
          _startAutoPlay();
        }
      });
    }
  }

  @override
  void onNavigationError(Exception error, String message) {
    // Override to show user-friendly error messages
    showErrorMessage(message);

    if (kDebugMode) {
      print('WelcomeViewModel navigation error: $error');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoPlayTimer?.cancel();
    super.dispose();
  }
}
