import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/auth_request.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

/// ViewModel for the Sign Up Screen
/// Manages user registration form, validation, and submission
class SignUpViewModel extends BaseViewModel {
  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  // Additional fields
  bool? gender; // true = male, false = female
  File? profilePicture;
  DateTime? _selectedDateOfBirth;

  String get firstName => firstNameController.text;
  String get lastName => lastNameController.text;
  String get username => usernameController.text;
  String get dateOfBirth => dateOfBirthController.text;
  String get email => emailController.text;
  String get phone => phoneController.text;
  String get password => passwordController.text;
  String get passwordConfirmation => passwordConfirmationController.text;

  // Image picker instance
  final ImagePicker _imagePicker = ImagePicker();

  /// Get the selected date of birth
  DateTime? get selectedDateOfBirth => _selectedDateOfBirth;

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
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    dateOfBirthController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  /// Set the date of birth and update the text field
  void setDateOfBirth(DateTime date) {
    _selectedDateOfBirth = date;
    dateOfBirthController.text = DateFormat('MMM dd, yyyy').format(date);
    safeNotifyListeners();
  }

  /// Handle sign up process
  Future<void> handleSignUp() async {
    if (!_validateInputs()) return;

    await executeAsyncResult<AuthUser>(
      () => _performSignUp(),
      onSuccess: (user) {
        showSuccessMessage('Welcome to SpotSell, ${user.username}!');
        clearForm();
        // AuthService will automatically notify NavigationGuard
        // NavigationGuard will handle the navigation automatically
        _navigateToUserDashboard();
      },
    );
  }

  /// Handle navigation to sign in screen
  Future<void> handleSignIn() async {
    final success = await navigateTo(
      RouteNames.signIn,
      errorMessage: 'Unable to navigate to sign in screen',
    );

    if (!success) {
      showErrorMessage('Navigation failed. Please try again.');
    }
  }

  /// Validate all form inputs
  bool _validateInputs() {
    // Clear any existing errors
    clearError();

    // First Name validation
    if (firstName.trim().isEmpty) {
      showErrorMessage('Please enter your first name');
      return false;
    }

    if (firstName.trim().length < 2) {
      showErrorMessage('First name must be at least 2 characters long');
      return false;
    }

    // Last Name validation
    if (lastName.trim().isEmpty) {
      showErrorMessage('Please enter your last name');
      return false;
    }

    if (lastName.trim().length < 2) {
      showErrorMessage('Last name must be at least 2 characters long');
      return false;
    }

    // Phone validation
    if (phone.trim().length < 11) {
      showErrorMessage('Phone number must be at least 11 characters long');
      return false;
    }

    // Username validation
    if (username.trim().isEmpty) {
      showErrorMessage('Please choose a username');
      return false;
    }

    if (username.trim().length < 3) {
      showErrorMessage('Username must be at least 3 characters long');
      return false;
    }

    if (!_isValidUsername(username.trim())) {
      showErrorMessage(
        'Username can only contain letters, numbers, dots, and underscores',
      );
      return false;
    }

    // Date of Birth validation
    if (_selectedDateOfBirth == null) {
      showErrorMessage('Please select your date of birth');
      return false;
    }

    if (!_isValidAge(_selectedDateOfBirth!)) {
      showErrorMessage(
        'You must be at least 13 years old to create an account',
      );
      return false;
    }

    // Gender validation
    if (gender == null) {
      showErrorMessage('Please select your gender');
      return false;
    }

    // Email validation
    if (email.trim().isEmpty) {
      showErrorMessage('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(email.trim())) {
      showErrorMessage('Please enter a valid email address');
      return false;
    }

    // Password validation
    if (password.isEmpty) {
      showErrorMessage('Please create a password');
      return false;
    }

    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      showErrorMessage(passwordValidation);
      return false;
    }

    // Password confirmation validation
    if (passwordConfirmation.isEmpty) {
      showErrorMessage('Please confirm your password');
      return false;
    }

    if (password != passwordConfirmation) {
      showErrorMessage('Passwords do not match');
      return false;
    }

    return true;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validate username format
  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username);
  }

  /// Validate age (must be at least 13 years old)
  bool _isValidAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      return age - 1 >= 13;
    }
    return age >= 13;
  }

  /// Validate password strength
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null; // Password is valid
  }

  /// Perform the actual sign up process using AuthService
  Future<Result<AuthUser>> _performSignUp() async {
    try {
      final request = SignUpRequest(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        username: username.trim(),
        email: email.trim(),
        phone: phone.trim(),
        dateOfBirth: _selectedDateOfBirth!,
        password: password,
        passwordConfirmation: passwordConfirmation,
        gender: gender! ? 'Male' : 'Female',
        attachments: profilePicture != null
            ? List.generate(1, (index) => profilePicture!).toList()
            : null,
      );

      // Use AuthService which will handle AuthRepository internally
      return await _authService.signUp(request);
    } catch (e) {
      return Result.error(Exception('Account creation failed: $e'));
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

  /// Clear all form data
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    usernameController.clear();
    dateOfBirthController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    passwordConfirmationController.clear();
    gender = null;
    _selectedDateOfBirth = null;
    profilePicture = null;
    clearError();
    safeNotifyListeners();
  }

  /// Get form validation status
  bool get isFormValid {
    return firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        usernameController.text.trim().isNotEmpty &&
        _selectedDateOfBirth != null &&
        gender != null &&
        emailController.text.trim().isNotEmpty &&
        _isValidEmail(emailController.text.trim()) &&
        passwordController.text.isNotEmpty &&
        passwordConfirmationController.text.isNotEmpty &&
        passwordController.text == passwordConfirmationController.text &&
        _validatePassword(passwordController.text) == null;
  }

  /// Check if we can enable the sign up button
  bool get canSignUp {
    return isFormValid && !isLoading;
  }

  /// Get password strength indicator
  double get passwordStrength {
    if (passwordController.text.isEmpty) return 0.0;

    int score = 0;
    final pwd = passwordController.text;

    // Length check
    if (pwd.length >= 8) score++;
    if (pwd.length >= 12) score++;

    // Character type checks
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
    if (RegExp(r'[a-z]').hasMatch(pwd)) score++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd)) score++;

    return score / 6.0; // Convert to 0.0 - 1.0 scale
  }

  /// Get password strength color
  Color get passwordStrengthColor {
    final strength = passwordStrength;
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  /// Get password strength text
  String get passwordStrengthText {
    final strength = passwordStrength;
    if (strength == 0.0) return '';
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  /// Check if username is available (simulate API call)
  Future<bool> checkUsernameAvailability(String username) async {
    if (username.length < 3) return false;

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate some taken usernames
    final takenUsernames = ['admin', 'test', 'user', 'spotsell', 'support'];
    return !takenUsernames.contains(username.toLowerCase());
  }

  /// Check if email is available (simulate API call)
  Future<bool> checkEmailAvailability(String email) async {
    if (!_isValidEmail(email)) return false;

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate some taken emails
    final takenEmails = ['test@example.com', 'admin@spotsell.com'];
    return !takenEmails.contains(email.toLowerCase());
  }

  /// Calculate user's age from date of birth
  int? get userAge {
    if (_selectedDateOfBirth == null) return null;

    final now = DateTime.now();
    int age = now.year - _selectedDateOfBirth!.year;

    if (now.month < _selectedDateOfBirth!.month ||
        (now.month == _selectedDateOfBirth!.month &&
            now.day < _selectedDateOfBirth!.day)) {
      age--;
    }

    return age;
  }

  /// Get formatted date of birth for display
  String get formattedDateOfBirth {
    if (_selectedDateOfBirth == null) return '';
    return DateFormat('MMMM dd, yyyy').format(_selectedDateOfBirth!);
  }

  /// Validate individual field (for real-time validation)
  String? validateField(String fieldName, String value) {
    switch (fieldName) {
      case 'firstName':
        if (value.trim().isEmpty) return 'First name is required';
        if (value.trim().length < 2) return 'Must be at least 2 characters';
        return null;

      case 'lastName':
        if (value.trim().isEmpty) return 'Last name is required';
        if (value.trim().length < 2) return 'Must be at least 2 characters';
        return null;

      case 'username':
        if (value.trim().isEmpty) return 'Username is required';
        if (value.trim().length < 3) return 'Must be at least 3 characters';
        if (!_isValidUsername(value.trim())) {
          return 'Only letters, numbers, dots, and underscores allowed';
        }
        return null;

      case 'email':
        if (value.trim().isEmpty) return 'Email is required';
        if (!_isValidEmail(value.trim())) return 'Enter a valid email address';
        return null;

      case 'password':
        if (value.isEmpty) return 'Password is required';
        return _validatePassword(value);

      case 'passwordConfirmation':
        if (value.isEmpty) return 'Please confirm your password';
        if (value != passwordController.text) return 'Passwords do not match';
        return null;

      default:
        return null;
    }
  }

  @override
  void onNavigationError(Exception error, String message) {
    super.onNavigationError(error, message);
    // Log navigation errors for debugging
    debugPrint('SignUpViewModel Navigation Error: $message');
    showErrorMessage('Navigation failed. Please try again.');
  }

  /// Handle profile picture selection
  Future<void> selectProfilePicture(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profilePicture = File(pickedFile.path);
        safeNotifyListeners();
        showSuccessMessage('Profile picture selected successfully!');
      }
    } catch (e) {
      showErrorMessage('Failed to select image. Please try again.');
      debugPrint('Error selecting profile picture: $e');
    }
  }

  /// Remove selected profile picture
  void removeProfilePicture() {
    profilePicture = null;
    safeNotifyListeners();
    showInfoMessage('Profile picture removed');
  }

  /// Get image file size in MB
  Future<double> getImageSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Compress image if needed (basic implementation)
  Future<File?> compressImageIfNeeded(File file) async {
    try {
      final sizeInMB = await getImageSizeInMB(file);

      // If image is larger than 5MB, we might want to compress it further
      if (sizeInMB > 5.0) {
        showWarningMessage(
          'Image is quite large (${sizeInMB.toStringAsFixed(1)}MB). Consider using a smaller image for faster upload.',
        );
      }

      return file;
    } catch (e) {
      debugPrint('Error checking image size: $e');
      return file;
    }
  }
}
