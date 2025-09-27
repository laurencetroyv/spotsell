import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/ui/feature/seller/view_models/products_view_model.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

import 'add_products_screen.dart';

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
  }

  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductsScreen(store: widget.store),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addProduct,
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
                    '\$${product.price}',
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
                  '\$${product.price}',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.products.isEmpty) {
      return SafeArea(
        child: AdaptiveScaffold(
          isLoading: _viewModel.isLoading,
          floatingActionButton: _buildFloatingActionButton(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  !kIsWeb && (Platform.isIOS || Platform.isMacOS)
                      ? CupertinoIcons.bag
                      : Icons.inventory_2,
                  size: 64,
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first product to get started',
                  style: TextStyle(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: AdaptiveScaffold(
        floatingActionButton: _buildFloatingActionButton(),
        child: ListView.builder(
          itemCount: _viewModel.products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(_viewModel.products[index]);
          },
        ),
      ),
    );
  }
}
