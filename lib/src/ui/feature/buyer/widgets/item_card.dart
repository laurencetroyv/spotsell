import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/products_request.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    this.product,
    this.item,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.showSeller = true,
    this.imageUrl,
    this.heroTag,
  }) : assert(
         product != null || item != null,
         'Either product or item must be provided',
       );

  // For backward compatibility with existing Map-based usage
  final Map<String, String>? item;

  // For new Product entity usage
  final Product? product;

  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showSeller;
  final String? imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    // Get data from either product or item
    final title = product?.title ?? item?['title'] ?? 'Unknown Item';
    final price = product?.price ?? item?['price'] ?? '0';
    final condition =
        product?.properCondition ?? item?['condition'] ?? 'Unknown';
    final seller = product?.store?.name ?? item?['seller'] ?? 'Unknown Seller';
    final imageUrlToUse =
        imageUrl ??
        'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=400&auto=format&fit=crop';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _getCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Expanded(
              flex: 3,
              child: _buildImageSection(context, imageUrlToUse, title),
            ),

            // Product Details Section
            Expanded(
              flex: 2,
              child: _buildDetailsSection(
                context,
                responsive,
                title,
                price,
                condition,
                seller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        color: _getImageBackgroundColor(context),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: heroTag != null
                ? Hero(tag: heroTag!, child: _buildImage(imageUrl, title))
                : _buildImage(imageUrl, title),
          ),

          // Favorite Button (if onFavorite is provided)
          if (onFavorite != null)
            Positioned(top: 8, right: 8, child: _buildFavoriteButton(context)),

          // Condition Badge
          Positioned(
            top: 8,
            left: 8,
            child: _buildConditionBadge(
              context,
              product?.properCondition ?? item?['condition'] ?? 'Unknown',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl, String title) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: _getImageBackgroundColor(context),
          child: Center(child: _buildLoadingIndicator(context)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: _getImageBackgroundColor(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getAdaptiveIcon(AdaptiveIcon.store),
                  size: 32,
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.4),
                ),
                const SizedBox(height: 4),
                Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return const CupertinoActivityIndicator(radius: 12);
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: ThemeUtils.getPrimaryColor(context),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return GestureDetector(
      onTap: onFavorite,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: ThemeUtils.getBackgroundColor(context).withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFavorite
              ? _getAdaptiveIcon(AdaptiveIcon.favorite)
              : _getOutlineIcon(AdaptiveIcon.favorite),
          size: 16,
          color: isFavorite
              ? Colors.red.shade500
              : ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildConditionBadge(BuildContext context, String condition) {
    Color badgeColor = _getConditionColor(condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    String title,
    String price,
    String condition,
    String seller,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isDesktop ? 12 : 8),
      decoration: BoxDecoration(
        color: _getDetailsBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Expanded(
            child: Text(
              title,
              style: _getTitleStyle(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Price
          Text(_formatPrice(price), style: _getPriceStyle(context)),

          if (showSeller) ...[
            const SizedBox(height: 4),

            // Seller Info
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getSellerAvatarColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAdaptiveIcon(AdaptiveIcon.profile),
                    size: 8,
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    seller,
                    style: _getSellerStyle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for styling
  BoxDecoration _getCardDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: ThemeUtils.getSurfaceColor(context),
      border: Border.all(
        color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
        width: 1,
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

  Color _getImageBackgroundColor(BuildContext context) {
    return ThemeUtils.getTextColor(context).withValues(alpha: 0.05);
  }

  Color _getDetailsBackgroundColor(BuildContext context) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return CupertinoTheme.of(context).scaffoldBackgroundColor;
    }
    return ThemeUtils.getSurfaceColor(context);
  }

  Color _getSellerAvatarColor(BuildContext context) {
    return ThemeUtils.getTextColor(context).withValues(alpha: 0.1);
  }

  TextStyle _getTitleStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.body,
        )?.copyWith(fontWeight: FontWeight.w500, height: 1.2) ??
        const TextStyle(fontWeight: FontWeight.w500);
  }

  TextStyle _getPriceStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.caption,
        )?.copyWith(
          color: ThemeUtils.getPrimaryColor(context),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ) ??
        TextStyle(
          color: ThemeUtils.getPrimaryColor(context),
          fontWeight: FontWeight.w700,
        );
  }

  TextStyle _getSellerStyle(BuildContext context) {
    return ThemeUtils.getAdaptiveTextStyle(
          context,
          TextStyleType.caption,
        )?.copyWith(
          color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
          fontSize: 10,
        ) ??
        TextStyle(
          color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
          fontSize: 10,
        );
  }

  String _formatPrice(String price) {
    // Remove any existing currency symbols and format consistently
    final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    final numPrice = double.tryParse(cleanPrice) ?? 0;

    if (numPrice == 0) return 'Free';

    return '₱${numPrice.toStringAsFixed(numPrice.truncateToDouble() == numPrice ? 0 : 2)}';
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

  IconData _getAdaptiveIcon(AdaptiveIcon icon) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      switch (icon) {
        case AdaptiveIcon.favorite:
          return CupertinoIcons.heart_fill;
        case AdaptiveIcon.profile:
          return CupertinoIcons.person_fill;
        case AdaptiveIcon.store:
          return CupertinoIcons.bag_fill;
        default:
          return CupertinoIcons.question;
      }
    }

    // Material and others
    switch (icon) {
      case AdaptiveIcon.favorite:
        return Icons.favorite;
      case AdaptiveIcon.profile:
        return Icons.person;
      case AdaptiveIcon.store:
        return Icons.inventory_2;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getOutlineIcon(AdaptiveIcon icon) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      switch (icon) {
        case AdaptiveIcon.favorite:
          return CupertinoIcons.heart;
        case AdaptiveIcon.profile:
          return CupertinoIcons.person;
        case AdaptiveIcon.store:
          return CupertinoIcons.bag;
        default:
          return CupertinoIcons.question;
      }
    }

    // Material and others
    switch (icon) {
      case AdaptiveIcon.favorite:
        return Icons.favorite_border;
      case AdaptiveIcon.profile:
        return Icons.person_outline;
      case AdaptiveIcon.store:
        return Icons.inventory_2_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
