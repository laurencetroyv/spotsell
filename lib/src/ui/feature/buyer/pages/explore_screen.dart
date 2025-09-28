import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/products_request.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/explore_view_model.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/item_card.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late ExploreViewModel _viewModel;
  late ProductRepository _repository;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _repository = getService<ProductRepository>();
    _viewModel = ExploreViewModel(_repository);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return AdaptiveScaffold(
      appBar: responsive.shouldShowNavigationRail
          ? null
          : _buildAppBar(context),
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          _viewModel.tabController = TabController(
            length: _viewModel.tabs.length,
            vsync: this,
          );

          return Column(
            children: [
              _buildTabSection(context, responsive),
              Expanded(child: _buildProductGrid(context, responsive)),
            ],
          );
        },
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
    final filteredProducts = _viewModel.getProductsForTab(tabName);

    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

  void _handleProductTap(Product product) {
    // Navigate to product details
    debugPrint('Product tapped: ${product.title}');
    // Navigate to product detail screen
  }

  Future<void> _handleRefresh(String tabName) async {
    // Implement refresh logic
    debugPrint('Refreshing $tabName');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Refresh products data
  }
}
