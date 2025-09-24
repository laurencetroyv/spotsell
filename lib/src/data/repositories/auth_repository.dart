import 'dart:io';

import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/auth_request.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<AuthUser>> signIn(SignInRequest request);

  /// Sign up with user details
  Future<Result<AuthUser>> signUp(SignUpRequest request);

  /// Sign out current user
  Future<Result<void>> signOut();

  /// Get current user profile
  Future<Result<AuthUser>> getCurrentUser(String? token);

  /// Update user profile
  Future<Result<AuthUser>> updateProfile(
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    File? profilePicture,
  );

  /// Delete account
  Future<Result<void>> deleteAccount(String password);
}
