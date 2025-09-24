import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/web.dart';

import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/auth_request.dart';
import 'package:spotsell/src/data/repositories/auth_repository.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  /// API Endpouints
  static const String _signInUrlEndpoint = '/log-in';
  static const String _signUpUrlEndpoint = '/sign-up';
  static const String _signOutUrlEndpoint = '/sign-out';
  static const String _getCurrentUserUrlEndpoint = '/authenticated';
  static const String _updateProfileUrlEndpoint = '/authenticated';
  static const String _deleteAccountUrlEndpoint = '/authenticated';

  AuthRepositoryImpl({
    required Dio dio,
    required SecureStorageService secureStorage,
  }) : _dio = dio,
       _secureStorage = secureStorage {
    _setupDioInterceptors();
  }

  void _setupDioInterceptors() {
    _dio.options.baseUrl = Env.API;
    // Request interceptor to add auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final sessionResult = await _secureStorage.fetchSession();
          if (sessionResult is Ok<String?> && sessionResult.value != null) {
            options.headers['Authorization'] = 'Bearer ${sessionResult.value}';
          }

          // Add content type
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          _logger.d('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}', error: error);
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<Result<AuthUser>> signIn(SignInRequest request) async {
    try {
      _logger.i('Attempting sign in for email: ${request.email}');

      final response = await _dio.post(
        _signInUrlEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthUser.fromJson(response.data);

        // Save tokens to secure storage
        await _secureStorage.saveSession(authResponse.token);

        _logger.i('Sign in successful for user: ${authResponse.username}');
        return Result.ok(authResponse);
      } else {
        return Result.error(
          Exception('Sign in failed: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Sign in failed'));
    } catch (e) {
      _logger.e('Unexpected error during sign in', error: e);
      return Result.error(
        Exception('An unexpected error occurred during sign in'),
      );
    }
  }

  @override
  Future<Result<AuthUser>> signUp(SignUpRequest request) async {
    try {
      _logger.i('Attempting sign up for email: ${request.email}');

      // Prepare form data for multipart upload (in case of profile picture)_logger
      FormData formData;

      if (request.attachments != null && request.attachments!.isNotEmpty) {
        final data = request.toJson();

        // Add attachments to the form data
        final attachmentFiles = <MultipartFile>[];
        for (final file in request.attachments!) {
          final fileName = file.path.split('/').last;
          attachmentFiles.add(
            await MultipartFile.fromFile(file.path, filename: fileName),
          );
        }

        data['attachments[]'] = attachmentFiles;
        formData = FormData.fromMap(data);
      } else {
        formData = FormData.fromMap(request.toJson());
      }

      final response = await _dio.post(
        _signUpUrlEndpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthUser.fromJson(response.data);

        // Save tokens to secure storage
        await _secureStorage.saveSession(authResponse.token);

        _logger.i('Sign up successful for user: ${authResponse.username}');
        return Result.ok(authResponse);
      } else {
        return Result.error(
          Exception('Sign up failed: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Sign up failed'));
    } catch (e) {
      _logger.e('Unexpected error during sign up', error: e);
      return Result.error(
        Exception('An unexpected error occurred during sign up'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      _logger.i('Attempting sign out');

      await _dio.post(_signOutUrlEndpoint);

      // Clear local session regardless of server response
      await _secureStorage.saveSession(null);

      _logger.i('Sign out successful');
      return Result.ok(null);
    } on DioException catch (e) {
      // Still clear local session even if server request fails
      await _secureStorage.saveSession(null);
      _logger.w('Sign out request failed but local session cleared', error: e);
      return Result.ok(
        null,
      ); // Consider this successful since local session is cleared
    } catch (e) {
      _logger.e('Unexpected error during sign out', error: e);
      await _secureStorage.saveSession(null);
      return Result.ok(null); // Still successful locally
    }
  }

  @override
  Future<Result<AuthUser>> getCurrentUser(String? token) async {
    try {
      final response = await _dio.get(_getCurrentUserUrlEndpoint);

      if (response.statusCode == 200) {
        final user = AuthUser.fromJson(response.data, token: token);
        return Result.ok(user);
      } else {
        return Result.error(
          Exception('Failed to get user profile: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to get user profile'));
    } catch (e) {
      _logger.e('Unexpected error getting user profile', error: e);
      return Result.error(
        Exception('An unexpected error occurred while getting user profile'),
      );
    }
  }

  @override
  Future<Result<AuthUser>> updateProfile(
    String? firstName,
    String? lastName,
    String? username,
    DateTime? dateOfBirth,
    String? gender,
    File? profilePicture,
  ) async {
    try {
      _logger.i('Attempting profile update');

      // Prepare form data
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (username != null) data['username'] = username;
      if (dateOfBirth != null) {
        data['dateOfBirth'] = dateOfBirth.toIso8601String();
      }
      if (gender != null) data['gender'] = gender;

      FormData formData;
      if (profilePicture != null) {
        data['attachments[]'] = await MultipartFile.fromFile(
          profilePicture.path,
          filename: 'profile_picture.jpg',
        );
      }
      formData = FormData.fromMap(data);

      final response = await _dio.put(
        _updateProfileUrlEndpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final user = AuthUser.fromJson(response.data);
        _logger.i('Profile update successful');
        return Result.ok(user);
      } else {
        return Result.error(
          Exception('Profile update failed: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Profile update failed'));
    } catch (e) {
      _logger.e('Unexpected error during profile update', error: e);
      return Result.error(
        Exception('An unexpected error occurred during profile update'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount(String password) async {
    try {
      _logger.i('Attempting account deletion');

      final response = await _dio.delete(
        _deleteAccountUrlEndpoint,
        data: {'password': password},
      );

      if (response.statusCode == 200) {
        // Clear local session
        await _secureStorage.saveSession(null);

        _logger.i('Account deletion successful');
        return Result.ok(null);
      } else {
        return Result.error(
          Exception('Account deletion failed: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Account deletion failed'));
    } catch (e) {
      _logger.e('Unexpected error during account deletion', error: e);
      return Result.error(
        Exception('An unexpected error occurred during account deletion'),
      );
    }
  }

  Exception _handleDioError(DioException error, String context) {
    String message = context;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message =
            '$context: Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = '$context: Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = '$context: Server response timeout. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message =
            '$context: Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == 422) {
          // Validation error
          if (responseData is Map<String, dynamic> &&
              responseData['message'] != null) {
            message = responseData['message'];
          } else {
            message = '$context: Validation error.';
          }
        } else {
          message = '$context: Request failed with status $statusCode.';
        }
        break;
      case DioExceptionType.cancel:
        message = '$context: Request was cancelled.';
        break;
      case DioExceptionType.unknown:
        message = '$context: An unexpected error occurred.';
        break;
      case DioExceptionType.badCertificate:
        message = '$context: Security certificate error.';
        break;
    }

    _logger.e(message, error: error);
    return Exception(message);
  }
}
