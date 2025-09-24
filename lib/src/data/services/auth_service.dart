import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:logger/web.dart';

import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/auth_request.dart';
import 'package:spotsell/src/data/entities/user_role.dart';
import 'package:spotsell/src/data/repositories/auth_repository.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';

/// Service responsible for managing user authentication state and session
/// Acts as a state management layer on top of AuthRepository
class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  AuthUser? _currentUser;
  bool _isInitialized = false;
  bool _isLoading = false;

  AuthService({
    required AuthRepository authRepository,
    required SecureStorageService secureStorage,
  }) : _authRepository = authRepository,
       _secureStorage = secureStorage;

  /// Current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Whether the user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Whether the service is currently loading
  bool get isLoading => _isLoading;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// User roles (empty list if no user or no roles)
  List<String> get userRoles {
    if (_currentUser?.role == null) return [];
    return List<String>.from(_currentUser!.role!);
  }

  /// Check if user has a specific role
  bool hasRole(String role) {
    return userRoles.contains(role.toLowerCase()) ||
        userRoles.contains(role) ||
        userRoles.any((r) => r.toLowerCase() == role.toLowerCase());
  }

  /// Check if user has admin role
  bool get isAdmin => hasRole('admin');

  /// Check if user has seller role
  bool get isSeller => hasRole('seller');

  /// Check if user is buyer (default role or no specific roles)
  bool get isBuyer => !isAdmin && !isSeller;

  /// Get the primary role for navigation
  UserRole get primaryRole {
    if (isAdmin) return UserRole.admin;
    if (isSeller) return UserRole.seller;
    return UserRole.buyer;
  }

  /// Get all available roles for the current user
  List<UserRole> get availableRoles {
    final roles = <UserRole>[];

    // Always add buyer as it's the default
    roles.add(UserRole.buyer);

    if (isSeller) roles.add(UserRole.seller);
    if (isAdmin) roles.add(UserRole.admin);

    return roles;
  }

  /// Initialize the authentication service
  /// Checks for existing session and validates it
  Future<Result<void>> initialize() async {
    if (_isInitialized) return Result.ok(null);

    _setLoading(true);

    try {
      _logger.i('Initializing AuthService...');

      // Check if we have a stored session
      final sessionResult = await _secureStorage.fetchSession();

      switch (sessionResult) {
        case Ok<String?>():
          final token = sessionResult.value;
          if (token != null && token.isNotEmpty) {
            _logger.i('Found stored session, validating...');
            await _validateSession(token);
          } else {
            _logger.i('No stored session found');
          }
          break;
        case Error<String?>():
          _logger.w('Error retrieving stored session: ${sessionResult.error}');
          break;
      }

      _isInitialized = true;
      _setLoading(false);

      _logger.i(
        'AuthService initialized. User authenticated: $isAuthenticated',
      );

      return Result.ok(null);
    } catch (e) {
      _setLoading(false);
      _logger.e('Failed to initialize AuthService', error: e);
      return Result.error(Exception('Failed to initialize authentication: $e'));
    }
  }

  /// Validate current session by fetching user data using AuthRepository
  Future<Result<AuthUser>> _validateSession(String? token) async {
    try {
      final result = await _authRepository.getCurrentUser(token);

      switch (result) {
        case Ok<AuthUser>():
          _currentUser = result.value;
          notifyListeners(); // Notify UI about state change
          _logger.i('Session validated for user: ${_currentUser!.username}');
          return Result.ok(result.value);
        case Error<AuthUser>():
          _logger.w('Session validation failed: ${result.error}');
          await _clearUserState();
          return Result.error(result.error);
      }
    } catch (e) {
      _logger.e('Error validating session', error: e);
      await _clearUserState();
      return Result.error(Exception('Session validation failed: $e'));
    }
  }

  /// Sign in user using AuthRepository and update state
  Future<Result<AuthUser>> signIn(SignInRequest request) async {
    _setLoading(true);

    try {
      // Use your existing AuthRepository for the actual sign in
      final result = await _authRepository.signIn(request);

      switch (result) {
        case Ok<AuthUser>():
          _currentUser = result.value;
          notifyListeners(); // Notify UI about state change
          _logger.i('User signed in successfully: ${_currentUser!.username}');
          return Result.ok(result.value);
        case Error<AuthUser>():
          _logger.w('Sign in failed: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up user using AuthRepository and update state
  Future<Result<AuthUser>> signUp(SignUpRequest request) async {
    _setLoading(true);

    try {
      // Use your existing AuthRepository for the actual sign up
      final result = await _authRepository.signUp(request);

      switch (result) {
        case Ok<AuthUser>():
          _currentUser = result.value;
          notifyListeners(); // Notify UI about state change
          _logger.i('User signed up successfully: ${_currentUser!.username}');
          return Result.ok(result.value);
        case Error<AuthUser>():
          _logger.w('Sign up failed: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out user using AuthRepository and clear state
  Future<Result<void>> signOut() async {
    _setLoading(true);

    try {
      // Use your existing AuthRepository for the actual sign out
      final result = await _authRepository.signOut();

      // Clear local state regardless of server response
      await _clearUserState();

      _logger.i('User signed out successfully');
      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current user data using AuthRepository
  Future<Result<AuthUser>> refreshUser(String? token) async {
    if (!isAuthenticated) {
      return Result.error(Exception('User not authenticated'));
    }

    _setLoading(true);

    try {
      return await _validateSession(token);
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile using AuthRepository
  Future<Result<AuthUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    File? profilePicture,
  }) async {
    if (!isAuthenticated) {
      return Result.error(Exception('User not authenticated'));
    }

    _setLoading(true);

    try {
      // Use your existing AuthRepository for profile update
      final result = await _authRepository.updateProfile(
        firstName,
        lastName,
        username,
        email,
        phone,
        dateOfBirth,
        gender,
        profilePicture,
      );

      switch (result) {
        case Ok<AuthUser>():
          _currentUser = result.value;
          notifyListeners(); // Notify UI about state change
          _logger.i('Profile updated successfully');
          return Result.ok(result.value);
        case Error<AuthUser>():
          _logger.w('Profile update failed: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account using AuthRepository
  Future<Result<void>> deleteAccount(String password) async {
    if (!isAuthenticated) {
      return Result.error(Exception('User not authenticated'));
    }

    _setLoading(true);

    try {
      // Use your existing AuthRepository for account deletion
      final result = await _authRepository.deleteAccount(password);

      switch (result) {
        case Ok<void>():
          await _clearUserState();
          _logger.i('Account deleted successfully');
          return Result.ok(null);
        case Error<void>():
          _logger.w('Account deletion failed: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Clear user state and notify listeners
  Future<void> _clearUserState() async {
    _currentUser = null;
    notifyListeners(); // Notify UI about state change
    _logger.i('User state cleared');
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners(); // Notify UI about loading state change
    }
  }

  /// Force sign out (for security purposes)
  Future<void> forceSignOut() async {
    await _clearUserState();
    _logger.i('User force signed out');
  }

  @override
  void dispose() {
    super.dispose();
    _logger.i('AuthService disposed');
  }
}
