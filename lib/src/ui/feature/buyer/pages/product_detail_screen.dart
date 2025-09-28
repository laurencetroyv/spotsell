import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/product_image_view_model.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/item_card.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/product_image_carousel.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;
  late ProductDetailViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product = ModalRoute.of(context)!.settings.arguments! as Product;

    _viewModel = ProductDetailViewModel();
    _viewModel.initialize();

    // Load product details and recommendations
    _viewModel.loadProductDetails(product);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AdaptiveScaffold(
          isLoading: _viewModel.isLoading,
          appBar: _buildAppBar(context),
          child: _viewModel.hasError
              ? _buildErrorState(context)
              : _buildContent(context, responsive),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _handleShare,
              child: const Icon(CupertinoIcons.share),
            ),
          ],
        ),
      );
    }

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ThemeUtils.getBackgroundColor(context),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share), onPressed: _handleShare),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ResponsiveBreakpoints responsive) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Image Carousel
        SliverToBoxAdapter(
          child: ProductImageCarousel(
            product: product,
            onImageTap: _handleImageTap,
          ),
        ),

        // Product Details
        SliverToBoxAdapter(child: _buildProductDetails(context, responsive)),

        // Store Info
        SliverToBoxAdapter(child: _buildStoreInfo(context, responsive)),

        // Action Buttons
        SliverToBoxAdapter(child: _buildActionButtons(context, responsive)),

        // Recommendations Header
        SliverToBoxAdapter(
          child: _buildRecommendationsHeader(context, responsive),
        ),

        // Recommendations Grid
        _buildRecommendationsGrid(context, responsive),

        // Bottom spacing
        SliverToBoxAdapter(
          child: SizedBox(height: responsive.extraLargeSpacing),
        ),
      ],
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      margin: EdgeInsets.all(responsive.mediumSpacing),
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: _getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Condition
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _viewModel.productTitle,
                  style: _getTitleStyle(context, responsive),
                ),
              ),
              const SizedBox(width: 12),
              _buildConditionBadge(context, _viewModel.productCondition),
            ],
          ),

          SizedBox(height: responsive.smallSpacing),

          // Price
          Text(
            _viewModel.formattedPrice,
            style: _getPriceStyle(context, responsive),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Description
          if (_viewModel.productDescription.isNotEmpty) ...[
            Text('Description', style: _getSectionHeaderStyle(context)),
            SizedBox(height: responsive.smallSpacing),
            Text(
              _viewModel.productDescription,
              style: _getBodyTextStyle(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStoreInfo(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.mediumSpacing),
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: _getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seller Information', style: _getSectionHeaderStyle(context)),
          SizedBox(height: responsive.smallSpacing),

          Row(
            children: [
              // Store Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getAvatarBackgroundColor(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  ThemeUtils.getAdaptiveIcon(AdaptiveIcon.store),
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),

              SizedBox(width: responsive.mediumSpacing),

              // Store Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viewModel.storeName,
                      style: _getStoreNameStyle(context),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 (120 reviews)', // Mock rating
                          style: _getCaptionStyle(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Follow Button
              AdaptiveButton(
                type: AdaptiveButtonType.secondary,
                onPressed: () => _viewModel.visitStore(product.store),
                size: AdaptiveButtonSize.small,
                child: Text('Visit Store'),
              ),
            ],
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Store Stats
          Row(
            children: [
              _buildStatItem(
                context,
                'Products',
                '${_viewModel.storeProductCount}',
              ),
              const SizedBox(width: 24),
              _buildStatItem(context, 'Followers', '1.2K'),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                'Joined',
                DateFormat('MMM. dd, yyyy').format(product.store!.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: _getStatValueStyle(context)),
        Text(label, style: _getCaptionStyle(context)),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Padding(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      child: Row(
        spacing: responsive.verticalPadding,
        children: [
          Expanded(
            child: AdaptiveButton(
              onPressed: _handleMessage,
              icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages)),
              child: const Text('Message'),
            ),
          ),
          if (!kIsWeb && product.store!.phone != null)
            Expanded(
              child: AdaptiveButton(
                type: AdaptiveButtonType.secondary,
                onPressed: _handleContact,
                icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.call)),
                child: const Text('Contact'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsHeader(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      margin: EdgeInsets.all(responsive.mediumSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'More from ${_viewModel.storeName}',
            style: _getSectionHeaderStyle(context),
          ),
          AdaptiveButton(
            type: AdaptiveButtonType.text,
            onPressed: _handleViewAllProducts,
            size: AdaptiveButtonSize.small,
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsGrid(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_viewModel.recommendations.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.all(responsive.mediumSpacing),
          padding: EdgeInsets.all(responsive.largeSpacing),
          child: Center(
            child: Text(
              'No other products available from this store',
              style: _getCaptionStyle(context),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: responsive.mediumSpacing),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.gridCrossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: responsive.mediumSpacing,
          mainAxisSpacing: responsive.mediumSpacing,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final recommendation = _viewModel.recommendations[index];
          return ItemCard(
            product: recommendation,
            onTap: () => _handleRecommendationTap(recommendation),
          );
        }, childCount: _viewModel.recommendations.length),
      ),
    );
  }

  Widget _buildConditionBadge(BuildContext context, String condition) {
    Color badgeColor = _getConditionColor(condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        condition,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
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
            'Failed to load product',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          AdaptiveButton(
            type: AdaptiveButtonType.secondary,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _handleImageTap(int index) {
    // Navigate to full-screen image gallery
    debugPrint('Image tapped at index: $index');
  }

  void _handleShare() {
    // Implement share functionality
    debugPrint('Share product');
  }

  Future<void> _handleMessage() async {
    await _viewModel.loadConversationOfStore();

    await context.pushNamed(
      RouteNames.message,
      arguments: _viewModel.conversations.first,
    );
  }

  Future<void> _handleContact() async {
    context.pushNamed(RouteNames.message, arguments: product);
  }

  void _handleViewAllProducts() {
    // Navigate to store's all products
    debugPrint('View all products from store');
  }

  void _handleRecommendationTap(Product product) {
    context.pushNamed(RouteNames.productDetail, arguments: product);
  }

  // Styling Methods
  BoxDecoration _getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: ThemeUtils.getSurfaceColor(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Color _getAvatarBackgroundColor(BuildContext context) {
    return ThemeUtils.getTextColor(context).withValues(alpha: 0.05);
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
      case 'brand new':
        return Colors.green.shade600;
      case 'like new':
        return Colors.blue.shade600;
      case 'good':
        return Colors.orange.shade600;
      case 'fair':
        return Colors.amber.shade600;
      case 'poor':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  TextStyle _getTitleStyle(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.headline,
        )?.copyWith(fontWeight: FontWeight.bold, height: 1.2) ??
        TextStyle(
          fontSize: responsive.isDesktop ? 24 : 20,
          fontWeight: FontWeight.bold,
        );
  }

  TextStyle _getPriceStyle(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return TextStyle(
      fontSize: responsive.isDesktop ? 22 : 18,
      fontWeight: FontWeight.w700,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  TextStyle _getSectionHeaderStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.title,
        )?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }

  TextStyle _getBodyTextStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body) ??
        const TextStyle(fontSize: 14);
  }

  TextStyle _getStoreNameStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.body,
        )?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }

  TextStyle _getStatValueStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.body,
        )?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  }

  TextStyle _getCaptionStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.caption,
        )?.copyWith(
          color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
        ) ??
        TextStyle(
          fontSize: 12,
          color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
        );
  }
}
