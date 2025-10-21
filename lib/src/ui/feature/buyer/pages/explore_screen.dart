import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/product_repository.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/explore_view_model.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/item_card.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_progress_ring.dart';
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
          if (_viewModel.isLoading) {
            return SafeArea(child: Center(child: AdaptiveProgressRing()));
          }

          if (_viewModel.products.isEmpty) {
            return _buildEmptyState(context);
          }

          _viewModel.tabController = TabController(
            length: _viewModel.tabs.length,
            vsync: this,
          );

          return SafeArea(
            child: Column(
              children: [
                _buildTabSection(context, responsive),
                Expanded(child: _buildProductGrid(context, responsive)),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: AdaptiveTextField(
          controller: _viewModel.searchController,
          placeholder: 'Search product',
          prefixIcon: CupertinoIcons.search,
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

    // Material (Android, Linux, Web)
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ThemeUtils.getBackgroundColor(context),
      title: AdaptiveTextField(
        controller: _viewModel.searchController,
        placeholder: 'Search product',
        prefixIcon: Icons.search,
        onChanged: _handleSearch,
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
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
          proportionalWidth: true,
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

    if (!kIsWeb && (Platform.isMacOS || Platform.isIOS)) {
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => _handleRefresh(tabName),
          ),
          SliverPadding(
            padding: EdgeInsets.all(responsive.mediumSpacing),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: responsive.gridCrossAxisCount,
                childAspectRatio: 0.75,
                crossAxisSpacing: responsive.mediumSpacing,
                mainAxisSpacing: responsive.mediumSpacing,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = filteredProducts[index];
                return ItemCard(
                  product: product,
                  onTap: () => _handleProductTap(product),
                );
              }, childCount: filteredProducts.length),
            ),
          ),
        ],
      );
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

  Widget _buildEmptyState(BuildContext context) {
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
            'No items found',
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
    context.pushNamed(RouteNames.productDetail, arguments: product);
  }

  Future<void> _handleRefresh(String tabName) async {
    // Implement refresh logic
    debugPrint('Refreshing $tabName');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Refresh products data
  }
}
