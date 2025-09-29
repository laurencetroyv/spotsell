import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/seller/pages/pages.dart';
import 'package:spotsell/src/ui/feature/seller/view_models/seller_view_model.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  late Store _store;
  late SellerViewModel _viewModel;
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _store = ModalRoute.of(context)!.settings.arguments! as Store;

    _viewModel = SellerViewModel();
    _viewModel.initialize();
    _initialzeAuth();

    _viewModel.pages = [
      ConversationScreen(_store),
      ProductsScreen(_store),
      ProfileScreen(_store, authService: _authService),
    ];
  }

  Future<void> _initialzeAuth() async {
    _authService = getService<AuthService>();
    if (!_authService.isInitialized) {
      await _authService.initialize();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    final navigationRail = !kIsWeb && Platform.isWindows;

    return AdaptiveScaffold(
      appBar: _viewModel.selectedNavIndex != 2
          ? _buildAppBar(context, responsive)
          : null,
      navigationRail: navigationRail || responsive.shouldShowNavigationRail
          ? _buildNavigationRail(context)
          : null,
      bottomNavigationBar: responsive.shouldShowBottomNavigation
          ? _buildBottomNavigation(context)
          : null,
      child: _buildMainContent(context, responsive),
      children: _viewModel.pages,
      signOut: () => _authService.signOut(),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationBar(
          middle: Text("${_store.name} Store"),
          automaticallyImplyLeading: false,
        );
      }
    }

    return AppBar(
      title: Text("${_store.name} Store"),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  NavigationRail _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _viewModel.selectedNavIndex,
      onDestinationSelected: (index) {
        setState(() {
          _viewModel.selectedNavIndex = index;
        });
      },
      leading: IconButton(
        onPressed: () {
          setState(() => _viewModel.extend = !_viewModel.extend);
        },
        icon: Icon(Icons.menu),
      ),
      leadingAtTop: true,
      extended: _viewModel.extend,
      labelType: _viewModel.extend ? null : NavigationRailLabelType.all,
      backgroundColor: ThemeUtils.getSurfaceColor(context),
      destinations: [
        NavigationRailDestination(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.home)),
          selectedIcon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.home)),
          label: const Text('Messages'),
        ),
        NavigationRailDestination(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.favorite)),
          selectedIcon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.favorite)),
          label: const Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.settings)),
          selectedIcon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.settings)),
          label: const Text('Profile'),
        ),
      ],
      trailing: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _authService.signOut(),
                icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut)),
              ),
              if (_viewModel.extend) Text('Sign Out'),
            ],
          ),
          SizedBox(height: ThemeUtils.getAdaptivePadding(context).bottom - 4),
        ],
      ),
      trailingAtBottom: true,
    );
  }

  Widget? _buildBottomNavigation(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoTabBar(
          currentIndex: _viewModel.selectedNavIndex,
          onTap: (index) {
            setState(() {
              _viewModel.selectedNavIndex = index;
            });
          },
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages)),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.bag),
              activeIcon: const Icon(CupertinoIcons.bag_fill),
              label: 'Products',
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
      onTap: (index) {
        setState(() {
          _viewModel.selectedNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ThemeUtils.getPrimaryColor(context),
      unselectedItemColor: ThemeUtils.getTextColor(
        context,
      ).withValues(alpha: 0.6),
      items: [
        BottomNavigationBarItem(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages)),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront),
          label: 'Products',
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
    return _viewModel.pages[_viewModel.selectedNavIndex];
  }
}
