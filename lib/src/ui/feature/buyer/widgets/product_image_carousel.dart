import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';

class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({
    super.key,
    required this.product,

    this.onImageTap,
    this.height,
  });

  final Product product;
  final void Function(int index)? onImageTap;
  final double? height;

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = widget.height ?? screenHeight * 0.5;

    if (widget.product.attachments == null) {
      return _buildPlaceholder(context, carouselHeight);
    }

    return Container(
      height: carouselHeight,
      color: _getBackgroundColor(context),
      child: Stack(
        children: [
          // Main Image Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.product.attachments?.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onImageTap?.call(index),
                child: Hero(
                  tag: index == 0
                      ? widget.product
                      : '${widget.product.id}_$index',
                  child: _buildImage(
                    widget.product.attachments![index].url,
                    index,
                  ),
                ),
              );
            },
          ),

          // Navigation arrows (desktop only)
          if (responsive.isDesktop &&
              widget.product.attachments!.length > 1) ...[
            _buildNavigationArrow(context, left: true, onTap: _previousImage),
            _buildNavigationArrow(context, left: false, onTap: _nextImage),
          ],

          // Page indicators
          if (widget.product.attachments!.length > 1)
            Positioned(
              bottom: responsive.mediumSpacing,
              left: 0,
              right: 0,
              child: _buildPageIndicators(context, responsive),
            ),

          // Image counter (top right)
          if (widget.product.attachments!.length > 1)
            Positioned(
              top: responsive.mediumSpacing,
              right: responsive.mediumSpacing,
              child: _buildImageCounter(context),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl, int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: _getImageBackgroundColor(context)),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            color: _getImageBackgroundColor(context),
            child: Center(
              child: _buildLoadingIndicator(context, loadingProgress),
            ),
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
                    ThemeUtils.getAdaptiveIcon(AdaptiveIcon.store),
                    size: 64,
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: ThemeUtils.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(
    BuildContext context,
    ImageChunkEvent? loadingProgress,
  ) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return const CupertinoActivityIndicator(radius: 20);
    }

    return CircularProgressIndicator(
      value: loadingProgress?.expectedTotalBytes != null
          ? loadingProgress!.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
          : null,
      strokeWidth: 3,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  Widget _buildNavigationArrow(
    BuildContext context, {
    required bool left,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: left ? 16 : null,
      right: left ? null : 16,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              left ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.product.attachments!.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? _getActiveIndicatorColor(context)
                : _getInactiveIndicatorColor(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCounter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentIndex + 1}/${widget.product.attachments?.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, double height) {
    return Container(
      height: height,
      color: _getImageBackgroundColor(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ThemeUtils.getAdaptiveIcon(AdaptiveIcon.store),
              size: 64,
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No images available',
              style: TextStyle(
                fontSize: 16,
                color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.product.attachments!.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Styling methods
  Color _getBackgroundColor(BuildContext context) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return CupertinoColors.systemGrey6.resolveFrom(context);
    }
    return Colors.grey.shade100;
  }

  Color _getImageBackgroundColor(BuildContext context) {
    return ThemeUtils.getTextColor(context).withValues(alpha: 0.05);
  }

  Color _getActiveIndicatorColor(BuildContext context) {
    return ThemeUtils.getPrimaryColor(context);
  }

  Color _getInactiveIndicatorColor(BuildContext context) {
    return ThemeUtils.getTextColor(context).withValues(alpha: 0.3);
  }
}
