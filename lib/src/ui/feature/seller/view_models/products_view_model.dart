import 'package:flutter/widgets.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ProductsViewModel extends BaseViewModel {
  List<Product> _products = [];

  // Getter for products
  List<Product> get products => _products;

  late ProductRepository _repository;

  @override
  void initialize() {
    super.initialize();
    _repository = getService<ProductRepository>();
  }

  /// Initialize the repository and load products for a specific store
  Future<void> initializeRepository(int storeId) async {
    await executeAsyncResult<List<Product>>(
      () => _loadProductsFromRepository(storeId),
      errorMessage: 'Failed to load products',
      onSuccess: (products) {
        _products = products;
        safeNotifyListeners();
      },
    );
  }

  /// Refresh products for a specific store
  Future<void> refreshProducts(int storeId) async {
    await executeAsyncResult<List<Product>>(
      () => _loadProductsFromRepository(storeId),
      errorMessage: 'Failed to refresh products',
      onSuccess: (products) {
        _products = products;
        safeNotifyListeners();
      },
    );
  }

  /// Add a new product to the list
  void addProduct(Product product) {
    _products.add(product);
    safeNotifyListeners();
  }

  /// Update an existing product in the list
  void updateProduct(Product updatedProduct) {
    if (updatedProduct.id == null) return;

    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      safeNotifyListeners();
    }
  }

  /// Remove a product from the list
  void removeProduct(int productId) {
    _products.removeWhere((p) => p.id == productId);
    safeNotifyListeners();
  }

  /// Clear all products
  void clearProducts() {
    _products.clear();
    safeNotifyListeners();
  }

  /// Load products from repository
  Future<Result<List<Product>>> _loadProductsFromRepository(int storeId) async {
    try {
      final request = ProductsMeta(showAll: true, storeId: storeId);
      return await _repository.getPublicProducts(request);
    } catch (e) {
      debugPrint('Error loading products from repository: $e');
      return Result.error(Exception('Failed to load products: $e'));
    }
  }

  /// Create a new product
  Future<bool> createProduct(ProductsRequest request) async {
    return await executeAsyncResult<Product>(
      () => _repository.createProduct(request),
      errorMessage: 'Failed to create product',
      onSuccess: (product) {
        _products.add(product);
        safeNotifyListeners();
      },
    );
  }

  /// Update an existing product
  Future<bool> updateProductById(UpdateProductRequest request) async {
    return await executeAsyncResult<Product>(
      () => _repository.updateProduct(request),
      errorMessage: 'Failed to update product',
      onSuccess: (updatedProduct) {
        updateProduct(updatedProduct);
      },
    );
  }

  /// Delete a product
  Future<bool> deleteProduct(int productId, int storeId) async {
    return await executeAsyncResult<void>(
      () => _repository.deleteProduct(productId, storeId),
      errorMessage: 'Failed to delete product',
      onSuccess: (_) {
        removeProduct(productId);
      },
    );
  }

  /// Get product by ID
  Product? getProductById(int productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Filter products by status
  List<Product> getProductsByStatus(Status status) {
    return _products.where((p) => p.status == status).toList();
  }

  /// Filter products by condition
  List<Product> getProductsByCondition(Condition condition) {
    return _products.where((p) => p.condition == condition).toList();
  }

  /// Search products by title or description
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.title.toLowerCase().contains(lowercaseQuery) ||
              p.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Get available products count
  int get availableProductsCount {
    return _products.where((p) => p.status == Status.available).length;
  }

  /// Get total products count
  int get totalProductsCount => _products.length;

  /// Check if products list is empty
  bool get isEmpty => _products.isEmpty;

  /// Check if products list is not empty
  bool get isNotEmpty => _products.isNotEmpty;
}
