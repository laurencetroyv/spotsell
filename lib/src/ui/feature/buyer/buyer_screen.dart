import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/buyer/buyer_view_model.dart';
import 'package:spotsell/src/ui/feature/buyer/pages/conversation_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/pages/explore_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/pages/profile_screen.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen>
    with TickerProviderStateMixin {
  late BuyerViewModel _viewModel;
  late AuthService _authService;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // bool _showAdvancedFilters = false;
  // bool _isCompactMode = false;

  @override
  void initState() {
    super.initState();
    _viewModel = BuyerViewModel();
    _viewModel.initialize();

    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _authService = getService<AuthService>();
    if (!_authService.isInitialized) {
      await _authService.initialize();
    }

    _viewModel.pages = [
      ConversationScreen(),
      ExploreScreen(),
      ProfileScreen(_authService),
    ];
  }

  void _navigateToTab(int index) {
    if (index < _viewModel.pages.length) {
      setState(() {
        _viewModel.selectedNavIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return Scaffold(
      body: Row(
        children: [
          if (_shouldShowNavigationRail(responsive))
            _buildEnhancedNavigationSidebar(context, responsive),

          Expanded(
            child: AdaptiveScaffold(
              bottomNavigationBar: responsive.shouldShowBottomNavigation
                  ? _buildBottomNavigation(context)
                  : null,
              child: _buildMainContent(context, responsive),
              children: _viewModel.pages,
              signOut: () => _authService.signOut(),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowNavigationRail(ResponsiveBreakpoints responsive) {
    return responsive.shouldShowNavigationRail ||
        (!kIsWeb && Platform.isWindows) ||
        (kIsWeb && responsive.isDesktop);
  }

  Widget _buildEnhancedNavigationSidebar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final isDesktop = responsive.isDesktop;
    final railWidth = _viewModel.extend ? 280.0 : 90.0;

    return Container(
      width: railWidth,
      decoration: BoxDecoration(
        color: ThemeUtils.getSurfaceColor(context),
        border: Border(
          right: BorderSide(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          _buildRailHeader(context, responsive),

          Expanded(child: _buildRailContent(context, responsive)),

          _buildRailFooter(context, responsive),
        ],
      ),
    );
  }

  Widget _buildRailHeader(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _viewModel.toggleExtended());
                },
                icon: const Icon(Icons.menu),
                tooltip: _viewModel.extend
                    ? 'Collapse sidebar'
                    : 'Expand sidebar',
              ),
              if (_viewModel.extend) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SpotSell',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (_viewModel.extend && responsive.isDesktop) ...[
            const SizedBox(height: 16),
            _buildSearchBar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: ThemeUtils.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeUtils.getTextColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.5),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: (value) {},
      ),
    );
  }

  Widget _buildRailContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: responsive.smallSpacing),
      children: [
        ...List.generate(_getNavigationItems().length, (index) {
          final item = _getNavigationItems()[index];
          final isSelected = _viewModel.selectedNavIndex == index;

          return _buildNavigationItem(
            context,
            item['icon'] as IconData,
            item['selectedIcon'] as IconData,
            item['label'] as String,
            isSelected,
            () => _navigateToTab(index),
          );
        }),

        const SizedBox(height: 16),

        // if (_viewModel.extend && responsive.isDesktop) ...[
        //   _buildSectionDivider(context, 'Quick Actions'),
        //   _buildQuickActionItem(
        //     context,
        //     Icons.filter_list,
        //     'Advanced Filters',
        //     () => setState(() => _showAdvancedFilters = !_showAdvancedFilters),
        //   ),
        //   _buildQuickActionItem(
        //     context,
        //     _isCompactMode ? Icons.view_list : Icons.view_module,
        //     _isCompactMode ? 'Card View' : 'Compact View',
        //     () => setState(() => _isCompactMode = !_isCompactMode),
        //   ),
        //   _buildQuickActionItem(
        //     context,
        //     Icons.refresh,
        //     'Refresh',
        //     () => _refreshCurrentPage(),
        //   ),
        // ],
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isExtended = _viewModel.extend;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
                size: 24,
              ),
              if (isExtended) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildSectionDivider(BuildContext context, String title) {
  //   if (!_viewModel.extend) return const SizedBox.shrink();

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Text(
  //       title,
  //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //         color: Theme.of(
  //           context,
  //         ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
  //         fontWeight: FontWeight.w600,
  //         letterSpacing: 0.5,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildQuickActionItem(
  //   BuildContext context,
  //   IconData icon,
  //   String label,
  //   VoidCallback onTap,
  // ) {
  //   return _buildNavigationItem(context, icon, icon, label, false, onTap);
  // }

  Widget _buildRailFooter(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          if (_viewModel.extend) ...[
            _buildUserProfileSection(context),
            const SizedBox(height: 12),
          ],

          _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    final user = _authService.currentUser;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeUtils.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return _buildNavigationItem(
      context,
      ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut),
      ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut),
      'Sign Out',
      false,
      () => _authService.signOut(),
    );
  }

  List<Map<String, dynamic>> _getNavigationItems() {
    return [
      {
        'icon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages),
        'selectedIcon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages),
        'label': 'Messages',
      },
      {
        'icon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.home),
        'selectedIcon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.home),
        'label': 'Explore',
      },
      {
        'icon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile),
        'selectedIcon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile),
        'label': 'Profile',
      },
    ];
  }

  Widget? _buildBottomNavigation(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTabBar(
          currentIndex: _viewModel.selectedNavIndex,
          onTap: _navigateToTab,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble),
              activeIcon: Icon(CupertinoIcons.chat_bubble_fill),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.search)),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile)),
              label: 'Profile',
            ),
          ],
        );
      }

      if (Platform.isWindows) {
        return null;
      }
    }

    return BottomNavigationBar(
      currentIndex: _viewModel.selectedNavIndex,
      onTap: _navigateToTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ThemeUtils.getPrimaryColor(context),
      unselectedItemColor: ThemeUtils.getTextColor(
        context,
      ).withValues(alpha: 0.6),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.search)),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile)),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final maxWidth = responsive.maxContentWidth;

    Widget content = _viewModel.pages[_viewModel.selectedNavIndex];

    if (responsive.isDesktop) {
      content = Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    return content;
  }

  // void _refreshCurrentPage() {
  //   debugPrint('Refreshing current page');
  // }
}
