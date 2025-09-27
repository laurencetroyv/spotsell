import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/data/services/logger_service.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger(
    output: Env.ENVIRONMENT == 'production'
        ? getService<LoggerService>()
        : null,
  );

  ProductRepositoryImpl({
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

  static final String listAllProducts = '/products';

  static final String createProducts = '/seller/products';
  static final String updateProducts = '/seller/products';
  static final String deleteProducts = '/seller/products';

  @override
  Future<Result<Product>> createProduct(ProductsRequest request) async {
    try {
      _logger.i('Creating product');

      final response = await _dio.post(createProducts, data: request.toJson());

      if (response.statusCode == 201) {
        final product = Product.fromJson(response.data);
        return Result.ok(product);
      } else {
        return Result.error(Exception('Failed to create product'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error creating product'));
    } catch (e) {
      _logger.e('Unexpected error creating product', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<void>> deleteProduct(num productId, num storeId) async {
    try {
      _logger.i('Deleting product with id: $productId from store: $storeId');

      final response = await _dio.delete(
        '$deleteProducts/$productId',
        queryParameters: {'store_id': storeId.toString()},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.ok(null);
      } else {
        return Result.error(Exception('Failed to delete product'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error deleting product'));
    } catch (e) {
      _logger.e('Unexpected error deleting product', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<Product>> getProduct(num id) async {
    try {
      _logger.i('Fetching product with id: $id');

      final response = await _dio.get('$listAllProducts/$id');

      if (response.statusCode == 200) {
        final product = Product.fromJson(response.data);
        return Result.ok(product);
      } else {
        return Result.error(Exception('Failed to fetch product'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error fetching product'));
    } catch (e) {
      _logger.e('Unexpected error fetching product', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<List<Product>>> getPublicProducts(ProductsMeta request) async {
    try {
      _logger.i('Fetching public products');

      final queryParams = <String, dynamic>{
        if (request.page != null) 'page': request.page.toString(),
        if (request.perPage != null) 'per_page': request.perPage.toString(),
        if (request.search != null && request.search!.isNotEmpty)
          'search': request.search,
        if (request.showAll != null) 'show_all': request.showAll! ? 1 : 0,
        if (request.sortBy != null && request.sortBy!.isNotEmpty)
          'sort_by': request.sortBy,
        if (request.sortOrder != null) 'sort_order': request.sortOrder!.name,
        if (request.filterByCondition != null &&
            request.filterByCondition!.isNotEmpty)
          'filter_by_condition': request.filterByCondition!
              .map((c) => c.name)
              .join(','),
        if (request.filterByStatus != null &&
            request.filterByStatus!.isNotEmpty)
          'filter_by_status': request.filterByStatus!
              .map((s) => s.name)
              .join(','),
      };

      final response = await _dio.get(
        listAllProducts,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final products = List.from(
          response.data['data'],
        ).map((e) => Product.fromJson(e)).toList();
        return Result.ok(products);
      } else {
        return Result.error(Exception('Failed to fetch products'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error fetching products'));
    } catch (e) {
      _logger.e('Unexpected error fetching products', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<Product>> updateProduct(UpdateProductRequest request) async {
    try {
      _logger.i('Updating product with id: ${request.id}');

      final response = await _dio.put(
        '$updateProducts/${request.id}',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final product = Product.fromJson(response.data);
        return Result.ok(product);
      } else {
        return Result.error(Exception('Failed to update product'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error updating product'));
    } catch (e) {
      _logger.e('Unexpected error updating product', error: e);
      return Result.error(Exception('Unexpected error occurred'));
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
          if (responseData is Map<String, dynamic> &&
              responseData['message'] != null) {
            message = responseData['message'];
          } else {
            message = '$context: Validation error.';
          }
        } else if (statusCode == 401) {
          message = 'Unauthorized. Please sign in again.';
        } else if (statusCode == 403) {
          message =
              'Access forbidden. You don\'t have permission for this action.';
        } else if (statusCode == 404) {
          message = 'Product not found.';
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
