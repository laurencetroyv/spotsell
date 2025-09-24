import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/ui/feature/buyer/buyer_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
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
          if (!responsive.shouldShowNavigationRail)
            _buildScamWarning(context, responsive),
          _buildCategoriesSection(context, responsive),
          if (!kIsWeb && !Platform.isWindows)
            _buildTabSection(context, responsive),
          if (!kIsWeb && !Platform.isWindows)
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
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.slider_horizontal_3),
                onPressed: () {
                  // Handle filter tap
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.bell),
                onPressed: () {
                  // Handle notifications tap
                },
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  fl.IconButton(
                    icon: const Icon(fl.FluentIcons.filter),
                    onPressed: () {
                      // Handle filter tap
                    },
                  ),
                  fl.IconButton(
                    icon: const Icon(fl.FluentIcons.ringer),
                    onPressed: () {
                      // Handle notifications tap
                    },
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
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () {
            // Handle filter tap
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Handle notifications tap
          },
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
          Icon(
            _getAdaptiveIcon(
              AdaptiveIcon.search,
              selected: false,
            ), // Using search as security placeholder
            color: _getWarningIconColor(context),
            size: 20,
          ),
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
    return _buildPlatformCard(
      context: context,
      onTap: () {
        // Handle category tap
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
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

    // Material and Fluent (Fluent doesn't have native tabs, so we use Material)
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
          .map((tab) => _buildProductList(context, responsive))
          .toList(),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.gridCrossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: responsive.mediumSpacing,
        mainAxisSpacing: responsive.mediumSpacing,
      ),
      itemCount: 10, // Mock data
      itemBuilder: (context, index) {
        return _buildProductCard(context, index);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    // Mock product data
    final products = [
      {
        'title': 'card binder',
        'price': 'PHP 40',
        'condition': 'Like New',
        'seller': 'heartcollects',
      },
      {
        'title': 'TUP 9 Pocket Binder (Powder Pink) Brand new sealed',
        'price': 'PHP 1,234',
        'condition': 'Brand New',
        'seller': 'Deykey123',
      },
    ];

    final product = products[index % products.length];

    return _buildPlatformCard(
      context: context,
      onTap: () {
        // Handle product tap
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: _getProductImageBackground(context),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildProductImage(),
              ),
            ),
          ),

          // Product details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product['title']!,
                    style: _getProductTitleStyle(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price and condition
                  Row(
                    children: [
                      Text(
                        product['price']!,
                        style: _getProductPriceStyle(context),
                      ),
                      const Spacer(),
                      Text(
                        product['condition']!,
                        style: _getProductConditionStyle(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Seller
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getSellerAvatarBackground(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getAdaptiveIcon(
                            AdaptiveIcon.profile,
                            selected: false,
                          ),
                          size: 10,
                          color: _getSellerAvatarIconColor(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['seller']!,
                          style: _getSellerTextStyle(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
  }) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
              ),
            ),
            child: child,
          ),
        );
      }

      if (Platform.isWindows) {
        return fl.Button(
          onPressed: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: fl.FluentTheme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: fl.FluentTheme.of(
                  context,
                ).resources.cardStrokeColorDefault,
              ),
            ),
            child: child,
          ),
        );
      }
    }

    // Material
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeUtils.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.amber.shade200, Colors.orange.shade300],
        ),
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.brown.shade400,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.brown.shade300),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Color _getProductImageBackground(BuildContext context) {
    return Colors.amber.shade100;
  }

  TextStyle? _getProductTitleStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(
          context,
        ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w500);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(
          context,
        ).typography.body?.copyWith(fontWeight: FontWeight.w500);
      }
    }
    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
  }

  TextStyle? _getProductPriceStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: CupertinoColors.activeBlue.resolveFrom(context),
          fontSize: 13,
        );
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).typography.caption?.copyWith(
          fontWeight: FontWeight.w600,
          color: fl.FluentTheme.of(context).accentColor,
        );
      }
    }
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  TextStyle? _getProductConditionStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.systemGreen.resolveFrom(context),
          fontSize: 10,
        );
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).typography.caption?.copyWith(
          color: Colors.green.shade600,
          fontSize: 10,
        );
      }
    }
    return Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.green.shade600, fontSize: 10);
  }

  Color _getSellerAvatarBackground(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoColors.systemGrey5.resolveFrom(context);
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).resources.subtleFillColorSecondary;
      }
    }
    return Colors.grey.shade300;
  }

  Color _getSellerAvatarIconColor(BuildContext context) {
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

  TextStyle? _getSellerTextStyle(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          fontSize: 11,
        );
      }
      if (Platform.isWindows) {
        return fl.FluentTheme.of(context).typography.caption?.copyWith(
          color: fl.FluentTheme.of(context).resources.textFillColorSecondary,
          fontSize: 11,
        );
      }
    }
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
      fontSize: 11,
    );
  }

  IconData _getAdaptiveIcon(AdaptiveIcon icon, {required bool selected}) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        switch (icon) {
          case AdaptiveIcon.home:
            return selected ? CupertinoIcons.house_fill : CupertinoIcons.house;
          case AdaptiveIcon.search:
            return CupertinoIcons.search;
          case AdaptiveIcon.favorite:
            return selected ? CupertinoIcons.heart_fill : CupertinoIcons.heart;
          case AdaptiveIcon.profile:
            return selected
                ? CupertinoIcons.person_fill
                : CupertinoIcons.person;
          case AdaptiveIcon.settings:
            return CupertinoIcons.settings;
          default:
            return CupertinoIcons.question;
        }
      }

      if (Platform.isWindows) {
        switch (icon) {
          case AdaptiveIcon.home:
            return fl.FluentIcons.home;
          case AdaptiveIcon.search:
            return fl.FluentIcons.search;
          case AdaptiveIcon.favorite:
            return fl.FluentIcons.heart;
          case AdaptiveIcon.profile:
            return fl.FluentIcons.contact;
          case AdaptiveIcon.settings:
            return fl.FluentIcons.settings;
          default:
            return fl.FluentIcons.help;
        }
      }
    }

    // Material
    switch (icon) {
      case AdaptiveIcon.home:
        return selected ? Icons.home : Icons.home_outlined;
      case AdaptiveIcon.search:
        return Icons.explore_outlined;
      case AdaptiveIcon.favorite:
        return selected ? Icons.favorite : Icons.favorite_border;
      case AdaptiveIcon.profile:
        return selected ? Icons.person : Icons.person_outline;
      case AdaptiveIcon.settings:
        return Icons.settings;
      default:
        return Icons.help_outline;
    }
  }
}
