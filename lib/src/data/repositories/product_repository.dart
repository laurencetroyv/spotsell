import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/products_request.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getPublicProducts(ProductsMeta request);

  Future<Result<Product>> getProduct(num id);

  Future<Result<Product>> createProduct(ProductsRequest request);

  Future<Result<Product>> updateProduct(UpdateProductRequest request);

  Future<Result<void>> deleteProduct(num productId, num storeId);
}
