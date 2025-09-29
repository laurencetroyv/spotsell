import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/messages_request.dart';
import 'package:spotsell/src/data/entities/meta_request.dart';
import 'package:spotsell/src/data/repositories/message_repository.dart';
import 'package:spotsell/src/data/services/logger_service.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';

class MessageRepositoryImpl implements MessageRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger(
    output: Env.ENVIRONMENT == 'production' && !kIsWeb
        ? getService<LoggerService>()
        : null,
  );

  MessageRepositoryImpl({
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

          _logger.d('Message Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Message Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Message Error: ${error.message}', error: error);
          handler.next(error);
        },
      ),
    );
  }

  static const String _buyerMessageUrl = '/buyer/conversations';

  static const String _sellerMessageUrl = '/seller/conversations';

  @override
  Future<Result<Message>> createMessage(
    MessageRequest request,
    num id,
    bool isSeller,
  ) async {
    try {
      _logger.i('Creating message');

      final url = isSeller ? _sellerMessageUrl : _buyerMessageUrl;

      final response = await _dio.post(
        '$url/$id/messages',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final message = Message.fromJson(response.data['data']);
        return Result.ok(message);
      } else {
        return Result.error(Exception('Failed to create message'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error creating message'));
    } catch (e) {
      _logger.e('Unexpected error creating message', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<List<Message>>> getAllMessages(
    Meta request,
    num id,
    bool isSeller,
  ) async {
    try {
      _logger.i('Creating message');

      final queryParams = <String, dynamic>{
        if (request.page != null) 'page': request.page.toString(),
        if (request.perPage != null) 'per_page': request.perPage.toString(),
        if (request.search != null && request.search!.isNotEmpty)
          'search': request.search,
        if (request.showAll != null) 'show_all': request.showAll! ? 1 : 0,
        if (request.sortBy != null && request.sortBy!.isNotEmpty)
          'sort_by': request.sortBy,
        if (request.sortOrder != null) 'sort_order': request.sortOrder!.name,
      };

      final url = isSeller ? _sellerMessageUrl : _buyerMessageUrl;

      final response = await _dio.get(
        '$url/$id/messages',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final message = List.from(
          response.data['data'],
        ).map((e) => Message.fromJson(e)).toList().reversed.toList();
        return Result.ok(message);
      } else {
        return Result.error(Exception('Failed to fetch message'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error fetching message'));
    } catch (e) {
      _logger.e('Unexpected error fetching message', error: e);
      return Result.error(Exception('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<void>> markMessageAsRead(num id, bool isSeller) async {
    try {
      _logger.i('Creating message');

      final url = isSeller ? _sellerMessageUrl : _buyerMessageUrl;

      final response = await _dio.patch('$url/$id/mark-read');

      if (response.statusCode == 201) {
        return Result.ok(null);
      } else {
        return Result.error(Exception('Failed to mark message as read'));
      }
    } on DioException catch (e) {
      return Result.error(_handleDioError(e, 'Error marking message as read'));
    } catch (e) {
      _logger.e('Unexpected error marking message as read', error: e);
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

  // @override
  // Future<Result<Message>> sendBuyerMessage(
  //   num conversationId,
  //   MessageBuyerRequest request,
  // ) async {
  //   try {
  //     _logger.i('Sending message to conversation: $conversationId');

  //     final response = await _dio.post(
  //       '$_buyerConversations/$conversationId/messages',
  //       data: request.toJson(),
  //     );

  //     if (response.statusCode == 201) {
  //       final message = Message.fromJson(response.data);
  //       return Result.ok(message);
  //     } else {
  //       return Result.error(Exception('Failed to send message'));
  //     }
  //   } on DioException catch (e) {
  //     return Result.error(_handleDioError(e, 'Error sending message'));
  //   } catch (e) {
  //     _logger.e('Unexpected error sending message', error: e);
  //     return Result.error(Exception('Unexpected error occurred'));
  //   }
  // }

  // @override
  // Future<Result<Conversation>> getBuyerConversationMessages(
  //   num conversationId,
  // ) async {
  //   try {
  //     _logger.i('Fetching messages for conversation: $conversationId');

  //     final response = await _dio.get('$_buyerConversations/$conversationId');

  //     if (response.statusCode == 200) {
  //       final messages = Conversation.fromJson(response.data['data']);
  //       return Result.ok(messages);
  //     } else {
  //       return Result.error(Exception('Failed to fetch messages'));
  //     }
  //   } on DioException catch (e) {
  //     return Result.error(_handleDioError(e, 'Error fetching messages'));
  //   } catch (e) {
  //     _logger.e('Unexpected error fetching messages', error: e);
  //     return Result.error(Exception('Unexpected error occurred'));
  //   }
  // }
}
