import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

/// ViewModel for the Sign Up Screen
/// Manages user registration form, validation, and submission
class SignUpViewModel extends BaseViewModel {
  // Form controllers
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController dateOfBirth = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController passwordConfirmation = TextEditingController();

  // Additional fields
  bool? gender; // true = male, false = female
  File? profilePicture;
  DateTime? _selectedDateOfBirth;

  // Image picker instance
  final ImagePicker _imagePicker = ImagePicker();

  /// Get the selected date of birth
  DateTime? get selectedDateOfBirth => _selectedDateOfBirth;

  /// Set the date of birth and update the text field
  void setDateOfBirth(DateTime date) {
    _selectedDateOfBirth = date;
    dateOfBirth.text = DateFormat('MMM dd, yyyy').format(date);
    safeNotifyListeners();
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    username.dispose();
    dateOfBirth.dispose();
    email.dispose();
    password.dispose();
    passwordConfirmation.dispose();
    super.dispose();
  }

  /// Handle sign up process
  Future<void> handleSignUp() async {
    if (!_validateInputs()) return;

    await executeAsyncResult<bool>(
      () => _performSignUp(),
      errorMessage: 'Failed to create account. Please try again.',
      onSuccess: (success) {
        if (success) {
          showSuccessMessage('Account created successfully!');
          _navigateToHome();
        }
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
    if (firstName.text.trim().isEmpty) {
      showErrorMessage('Please enter your first name');
      return false;
    }

    if (firstName.text.trim().length < 2) {
      showErrorMessage('First name must be at least 2 characters long');
      return false;
    }

    // Last Name validation
    if (lastName.text.trim().isEmpty) {
      showErrorMessage('Please enter your last name');
      return false;
    }

    if (lastName.text.trim().length < 2) {
      showErrorMessage('Last name must be at least 2 characters long');
      return false;
    }

    // Username validation
    if (username.text.trim().isEmpty) {
      showErrorMessage('Please choose a username');
      return false;
    }

    if (username.text.trim().length < 3) {
      showErrorMessage('Username must be at least 3 characters long');
      return false;
    }

    if (!_isValidUsername(username.text.trim())) {
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
    if (email.text.trim().isEmpty) {
      showErrorMessage('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(email.text.trim())) {
      showErrorMessage('Please enter a valid email address');
      return false;
    }

    // Password validation
    if (password.text.isEmpty) {
      showErrorMessage('Please create a password');
      return false;
    }

    final passwordValidation = _validatePassword(password.text);
    if (passwordValidation != null) {
      showErrorMessage(passwordValidation);
      return false;
    }

    // Password confirmation validation
    if (passwordConfirmation.text.isEmpty) {
      showErrorMessage('Please confirm your password');
      return false;
    }

    if (password.text != passwordConfirmation.text) {
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

  /// Perform the actual sign up process
  Future<Result<bool>> _performSignUp() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Create user data object (for API call)
      final userData = {
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'username': username.text.trim(),
        'email': email.text.trim(),
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'gender': gender == true ? 'male' : 'female',
        'password': password.text,
        'hasProfilePicture': profilePicture != null,
      };

      // TODO: Replace with actual API call
      debugPrint('Creating account with data: $userData');
      if (profilePicture != null) {
        debugPrint('Profile picture path: ${profilePicture!.path}');
        // In a real app, you would upload the image to your server here
        // final imageUrl = await uploadProfilePicture(profilePicture!);
        // userData['profilePictureUrl'] = imageUrl;
      }

      // Simulate different outcomes for testing
      if (email.text.trim().toLowerCase() == 'test@example.com') {
        return Result.error(Exception('This email is already registered'));
      }

      if (username.text.trim().toLowerCase() == 'admin') {
        return Result.error(Exception('This username is not available'));
      }

      // Simulate success
      return Result.ok(true);
    } catch (e) {
      return Result.error(Exception('Account creation failed: $e'));
    }
  }

  /// Navigate to home screen after successful sign up
  void _navigateToHome() {
    // TODO: Update this when home route is implemented
    // For now, just show success message and navigate to sign in
    showSuccessMessage('Account created! Please sign in to continue.');

    // Navigate to sign in screen
    Future.delayed(const Duration(seconds: 2), () {
      navigateToReplacement(
        RouteNames.signIn,
        errorMessage: 'Unable to navigate to sign in screen',
      );
    });

    // Uncomment when home route is available:
    // navigateToAndClearStack(
    //   RouteNames.home,
    //   errorMessage: 'Unable to navigate to home screen',
    // );
  }

  /// Clear all form data
  void clearForm() {
    firstName.clear();
    lastName.clear();
    username.clear();
    dateOfBirth.clear();
    email.clear();
    password.clear();
    passwordConfirmation.clear();
    gender = null;
    _selectedDateOfBirth = null;
    profilePicture = null;
    clearError();
    safeNotifyListeners();
  }

  /// Get form validation status
  bool get isFormValid {
    return firstName.text.trim().isNotEmpty &&
        lastName.text.trim().isNotEmpty &&
        username.text.trim().isNotEmpty &&
        _selectedDateOfBirth != null &&
        gender != null &&
        email.text.trim().isNotEmpty &&
        _isValidEmail(email.text.trim()) &&
        password.text.isNotEmpty &&
        passwordConfirmation.text.isNotEmpty &&
        password.text == passwordConfirmation.text &&
        _validatePassword(password.text) == null;
  }

  /// Check if we can enable the sign up button
  bool get canSignUp {
    return isFormValid && !isLoading;
  }

  /// Get password strength indicator
  double get passwordStrength {
    if (password.text.isEmpty) return 0.0;

    int score = 0;
    final pwd = password.text;

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
        if (value != password.text) return 'Passwords do not match';
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

  /// Validate image file (optional additional validation)
  bool _isValidImageFile(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.gif') ||
        extension.endsWith('.bmp') ||
        extension.endsWith('.webp');
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
