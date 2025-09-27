import 'package:dio/dio.dart';
import 'package:logger/web.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/repositories/store_repository.dart';
import 'package:spotsell/src/data/services/logger_service.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';

class StoreRepositoryImpl implements StoreRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger(
    output: Env.ENVIRONMENT == 'production'
        ? getService<LoggerService>()
        : null,
  );

  /// API Endpoints
  static const String _publicStoresEndpoint = '/stores';
  static const String _sellerStoresEndpoint = '/seller/stores';

  StoreRepositoryImpl({
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

          _logger.d('Store Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Store Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Store Error: ${error.message}', error: error);
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<Result<List<Store>>> getAllStores() async {
    try {
      _logger.i('Fetching all public stores');

      final response = await _dio.get(
        _publicStoresEndpoint,
        queryParameters: {"show_all": 1},
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesData = response.data['data'] ?? response.data;
        final stores = storesData
            .map((storeJson) => Store.fromJson(storeJson))
            .toList();

        _logger.i('Successfully fetched ${stores.length} stores');
        return Result.ok(stores);
      } else {
        return Result.error(
          Exception('Failed to fetch stores: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to fetch stores'));
    } catch (e) {
      _logger.e('Unexpected error fetching stores', error: e);
      return Result.error(
        Exception('An unexpected error occurred while fetching stores'),
      );
    }
  }

  @override
  Future<Result<Store>> createStore(CreateStoreRequest request) async {
    try {
      _logger.i('Creating new store: ${request.name}');

      final response = await _dio.post(
        _publicStoresEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final storeData = response.data['data'] ?? response.data;
        final store = Store.fromJson(storeData);

        _logger.i('Successfully created store: ${store.name}');
        return Result.ok(store);
      } else {
        return Result.error(
          Exception('Failed to create store: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to create store'));
    } catch (e) {
      _logger.e('Unexpected error creating store', error: e);
      return Result.error(
        Exception('An unexpected error occurred while creating store'),
      );
    }
  }

  @override
  Future<Result<List<Store>>> getSellerStores() async {
    try {
      _logger.i('Fetching seller stores');

      final response = await _dio.get(
        _sellerStoresEndpoint,
        queryParameters: {"show_all": 1},
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesData = response.data['data'] ?? response.data;
        final stores = storesData
            .map((storeJson) => Store.fromJson(storeJson))
            .toList();

        _logger.i('Successfully fetched ${stores.length} seller stores');
        return Result.ok(stores);
      } else {
        return Result.error(
          Exception('Failed to fetch seller stores: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to fetch seller stores'));
    } catch (e) {
      _logger.e('Unexpected error fetching seller stores', error: e);
      return Result.error(
        Exception('An unexpected error occurred while fetching seller stores'),
      );
    }
  }

  @override
  Future<Result<Store>> getStore(int id) async {
    try {
      _logger.i('Fetching store with ID: $id');

      final response = await _dio.get('$_sellerStoresEndpoint/$id');

      if (response.statusCode == 200) {
        final storeData = response.data['data'] ?? response.data;
        final store = Store.fromJson(storeData);

        _logger.i('Successfully fetched store: ${store.name}');
        return Result.ok(store);
      } else {
        return Result.error(
          Exception('Failed to fetch store: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to fetch store'));
    } catch (e) {
      _logger.e('Unexpected error fetching store', error: e);
      return Result.error(
        Exception('An unexpected error occurred while fetching store'),
      );
    }
  }

  @override
  Future<Result<Store>> updateStore(int id, UpdateStoreRequest request) async {
    try {
      _logger.i('Updating store with ID: $id');

      final response = await _dio.patch(
        '$_sellerStoresEndpoint/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final storeData = response.data['data'] ?? response.data;
        final store = Store.fromJson(storeData);

        _logger.i('Successfully updated store: ${store.name}');
        return Result.ok(store);
      } else {
        return Result.error(
          Exception('Failed to update store: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to update store'));
    } catch (e) {
      _logger.e('Unexpected error updating store', error: e);
      return Result.error(
        Exception('An unexpected error occurred while updating store'),
      );
    }
  }

  @override
  Future<Result<void>> deleteStore(int id) async {
    try {
      _logger.i('Deleting store with ID: $id');

      final response = await _dio.delete('$_sellerStoresEndpoint/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.i('Successfully deleted store with ID: $id');
        return Result.ok(null);
      } else {
        return Result.error(
          Exception('Failed to delete store: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Failed to delete store'));
    } catch (e) {
      _logger.e('Unexpected error deleting store', error: e);
      return Result.error(
        Exception('An unexpected error occurred while deleting store'),
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
          } else if (responseData is Map<String, dynamic> &&
              responseData['errors'] != null) {
            // Handle validation errors
            final errors = responseData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          } else {
            message = '$context: Validation error.';
          }
        } else if (statusCode == 401) {
          message = 'Unauthorized. Please sign in again.';
        } else if (statusCode == 403) {
          message =
              'Access forbidden. You don\'t have permission for this action.';
        } else if (statusCode == 404) {
          message = 'Store not found.';
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
