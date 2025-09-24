import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/store_request.dart';

abstract class StoreRepository {
  /// Get all public stores (for buyers/guests)
  Future<Result<List<Store>>> getAllStores();

  /// Create a new store (for sellers)
  Future<Result<Store>> createStore(CreateStoreRequest request);

  /// Get seller's stores (authenticated seller only)
  Future<Result<List<Store>>> getSellerStores();

  /// Get a specific store by ID (seller only)
  Future<Result<Store>> getStore(int id);

  /// Update a specific store (seller only)
  Future<Result<Store>> updateStore(int id, UpdateStoreRequest request);

  /// Delete a specific store (seller only)
  Future<Result<void>> deleteStore(int id);
}
