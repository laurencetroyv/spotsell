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
import 'package:spotsell/src/ui/feature/buyer/pages/message_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = BuyerViewModel();
    _viewModel.initialize();

    _viewModel.tabController = TabController(
      length: _viewModel.tabs.length,
      vsync: this,
    );

    _initialzeAuth();
  }

  Future<void> _initialzeAuth() async {
    _authService = getService<AuthService>();
    if (!_authService.isInitialized) {
      await _authService.initialize();
    }

    _viewModel.pages = [
      ConversationScreen(),
      ExploreScreen(_viewModel),
      ProfileScreen(_authService),
    ];
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
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.favorite)),
          selectedIcon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages)),
          label: const Text('Message'),
        ),
        NavigationRailDestination(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.home)),
          selectedIcon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.home)),
          label: const Text('Explore'),
        ),
        NavigationRailDestination(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.settings)),
          selectedIcon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.settings)),
          label: const Text('Me'),
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
              icon: const Icon(CupertinoIcons.chat_bubble),
              activeIcon: const Icon(CupertinoIcons.chat_bubble_fill),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.search)),
              label: 'Explore',
            ),

            BottomNavigationBarItem(
              icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile)),
              label: 'Me',
            ),
          ],
        );
      }

      if (Platform.isWindows) {
        // Fluent UI doesn't have bottom navigation, so we'll skip it
        return null;
      }
    }

    // Material (Android, Linux, Web)
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
        const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Message'),

        BottomNavigationBarItem(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.search)),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile)),
          label: 'Me',
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
