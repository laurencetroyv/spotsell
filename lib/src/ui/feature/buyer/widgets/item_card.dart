import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';

class ItemCard extends StatefulWidget {
  const ItemCard({super.key, required this.product, required this.onTap});

  final Product product;

  final VoidCallback onTap;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late String title;
  late String price;
  late String condition;
  late String seller;
  late String heroTag;
  late String imageUrlToUse;

  @override
  void initState() {
    title = widget.product.title;
    price = widget.product.price;
    condition = widget.product.properCondition;
    seller = widget.product.store?.name ?? 'Unknown Seller';
    heroTag = '${widget.product.id}-${widget.product.title}';

    if (widget.product.attachments != null &&
        widget.product.attachments!.isNotEmpty) {
      imageUrlToUse = widget.product.attachments!.first.url;
    } else {
      imageUrlToUse = '';
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: _getCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Expanded(flex: 3, child: _buildImageSection(context)),

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

  Widget _buildImageSection(BuildContext context) {
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
            child: Hero(
              tag: heroTag,
              child: _buildImage(imageUrlToUse, 'title'),
            ),
          ),

          // Condition Badge
          Positioned(
            top: 8,
            left: 8,
            child: _buildConditionBadge(
              context,
              widget.product.properCondition,
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
}
