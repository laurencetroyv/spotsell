import 'package:flutter/foundation.dart';

import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/repositories/store_repository.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

/// ViewModel for managing store operations (CRUD)
/// Handles the state and business logic for the ManageStoresScreen
class ManageStoreViewModel extends BaseViewModel {
  final StoreRepository _storeRepository;
  final AuthService _authService;

  List<Store> _stores = [];
  bool _isLoadingStores = false;
  String? _lastError;

  ManageStoreViewModel({
    required StoreRepository storeRepository,
    required AuthService authService,
  }) : _storeRepository = storeRepository,
       _authService = authService;

  // Getters
  List<Store> get stores => List.unmodifiable(_stores);
  bool get isLoadingStores => _isLoadingStores;
  bool get hasStores => _stores.isNotEmpty;
  int get storeCount => _stores.length;
  String? get lastError => _lastError;

  /// Load all stores for the current user
  Future<void> loadStores() async {
    if (!_authService.isAuthenticated) {
      setError('User not authenticated');
      return;
    }

    _setLoadingStores(true);
    _clearError();

    final success = await executeAsyncResult<List<Store>>(
      () => _storeRepository.getSellerStores(),
      errorMessage: 'Failed to load stores',
      showLoading: false, // We're managing loading state manually
      onSuccess: (stores) {
        _stores = stores;
        _setLoadingStores(false);
        debugPrint('Loaded ${stores.length} stores');
      },
    );

    if (!success) {
      _setLoadingStores(false);
    }
  }

  /// Create a new store
  Future<Store?> createStore(CreateStoreRequest request) async {
    if (!_authService.isAuthenticated) {
      setError('User not authenticated');
      return null;
    }

    Store? createdStore;

    final success = await executeAsyncResult<Store>(
      () => _storeRepository.createStore(request),
      errorMessage: 'Failed to create store',
      onSuccess: (store) {
        createdStore = store;
        _addStoreToList(store);
        debugPrint('Store created: ${store.name}');
      },
    );

    return success ? createdStore : null;
  }

  /// Update an existing store
  Future<Store?> updateStore(int storeId, UpdateStoreRequest request) async {
    if (!_authService.isAuthenticated) {
      setError('User not authenticated');
      return null;
    }

    Store? updatedStore;

    final success = await executeAsyncResult<Store>(
      () => _storeRepository.updateStore(storeId, request),
      errorMessage: 'Failed to update store',
      onSuccess: (store) {
        updatedStore = store;
        _updateStoreInList(store);
        debugPrint('Store updated: ${store.name}');
      },
    );

    return success ? updatedStore : null;
  }

  /// Delete a store
  Future<bool> deleteStore(int storeId) async {
    if (!_authService.isAuthenticated) {
      setError('User not authenticated');
      return false;
    }

    // Find the store to get its name for logging
    final store = _stores.firstWhere((s) => s.id == storeId);
    final storeName = store.name;

    final success = await executeAsyncResult<void>(
      () => _storeRepository.deleteStore(storeId),
      errorMessage: 'Failed to delete store',
      onSuccess: (_) {
        _removeStoreFromList(storeId);
        debugPrint('Store deleted: $storeName');
      },
    );

    return success;
  }

  /// Get a specific store by ID
  Store? getStoreById(int storeId) {
    try {
      return _stores.firstWhere((store) => store.id == storeId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh stores (reload from server)
  Future<void> refreshStores() async {
    debugPrint('Refreshing stores...');
    await loadStores();
  }

  /// Add a store to the local list
  void _addStoreToList(Store store) {
    _stores.add(store);
    _sortStores();
    safeNotifyListeners();
  }

  /// Update a store in the local list
  void _updateStoreInList(Store updatedStore) {
    final index = _stores.indexWhere((store) => store.id == updatedStore.id);
    if (index != -1) {
      _stores[index] = updatedStore;
      _sortStores();
      safeNotifyListeners();
    }
  }

  /// Remove a store from the local list
  void _removeStoreFromList(int storeId) {
    _stores.removeWhere((store) => store.id == storeId);
    safeNotifyListeners();
  }

  /// Sort stores by creation date (newest first)
  void _sortStores() {
    _stores.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Set loading state for stores
  void _setLoadingStores(bool loading) {
    if (_isLoadingStores != loading) {
      _isLoadingStores = loading;
      safeNotifyListeners();
    }
  }

  /// Clear any previous error
  void _clearError() {
    _lastError = null;
  }

  /// Set error message
  void _setError(String error) {
    _lastError = error;
    setError(error);
  }

  /// Check if user can create more stores (business logic)
  bool get canCreateStore {
    // You can add business rules here, like maximum stores per user
    // For now, allow unlimited stores
    return _authService.isAuthenticated &&
        (_authService.isSeller || _authService.isAdmin);
  }

  /// Get store statistics
  Map<String, dynamic> getStoreStatistics() {
    return {
      'totalStores': _stores.length,
      'storesWithDescription': _stores
          .where((s) => s.description?.isNotEmpty == true)
          .length,
      'storesWithContact': _stores
          .where(
            (s) =>
                (s.email?.isNotEmpty == true) || (s.phone?.isNotEmpty == true),
          )
          .length,
      'oldestStore': _stores.isNotEmpty
          ? _stores.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b)
          : null,
      'newestStore': _stores.isNotEmpty
          ? _stores.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
          : null,
    };
  }

  /// Filter stores by name (for search functionality)
  List<Store> searchStores(String query) {
    if (query.isEmpty) return _stores;

    final lowercaseQuery = query.toLowerCase();
    return _stores.where((store) {
      return store.name.toLowerCase().contains(lowercaseQuery) ||
          (store.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Get stores that need attention (missing contact info, description, etc.)
  List<Store> getStoresNeedingAttention() {
    return _stores.where((store) {
      final missingDescription = store.description?.isEmpty ?? true;
      final missingContact =
          (store.email?.isEmpty ?? true) && (store.phone?.isEmpty ?? true);
      return missingDescription || missingContact;
    }).toList();
  }

  /// Initialize the view model
  @override
  void initialize() {
    super.initialize();
    debugPrint('ManageStoreViewModel initialized');
  }

  /// Clean up resources when disposing
  @override
  void dispose() {
    _stores.clear();
    debugPrint('ManageStoreViewModel disposed');
    super.dispose();
  }

  /// Handle navigation errors specifically for store operations
  @override
  void onNavigationError(Exception error, String message) {
    debugPrint('Navigation error in ManageStoreViewModel: $message');
    _setError('Navigation failed: $message');
  }

  /// Validate store data before operations
  String? validateStore(
    String name,
    String? description,
    String? email,
    String? phone,
  ) {
    // Name validation
    if (name.trim().isEmpty) {
      return 'Store name is required';
    }

    if (name.trim().length < 3) {
      return 'Store name must be at least 3 characters';
    }

    if (name.trim().length > 50) {
      return 'Store name must be less than 50 characters';
    }

    // Description validation (optional)
    if (description != null && description.length > 500) {
      return 'Description must be less than 500 characters';
    }

    // Email validation (optional)
    if (email != null && email.isNotEmpty) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      );
      if (!emailRegex.hasMatch(email)) {
        return 'Please enter a valid email address';
      }
    }

    // Phone validation (optional)
    if (phone != null && phone.isNotEmpty) {
      // Remove all non-digit characters for validation
      final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 10) {
        return 'Phone number must be at least 10 digits';
      }
    }

    // Check for duplicate store names
    final existingStore = _stores
        .where((store) => store.name.toLowerCase() == name.trim().toLowerCase())
        .firstOrNull;

    if (existingStore != null) {
      return 'A store with this name already exists';
    }

    return null; // All validations passed
  }

  /// Check if store name is already taken
  bool isStoreNameTaken(String name, {int? excludeStoreId}) {
    return _stores.any(
      (store) =>
          store.name.toLowerCase() == name.toLowerCase() &&
          (excludeStoreId == null || store.id != excludeStoreId),
    );
  }

  /// Get suggested store names based on user's name
  List<String> getSuggestedStoreNames() {
    final user = _authService.currentUser;
    if (user == null) return [];

    final suggestions = <String>[];
    final firstName = user.firstName;
    final lastName = user.lastName;
    final username = user.username;

    // Generate suggestions based on user data
    if (firstName.isNotEmpty) {
      suggestions.add('$firstName\'s Store');
      suggestions.add('$firstName Shop');
      suggestions.add('$firstName Marketplace');
    }

    if (lastName.isNotEmpty) {
      suggestions.add('$lastName Store');
      suggestions.add('$lastName Shop');
    }

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      suggestions.add('$firstName $lastName Store');
      suggestions.add('${firstName[0]}${lastName[0]} Shop');
    }

    suggestions.add('$username Store');
    suggestions.add('$username Shop');
    suggestions.add('My Store');
    suggestions.add('Quick Sell');
    suggestions.add('Local Store');

    // Filter out suggestions that are already taken
    return suggestions
        .where((suggestion) => !isStoreNameTaken(suggestion))
        .take(5)
        .toList();
  }
}
