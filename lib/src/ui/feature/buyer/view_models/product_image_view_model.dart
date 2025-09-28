import 'package:flutter/foundation.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ProductDetailViewModel extends BaseViewModel {
  // Private fields
  Product? _product;
  Map<String, String>? _productItem;
  List<String> _productImages = [];
  List<Product> _recommendations = [];

  int _storeProductCount = 0;

  // Repository
  late ProductRepository _productRepository;

  // Getters
  Product? get product => _product;
  Map<String, String>? get productItem => _productItem;
  List<String> get productImages => _productImages;
  List<Product> get recommendations => _recommendations;
  int get storeProductCount => _storeProductCount;

  // Computed properties
  String get productTitle {
    return _product?.title ?? _productItem?['title'] ?? 'Unknown Product';
  }

  String get productDescription {
    return _product?.description ?? _productItem?['description'] ?? '';
  }

  String get productCondition {
    return _product?.properCondition ?? _productItem?['condition'] ?? 'Unknown';
  }

  String get productPrice {
    return _product?.price ?? _productItem?['price'] ?? '0';
  }

  String get formattedPrice {
    final cleanPrice = productPrice.replaceAll(RegExp(r'[^\d.]'), '');
    final numPrice = double.tryParse(cleanPrice) ?? 0;

    if (numPrice == 0) return 'Free';

    return '₱${numPrice.toStringAsFixed(numPrice.truncateToDouble() == numPrice ? 0 : 2)}';
  }

  String get storeName {
    return _product?.store?.name ?? _productItem?['seller'] ?? 'Unknown Store';
  }

  @override
  void initialize() {
    super.initialize();
    _productRepository = getService<ProductRepository>();
  }

  /// Load product details from Product entity
  Future<void> loadProductDetails(Product product) async {
    _product = product;

    await executeAsync(() async {
      // Load product images (mock implementation)
      _loadProductImages();

      // Load store recommendations
      await _loadStoreRecommendations();

      safeNotifyListeners();
    }, errorMessage: 'Failed to load product details');
  }

  /// Load product details from Map (backward compatibility)
  void loadProductFromMap(Map<String, String> productItem) {
    _productItem = productItem;

    executeAsync(() async {
      // Load product images (mock implementation)
      _loadProductImages();

      safeNotifyListeners();
    }, errorMessage: 'Failed to load product details');
  }

  /// Load product images
  void _loadProductImages() {
    // Mock implementation - in real app, get from product.attachments or API
    final baseImage =
        _productItem?['image'] ??
        'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=400';

    _productImages = [
      baseImage,
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=400',
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?q=80&w=400',
      'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?q=80&w=400',
    ];
  }

  /// Load store recommendations
  Future<void> _loadStoreRecommendations() async {
    if (_product?.store?.id == null) {
      return;
    }

    try {
      final request = ProductsMeta(
        storeId: _product!.store!.id,
        showAll: true,
        perPage: 6,
      );

      final result = await _productRepository.getPublicProducts(request);

      switch (result) {
        case Ok<List<Product>>():
          final products = result.value;

          _recommendations = products
              .where((p) => p.id != _product?.id)
              .take(6)
              .toList();

          _storeProductCount = products.length;

        case Error<List<Product>>():
          debugPrint('Failed to load store recommendations: ${result.error}');
      }
    } catch (e) {
      debugPrint('Error loading store recommendations: $e');
    }
  }

  /// Refresh product data
  Future<void> refresh() async {
    if (_product != null) {
      await loadProductDetails(_product!);
    } else if (_productItem != null) {
      loadProductFromMap(_productItem!);
    }
  }

  void visitStore(Store? store) async {}

  /// Get recommendation by index
  Product? getRecommendation(int index) {
    if (index >= 0 && index < _recommendations.length) {
      return _recommendations[index];
    }
    return null;
  }

  /// Check if product is available
  bool get isAvailable {
    if (_product != null) {
      return _product!.status == Status.available;
    }
    return true; // Assume available for Map-based products
  }

  /// Get product status text
  String get statusText {
    if (_product != null) {
      return _product!.properStatuses;
    }
    return 'Available';
  }

  /// Get store product count text
  String get storeProductCountText {
    if (_storeProductCount == 0) return 'No products';
    if (_storeProductCount == 1) return '1 product';
    return '$_storeProductCount products';
  }

  /// Check if this is the only product from store
  bool get isOnlyProductFromStore {
    return _storeProductCount <= 1;
  }
}
