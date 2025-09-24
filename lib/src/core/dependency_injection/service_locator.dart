import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:spotsell/src/data/repositories/auth_repository.dart';
import 'package:spotsell/src/data/repositories/auth_repository_impl.dart';
import 'package:spotsell/src/data/services/navigation_service.dart';
import 'package:spotsell/src/data/services/secure_storage_service.dart';
import 'package:spotsell/src/ui/services/cupertino_navigation_service.dart';
import 'package:spotsell/src/ui/services/fluent_navigation_service.dart';
import 'package:spotsell/src/ui/services/material_navigation_service.dart';
import 'package:spotsell/src/ui/services/yaru_navigation_service.dart';

/// Service locator for dependency injection
/// Manages the creation and lifecycle of all services in the application
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _factories = {};

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize all services
  /// This should be called once during app startup
  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_isInitialized) {
      debugPrint('ServiceLocator already initialized');
      return;
    }

    try {
      // Register core services
      await _registerCoreServices();

      // Register HTTP client
      await _registerHttpClient();

      // Register platform-specific services
      await _registerPlatformServices(navigatorKey);

      // Register repositories
      await _registerRepositories();

      // Register use cases (when created)
      await _registerUseCases();

      _isInitialized = true;
      debugPrint('ServiceLocator initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize ServiceLocator: $e');
      rethrow;
    }
  }

  /// Register core services that are platform-independent
  Future<void> _registerCoreServices() async {
    // Register SecureStorageService as singleton
    registerSingleton<SecureStorageService>(SecureStorageService());

    debugPrint('Core services registered');
  }

  /// Register HTTP client (Dio) with configuration
  Future<void> _registerHttpClient() async {
    final dio = Dio();

    // Configure Dio with default options
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    registerSingleton<Dio>(dio);
    debugPrint('HTTP client (Dio) registered');
  }

  /// Register platform-specific services
  Future<void> _registerPlatformServices(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    // Register platform-appropriate navigation service
    final navigationService = _createNavigationService(navigatorKey);
    registerSingleton<NavigationService>(navigationService);

    if (!kIsWeb) {
      debugPrint(
        'Platform services registered for ${Platform.operatingSystem}',
      );
    }
  }

  /// Create the appropriate navigation service for the current platform
  NavigationService _createNavigationService(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationService(navigatorKey);
      }

      if (Platform.isWindows) {
        return FluentNavigationService(navigatorKey);
      }

      if (Platform.isLinux || Platform.isFuchsia) {
        return YaruNavigationService(navigatorKey);
      }
    }

    // Default to Material (Android and fallback)
    return MaterialNavigationService(navigatorKey);
  }

  /// Register repositories
  Future<void> _registerRepositories() async {
    // Register AuthRepository as singleton
    registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        dio: get<Dio>(),
        secureStorage: get<SecureStorageService>(),
      ),
    );

    debugPrint('Repositories registered');
  }

  /// Register use cases (placeholder for future implementation)
  Future<void> _registerUseCases() async {
    // TODO: Register use cases when created
    // Example:
    // registerFactory<SignInUseCase>(() => SignInUseCase(
    //   authRepository: get<AuthRepository>(),
    // ));

    debugPrint('Use cases registered');
  }

  /// Register a singleton instance
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Register a factory function for creating instances
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Register a lazy singleton (created on first access)
  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = factory;
    // Mark it as a lazy singleton by storing in both maps
    _services[T] = null; // Placeholder
  }

  /// Get an instance of the specified type
  T get<T>() {
    final type = T;

    // Check if it's a registered singleton
    if (_singletons.containsKey(type)) {
      return _singletons[type] as T;
    }

    // Check if it's a lazy singleton that hasn't been created yet
    if (_services.containsKey(type) && _services[type] == null) {
      final factory = _factories[type];
      if (factory != null) {
        final instance = factory() as T;
        _services[type] = instance;
        return instance;
      }
    }

    // Check if it's an already created lazy singleton
    if (_services.containsKey(type) && _services[type] != null) {
      return _services[type] as T;
    }

    // Check if it's a factory
    if (_factories.containsKey(type)) {
      return _factories[type]!() as T;
    }

    throw ServiceLocatorException(
      'Service of type $type is not registered. '
      'Make sure to register it during initialization.',
    );
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    final type = T;
    return _singletons.containsKey(type) ||
        _services.containsKey(type) ||
        _factories.containsKey(type);
  }

  /// Get an instance if registered, otherwise return null
  T? getIfRegistered<T>() {
    try {
      return get<T>();
    } on ServiceLocatorException {
      return null;
    }
  }

  /// Remove a service registration
  void unregister<T>() {
    final type = T;
    _singletons.remove(type);
    _services.remove(type);
    _factories.remove(type);
  }

  /// Clear all registrations (useful for testing)
  void reset() {
    _singletons.clear();
    _services.clear();
    _factories.clear();
    _isInitialized = false;
    debugPrint('ServiceLocator reset');
  }

  /// Dispose of all services that implement Disposable
  Future<void> dispose() async {
    // Dispose singletons
    for (final service in _singletons.values) {
      if (service is Disposable) {
        await service.dispose();
      }
    }

    // Dispose lazy singletons
    for (final service in _services.values) {
      if (service != null && service is Disposable) {
        await service.dispose();
      }
    }

    reset();
    debugPrint('ServiceLocator disposed');
  }

  /// Get debug information about registered services
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'singletons': _singletons.keys.map((k) => k.toString()).toList(),
      'services': _services.keys.map((k) => k.toString()).toList(),
      'factories': _factories.keys.map((k) => k.toString()).toList(),
      'platform': Platform.operatingSystem,
    };
  }
}

/// Global accessor for the service locator
final serviceLocator = ServiceLocator();

/// Convenience function to get a service
T getService<T>() => serviceLocator.get<T>();

/// Convenience function to check if a service is registered
bool isServiceRegistered<T>() => serviceLocator.isRegistered<T>();

/// Interface for services that need cleanup
abstract class Disposable {
  Future<void> dispose();
}

/// Exception thrown when a service is not found
class ServiceLocatorException implements Exception {
  final String message;

  const ServiceLocatorException(this.message);

  @override
  String toString() => 'ServiceLocatorException: $message';
}

/// Extension to make ViewModels easier to use with service locator
extension ServiceLocatorExtension on Object {
  /// Get a service instance
  T getService<T>() => serviceLocator.get<T>();

  /// Get a service if registered
  T? getServiceIfRegistered<T>() => serviceLocator.getIfRegistered<T>();
}
