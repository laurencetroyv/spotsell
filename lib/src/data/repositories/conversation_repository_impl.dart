import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/conversation_repository.dart';
import 'package:spotsell/src/data/services/logger_service.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger(
    output: Env.ENVIRONMENT == 'production' && !kIsWeb
        ? getService<LoggerService>()
        : null,
  );

  ConversationRepositoryImpl({
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

  static const String _buyerConversations = '/buyer/conversations';

  static const String _sellerConversations = '/seller/conversations';

  @override
  Future<Result<Conversation>> createBuyerConversation(
    ConversationRequest request,
  ) async {
    try {
      _logger.i('Creating buyer conversation');

      final response = await _dio.post(
        _buyerConversations,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final conversation = Conversation.fromJson(response.data);
        return Result.ok(conversation);
      } else {
        return Result.error(Exception('Failed to create conversation'));
      }
    } on DioException catch (e) {
      return Result.error(
        _handleDioError(e, 'Error creating buyer conversation'),
      );
    } catch (e) {
      _logger.e('Unexpected error creating buyer conversation', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<Conversation>> createSellerConversation(
    SellerConversationRequest request,
  ) async {
    try {
      _logger.i('Creating seller conversation');

      final requestData = request.toJson();

      final response = await _dio.post(_sellerConversations, data: requestData);

      if (response.statusCode == 201) {
        final conversation = Conversation.fromJson(response.data);
        return Result.ok(conversation);
      } else {
        return Result.error(Exception('Failed to create conversation'));
      }
    } on DioException catch (e) {
      return Result.error(
        _handleDioError(e, 'Error creating seller conversation'),
      );
    } catch (e) {
      _logger.e('Unexpected error creating seller conversation', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<List<Conversation>>> showBuyerListAllMessage(
    Meta request,
  ) async {
    try {
      _logger.i('Fetching buyer conversations');

      final queryParams = <String, dynamic>{
        if (request.page != null) 'page': request.page.toString(),
        if (request.perPage != null) 'per_page': request.perPage.toString(),
        if (request.search != null && request.search!.isNotEmpty)
          'search': request.search,
        if (request.showAll != null) 'show_all': request.showAll.toString(),
        if (request.sortBy != null && request.sortBy!.isNotEmpty)
          'sort_by': request.sortBy,
        if (request.sortOrder != null) 'sort_order': request.sortOrder!.name,
      };

      final response = await _dio.get(
        _buyerConversations,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final conversation = List.from(
          response.data,
        ).map((e) => Conversation.fromJson(response.data)).toList();
        return Result.ok(conversation);
      } else {
        return Result.error(Exception('Failed to fetch conversations'));
      }
    } on DioException catch (e) {
      return Result.error(
        _handleDioError(e, 'Error fetching buyer conversations'),
      );
    } catch (e) {
      _logger.e('Unexpected error fetching buyer conversations', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<Conversation>> showBuyerConversation(num id) async {
    try {
      _logger.i('Fetching conversation with id: $id');

      final response = await _dio.get('/$_buyerConversations/$id');

      if (response.statusCode == 200) {
        final conversation = Conversation.fromJson(response.data);
        return Result.ok(conversation);
      } else {
        return Result.error(Exception('Failed to fetch conversation'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error fetching conversation'));
    } catch (e) {
      _logger.e('Unexpected error fetching conversation', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<Conversation>> showSellerConversation(num id) async {
    try {
      _logger.i('Fetching conversation with id: $id');

      final response = await _dio.get('$_buyerConversations/$id');

      if (response.statusCode == 200) {
        final conversation = Conversation.fromJson(response.data);
        return Result.ok(conversation);
      } else {
        return Result.error(Exception('Failed to fetch conversation'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error fetching conversation'));
    } catch (e) {
      _logger.e('Unexpected error fetching conversation', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<List<Conversation>>> showSellerListAllMessage(
    SellerMeta request,
  ) async {
    try {
      _logger.i('Fetching seller conversations for store ${request.storeId}');

      final queryParams = <String, dynamic>{
        'store_id': request.storeId.toString(),
        if (request.page != null) 'page': request.page.toString(),
        if (request.perPage != null) 'per_page': request.perPage.toString(),
        if (request.search != null && request.search!.isNotEmpty)
          'search': request.search,
        if (request.showAll != null) 'show_all': request.showAll! ? 1 : 0,
        if (request.sortBy != null && request.sortBy!.isNotEmpty)
          'sort_by': request.sortBy,
        if (request.sortOrder != null) 'sort_order': request.sortOrder!.name,
      };

      final response = await _dio.get(
        _sellerConversations,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final conversation = List.from(
          response.data['data'],
        ).map((e) => Conversation.fromJson(response.data)).toList();
        return Result.ok(conversation);
      } else {
        return Result.error(Exception('Failed to fetch seller conversations'));
      }
    } on DioException catch (e) {
      return Result.error(
        _handleDioError(e, 'Error fetching seller conversations'),
      );
    } catch (e) {
      _logger.e('Unexpected error fetching seller conversations', error: e);
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
          // Validation error
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
          message = 'Message not found.';
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
