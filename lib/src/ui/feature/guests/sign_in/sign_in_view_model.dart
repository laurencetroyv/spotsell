import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class SignInViewModel extends BaseViewModel {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  late final AuthService _authService;

  @override
  void initialize() {
    super.initialize();
    try {
      _authService = getService<AuthService>();
    } catch (e) {
      debugPrint('Warning: AuthService not available in ServiceLocator: $e');
      setError('Authentication service unavailable. Please restart the app.');
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  /// Handle sign in process
  Future<void> handleSignIn() async {
    if (!_validateInputs()) return;

    await executeAsyncResult<AuthUser>(
      () => _performSignIn(),
      onSuccess: (user) {
        showSuccessMessage('Welcome back, ${user.username}!');
        // AuthService will automatically notify NavigationGuard
        // NavigationGuard will handle the navigation automatically
        _navigateToUserDashboard();
      },
    );
  }

  /// Handle navigation to sign up screen
  Future<void> handleSignUp() async {
    final success = await navigateTo(
      RouteNames.signUp,
      errorMessage: 'Unable to navigate to sign up screen',
    );

    if (!success) {
      showErrorMessage('Navigation failed. Please try again.');
    }
  }

  /// Handle forgot password flow
  Future<void> handleForgotPassword() async {
    // For now, show a simple dialog
    // TODO: Implement proper forgot password flow
    await showPlatformDialog(
      title: 'Reset Password',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Password reset functionality will be available soon.'),
          const SizedBox(height: 16),
          const Text(
            'For now, please contact support if you need help accessing your account.',
          ),
          const SizedBox(height: 16),
          Text(
            'Support: support@spotsell.com',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Validate user inputs before submission
  bool _validateInputs() {
    if (email.text.trim().isEmpty) {
      showErrorMessage('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(email.text.trim())) {
      showErrorMessage('Please enter a valid email address');
      return false;
    }

    if (password.text.isEmpty) {
      showErrorMessage('Please enter your password');
      return false;
    }

    if (password.text.length < 6) {
      showErrorMessage('Password must be at least 6 characters long');
      return false;
    }

    return true;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// Perform the actual sign in process using AuthService
  Future<Result<AuthUser>> _performSignIn() async {
    try {
      final request = SignInRequest(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // Use AuthService which will handle AuthRepository internally
      return await _authService.signIn(request);
    } catch (e) {
      return Result.error(Exception('Sign in failed: $e'));
    }
  }

  /// Navigate to user's appropriate dashboard based on their role
  void _navigateToUserDashboard() {
    try {
      // Get the route for the user's primary role
      final route = RouteNames.getRouteForRole(_authService.primaryRole);

      // Navigate and clear the entire stack
      navigateToAndClearStack(
        route,
        errorMessage: 'Unable to navigate to dashboard',
      ).then((success) {
        if (!success) {
          // Fallback to home route which will use NavigationGuard
          navigateToAndClearStack(
            RouteNames.home,
            errorMessage: 'Unable to navigate to home screen',
          );
        }
      });
    } catch (e) {
      debugPrint('Error determining user dashboard: $e');
      // Fallback to home route
      navigateToAndClearStack(
        RouteNames.home,
        errorMessage: 'Unable to navigate to home screen',
      );
    }
  }

  /// Clear form data
  void clearForm() {
    email.clear();
    password.clear();
    clearError();
  }

  /// Get form validation status
  bool get isFormValid {
    return email.text.trim().isNotEmpty &&
        password.text.isNotEmpty &&
        _isValidEmail(email.text.trim()) &&
        password.text.length >= 6;
  }

  /// Check if we can enable the sign in button
  bool get canSignIn {
    return isFormValid && !isLoading;
  }

  @override
  void onNavigationError(Exception error, String message) {
    super.onNavigationError(error, message);
    // Log navigation errors for debugging
    debugPrint('SignInViewModel Navigation Error: $message');
    showErrorMessage('Navigation failed. Please try again.');
  }
}
