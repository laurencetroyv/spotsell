import 'package:flutter/material.dart';

import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ExploreViewModel extends BaseViewModel {
  ExploreViewModel(this._repository);

  final ProductRepository _repository;

  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  List<String> tabs = [];
  final List<Product> _products = [];

  String get searchQuery => searchController.text;
  List<Product> get products => _products;

  @override
  void initialize() {
    super.initialize();
    _loadProductsFromRepository();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void clearSearch() {
    searchController.clear();
    safeNotifyListeners();
  }

  void setSearchQuery(String query) {
    searchController.text = query;
    safeNotifyListeners();
  }

  void initializeTabController(TickerProvider vsync) {
    tabController = TabController(length: tabs.length, vsync: vsync);
  }

  Future<void> _loadProductsFromRepository() async {
    try {
      final request = ProductsMeta(
        showAll: true,
        withMeta: ['store', 'categories'],
      );

      await executeAsyncResult<List<Product>>(
        () => _repository.getPublicProducts(request),
        showLoading: true,
        onSuccess: (products) {
          _products.clear();
          _products.addAll(products);

          tabs = _products.map((e) => e.properCondition).toSet().toList();
        },
      );
      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error loading products from repository: $e');
    }
  }

  // Add method to filter products by search query
  List<Product> getFilteredProducts() {
    if (searchQuery.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      return product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Add method to get products for a specific tab
  List<Product> getProductsForTab(String tabName) {
    final filteredProducts = getFilteredProducts();
    return filteredProducts
        .where((product) => product.properCondition == tabName)
        .toList();
  }
}
