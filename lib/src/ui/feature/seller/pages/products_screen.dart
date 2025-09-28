import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/feature/seller/view_models/products_view_model.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen(this.store, {super.key});

  final Store store;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late ProductsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductsViewModel();
    _viewModel.initialize();
    // Load products for this store when the screen initializes
    _loadProducts();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Load products for the current store
  Future<void> _loadProducts() async {
    await _viewModel.initializeRepository(widget.store.id);
  }

  /// Refresh products list
  Future<void> _refreshProducts() async {
    await _viewModel.refreshProducts(widget.store.id);
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        // Navigate to add product screen and refresh when returning
        final result = await context.pushNamed(
          RouteNames.addProduct,
          arguments: widget.store,
        );

        // If a product was added, refresh the list
        if (result == true) {
          _refreshProducts();
        }
      },
      backgroundColor: ThemeUtils.getPrimaryColor(context),
      child: Icon(Icons.add, color: ThemeUtils.getTextColor(context)),
    );
  }

  Widget _buildProductCard(Product product) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoListTile(
          title: Text(product.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.description),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'PHP${product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.conditions,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.status == Status.available
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product.statuses,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => _onProductTap(product),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(product.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'PHP${product.price}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getPrimaryColor(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  product.properCondition,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: product.status == Status.available
                ? Colors.green
                : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.properStatuses,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _onProductTap(product),
      ),
    );
  }

  /// Handle product tap - navigate to product details/edit
  void _onProductTap(Product product) async {
    // Navigate to product details or edit screen
    // You can add route navigation here based on your requirements
    // final result = await context.pushNamed(
    //   RouteNames.editProduct, // Assuming you have this route
    //   arguments: product,
    // );

    // If product was edited/deleted, refresh the list
    // if (result == true) {
    //   _refreshProducts();
    // }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            !kIsWeb && (Platform.isIOS || Platform.isMacOS)
                ? CupertinoIcons.bag
                : Icons.inventory_2,
            size: 64,
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No products yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await context.pushNamed(
                RouteNames.addProduct,
                arguments: widget.store,
              );
              if (result == true) {
                _refreshProducts();
              }
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // Use CupertinoScrollbar for iOS/macOS
      return CupertinoScrollbar(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: _refreshProducts),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildProductCard(_viewModel.products[index]),
                childCount: _viewModel.products.length,
              ),
            ),
          ],
        ),
      );
    }

    // Material Design with RefreshIndicator
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _viewModel.products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_viewModel.products[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AdaptiveScaffold(
        floatingActionButton: _buildFloatingActionButton(),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            // Show error state if there's an error
            if (_viewModel.hasError) {
              return _buildErrorState();
            }

            // Show empty state if no products and not loading
            if (_viewModel.products.isEmpty && !_viewModel.isLoading) {
              return _buildEmptyState();
            }

            // Show products list
            return _buildProductsList();
          },
        ),
      ),
    );
  }
}
