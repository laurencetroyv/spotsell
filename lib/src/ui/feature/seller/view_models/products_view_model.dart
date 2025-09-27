import 'package:flutter/widgets.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ProductsViewModel extends BaseViewModel {
  List<Product> products = [];

  late ProductRepository _repository;

  @override
  void initialize() {
    super.initialize();
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      _repository = getService<ProductRepository>();

      final request = ProductsMeta(showAll: true);

      final response = await _repository.getPublicProducts(request);

      switch (response) {
        case Ok<List<Product>>():
          products = response.value;
        case Error<List<Product>>():
          products = [];
      }
    } catch (e) {
      debugPrint('Error initializing converation repository: $e');
    }
  }
}
