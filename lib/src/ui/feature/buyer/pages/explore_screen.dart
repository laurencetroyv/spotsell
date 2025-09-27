import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/feature/buyer/buyer_view_model.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/item_card.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen(this.viewModel, {super.key});

  final BuyerViewModel viewModel;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late BuyerViewModel _viewModel;
  late ProductRepository _repository;
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _repository = getService<ProductRepository>();
    _loadProductsFromRepository();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProductsFromRepository() async {
    try {
      final request = ProductsMeta(showAll: true);
      final response = await _repository.getPublicProducts(request);
      switch (response) {
        case Ok<List<Product>>():
          setState(() => _products = response.value);
        case Error<List<Product>>():
          setState(() => _products = []);
      }
    } catch (e) {
      debugPrint('Error loading products from repository: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return AdaptiveScaffold(
      appBar: responsive.shouldShowNavigationRail
          ? null
          : _buildAppBar(context),
      child: Column(
        children: [
          _buildTabSection(context, responsive),
          Expanded(child: _buildProductGrid(context, responsive)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              // Handle menu tap
            },
          ),
          middle: AdaptiveTextField(
            controller: _viewModel.searchController,
            placeholder: 'Search product',
            prefixIcon: CupertinoIcons.search,
            width: 200,
            onChanged: _handleSearch,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _handleFilter,
                child: const Icon(CupertinoIcons.slider_horizontal_3),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _handleNotifications,
                child: const Icon(CupertinoIcons.bell),
              ),
            ],
          ),
        );
      }

      if (Platform.isWindows) {
        return PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: fl.FluentTheme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: fl.FluentTheme.of(
                    context,
                  ).resources.cardStrokeColorDefault,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  fl.IconButton(
                    icon: const Icon(fl.FluentIcons.global_nav_button),
                    onPressed: () {
                      // Handle menu tap
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AdaptiveTextField(
                      controller: _viewModel.searchController,
                      placeholder: 'Search product',
                      prefixIcon: Icons.search,
                      onChanged: _handleSearch,
                    ),
                  ),
                  const SizedBox(width: 16),
                  fl.IconButton(
                    icon: const Icon(fl.FluentIcons.filter),
                    onPressed: _handleFilter,
                  ),
                  fl.IconButton(
                    icon: const Icon(fl.FluentIcons.ringer),
                    onPressed: _handleNotifications,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Material (Android, Linux, Web)
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ThemeUtils.getBackgroundColor(context),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          // Handle menu tap
        },
      ),
      title: AdaptiveTextField(
        controller: _viewModel.searchController,
        placeholder: 'Search product',
        prefixIcon: Icons.search,
        onChanged: _handleSearch,
      ),
      actions: [
        IconButton(icon: const Icon(Icons.tune), onPressed: _handleFilter),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _handleNotifications,
        ),
      ],
    );
  }

  Widget _buildScamWarning(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      margin: EdgeInsets.all(responsive.mediumSpacing),
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: _getWarningBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getWarningBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: _getWarningIconColor(context), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beware of "pa-ahon" scams.',
                  style: _getWarningTitleStyle(context),
                ),
                Text(
                  'Don\'t interact on bittemote ahons and commission tricks. It\'s a scam.',
                  style: _getWarningBodyStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.smallSpacing,
      ),
      child: Row(
        children: _viewModel.categories.asMap().entries.map((entry) {
          final category = entry.value;

          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: responsive.smallSpacing / 2,
              ),
              child: _buildCategoryCard(
                context,
                category,
                _getCategoryIcon(category),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () => _handleCategoryTap(title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ThemeUtils.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryCardBackground(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 32,
                color: _getCategoryIconColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: _getCategoryTextStyle(context),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: _buildPlatformTabBar(context),
    );
  }

  Widget _buildPlatformTabBar(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoSlidingSegmentedControl<int>(
          groupValue: _viewModel.tabController.index,
          onValueChanged: (value) {
            if (value != null) {
              _viewModel.tabController.animateTo(value);
            }
          },
          children: Map.fromEntries(
            _viewModel.tabs.asMap().entries.map(
              (entry) => MapEntry(
                entry.key,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(entry.value),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Material and Fluent
    return TabBar(
      controller: _viewModel.tabController,
      isScrollable: true,
      labelColor: ThemeUtils.getPrimaryColor(context),
      unselectedLabelColor: ThemeUtils.getTextColor(
        context,
      ).withValues(alpha: 0.6),
      indicatorColor: ThemeUtils.getPrimaryColor(context),
      indicatorWeight: 2,
      labelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
      tabs: _viewModel.tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return TabBarView(
      controller: _viewModel.tabController,
      children: _viewModel.tabs
          .map((tab) => _buildProductList(context, responsive, tab))
          .toList(),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    String tabName,
  ) {
    // Filter products based on tab (you can implement different logic here)
    // final filteredProducts = _getProductsForTab(tabName);
    final filteredProducts = _products;

    if (filteredProducts.isEmpty) {
      return _buildEmptyState(context, tabName);
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(tabName),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(responsive.mediumSpacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.gridCrossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: responsive.mediumSpacing,
          mainAxisSpacing: responsive.mediumSpacing,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ItemCard(
            product: product,
            onTap: () => _handleProductTap(product),
            onFavorite: () => _handleFavoriteTap(product),
            isFavorite: _viewModel.isFavorite(product.title),
            heroTag: 'product_${product.title}_$index',
            imageUrl:
                'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=400&auto=format&fit=crop',
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ThemeUtils.getAdaptiveIcon(AdaptiveIcon.search),
            size: 64,
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No items found in $tabName',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or check back later',
            style: TextStyle(
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _handleSearch(String query) {
    // Implement search logic
    debugPrint('Searching for: $query');
    // You can add debouncing here if needed
  }

  void _handleFilter() {
    // Implement filter logic
    debugPrint('Filter tapped');
    // Show filter bottom sheet or modal
  }

  void _handleNotifications() {
    // Implement notifications logic
    debugPrint('Notifications tapped');
    // Navigate to notifications screen
  }

  void _handleCategoryTap(String category) {
    // Implement category filtering
    debugPrint('Category tapped: $category');
    // Filter products by category
  }

  void _handleProductTap(Product product) {
    // Navigate to product details
    debugPrint('Product tapped: ${product.title}');
    // Navigate to product detail screen
  }

  void _handleFavoriteTap(Product product) {
    // Toggle favorite status
    debugPrint('Favorite tapped: ${product.title}');
    setState(() {
      _viewModel.toggleFavorite(product.title);
    });
  }

  Future<void> _handleRefresh(String tabName) async {
    // Implement refresh logic
    debugPrint('Refreshing $tabName');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Refresh products data
  }

  // Helper methods
  // List<Map<String, String>> _getProductsForTab(String tabName) {
  //   // Filter products based on tab
  //   // This is mock logic - replace with actual filtering
  //   switch (tabName) {
  //     case 'Top Picks':
  //       return _mockProducts.take(6).toList();
  //     case 'Nearby':
  //       return _mockProducts
  //           .where((p) => p['seller']?.contains('heart') ?? false)
  //           .toList();
  //     case 'Free Items':
  //       return _mockProducts.where((p) => p['price'] == '0').toList();
  //     case 'Following':
  //       return _mockProducts
  //           .where((p) => _viewModel.isFollowing(p['seller'] ?? ''))
  //           .toList();
  //     default:
  //       return _mockProducts;
  //   }
  // }

  IconData _getCategoryIcon(String category) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        switch (category) {
          case 'Property':
            return CupertinoIcons.house;
          case 'Autos':
            return CupertinoIcons.car;
          case 'Mobile Phones & Gadgets':
            return CupertinoIcons.phone;
          default:
            return CupertinoIcons.square_grid_2x2;
        }
      }

      if (Platform.isWindows) {
        switch (category) {
          case 'Property':
            return fl.FluentIcons.home;
          case 'Autos':
            return fl.FluentIcons.car;
          case 'Mobile Phones & Gadgets':
            return fl.FluentIcons.phone;
          default:
            return fl.FluentIcons.grid_view_small;
        }
      }
    }

    // Material
    switch (category) {
      case 'Property':
        return Icons.home;
      case 'Autos':
        return Icons.directions_car;
      case 'Mobile Phones & Gadgets':
        return Icons.phone_android;
      default:
        return Icons.category;
    }
  }

  // Platform-specific styling methods
  Color _getWarningBackgroundColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoColors.systemBlue.withValues(alpha: 0.1);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).accentColor.withValues(alpha: 0.1);
      }
    }
    return Colors.blue.shade50;
  }

  Color _getWarningBorderColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoColors.systemBlue.withValues(alpha: 0.3);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).accentColor.withValues(alpha: 0.3);
      }
    }
    return Colors.blue.shade200;
  }

  Color _getWarningIconColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoColors.systemBlue;
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).accentColor;
      }
    }
    return Colors.blue.shade600;
  }

  TextStyle? _getWarningTitleStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemBlue,
        );
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).typography.body?.copyWith(
          fontWeight: FontWeight.w600,
          color: fl.FluentTheme.of(context).accentColor,
        );
      }
    }
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.blue.shade700,
    );
  }

  TextStyle? _getWarningBodyStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          fontSize: 13,
          color: CupertinoColors.systemBlue,
        );
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).typography.caption?.copyWith(
          color: fl.FluentTheme.of(context).accentColor,
        );
      }
    }
    return Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.blue.shade600);
  }

  Color _getCategoryCardBackground(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoColors.systemGrey6.resolveFrom(context);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).resources.subtleFillColorSecondary;
      }
    }
    return Colors.grey.shade200;
  }

  Color _getCategoryIconColor(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoColors.systemGrey.resolveFrom(context);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).resources.textFillColorSecondary;
      }
    }
    return Colors.grey.shade600;
  }

  TextStyle? _getCategoryTextStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(
          context,
        ).typography.caption?.copyWith(fontWeight: FontWeight.w500);
      }
    }
    return Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500);
  }
}
