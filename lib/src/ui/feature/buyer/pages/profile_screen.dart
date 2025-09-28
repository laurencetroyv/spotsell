import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/auth_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/repositories/store_repository.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/profile_view_model.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/profile_info_card.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/store_item_card.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_progress_ring.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this.authService, {super.key});

  final AuthService authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  late AuthService _authService;
  late StoreRepository _storeRepository;

  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _viewModel.initialize();

    _authService = widget.authService;
    _user = widget.authService.currentUser;

    _initializeStoreRepository();
  }

  Future<void> _initializeStoreRepository() async {
    try {
      _storeRepository = getService<StoreRepository>();
      if (_authService.isSeller) {
        await _loadUserStores();
      }
    } catch (e) {
      debugPrint('Error initializing store repository: $e');
    }
  }

  Future<void> _loadUserStores() async {
    setState(() => _viewModel.isLoadingStores = true);

    try {
      final result = await _storeRepository.getSellerStores();
      switch (result) {
        case Ok<List<Store>>():
          setState(() {
            _viewModel.userStores = result.value;
          });
          break;
        case Error<List<Store>>():
          debugPrint('Error loading stores: ${result.error}');
          break;
      }
    } catch (e) {
      debugPrint('Error loading stores: $e');
    } finally {
      setState(() => _viewModel.isLoadingStores = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return SafeArea(
      child: AdaptiveScaffold(
        appBar: _buildAppBar(context, responsive),
        child: _buildProfileContent(context, responsive),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    // Don't show app bar if using navigation rail (desktop)
    if (responsive.shouldShowNavigationRail) return null;

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Profile',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _handleSignOut,
            child: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut)),
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
                  Text(
                    'Profile',
                    style: fl.FluentTheme.of(context).typography.title,
                  ),
                  const Spacer(),
                  fl.IconButton(
                    icon: Icon(
                      ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut),
                    ),
                    onPressed: _handleSignOut,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Material
    return AppBar(
      title: const Text('Profile'),
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ThemeUtils.getBackgroundColor(context),
      actions: [
        IconButton(
          icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut)),
          onPressed: _handleSignOut,
        ),
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: responsive.mediumSpacing),

          ProfileInfoCard(
            user: _user,
            viewModel: _viewModel,
            authService: _authService,
          ),
          SizedBox(height: responsive.largeSpacing),

          if (_authService.isSeller && _viewModel.userStores.isEmpty)
            AdaptiveProgressRing()
          else ...[
            _buildStoresSection(context, responsive),
            SizedBox(height: responsive.largeSpacing),
          ],
        ],
      ),
    );
  }

  Widget _buildStoresSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final stores = _viewModel.userStores;

    return Column(
      children: [
        _buildSectionHeader(context, 'Stores', 'Manage Stores'),
        SizedBox(height: responsive.smallSpacing),
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...stores.asMap().entries.map((entry) {
                  final index = entry.key;
                  final store = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < stores.length - 1
                          ? responsive.mediumSpacing
                          : 0,
                    ),
                    child: SizedBox(
                      width: responsive.isMobile
                          ? responsive.screenWidth -
                                (responsive.horizontalPadding * 2)
                          : 330,

                      child: GestureDetector(
                        onTap: () => context.pushNamed(
                          RouteNames.seller,
                          arguments: store,
                        ),
                        child: StoreItemCard(
                          storeName: store.name,
                          showHeart: true,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String action,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: ThemeUtils.getAdaptiveTextStyle(
            context,
            TextStyleType.title,
          )?.copyWith(fontWeight: FontWeight.w600),
        ),
        AdaptiveButton(
          onPressed: () => _handleSectionAction(title.toLowerCase()),
          type: AdaptiveButtonType.text,
          size: AdaptiveButtonSize.small,
          child: Text(
            action,
            style: TextStyle(color: ThemeUtils.getPrimaryColor(context)),
          ),
        ),
      ],
    );
  }

  // Widget _buildFavoritesGrid(
  //   BuildContext context,
  //   ResponsiveBreakpoints responsive,
  // ) {
  //   // Mock favorite items
  //   final favorites = List.generate(
  //     6,
  //     (index) => {
  //       'title': 'Item Title',
  //       'price': 'PHP 1,234',
  //       'condition': 'Brand New',
  //       'seller': 'Dexter123',
  //     },
  //   );

  //   int crossAxisCount = 2;

  //   if (responsive.isMobile) {
  //     crossAxisCount = 2;
  //   } else if (responsive.isTablet) {
  //     crossAxisCount = 3;
  //   } else if (responsive.isDesktop) {
  //     crossAxisCount = 5;
  //   } else {
  //     crossAxisCount = 7;
  //   }

  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: crossAxisCount,
  //       childAspectRatio: 0.8,
  //       crossAxisSpacing: responsive.smallSpacing,
  //       mainAxisSpacing: responsive.smallSpacing,
  //     ),
  //     itemCount: favorites.length,
  //     itemBuilder: (context, index) {
  //       final item = favorites[index];
  //       return ItemCard(item: item);
  //     },
  //   );
  // }

  void _handleSectionAction(String section) {
    switch (section) {
      case 'stores':
        context.pushNamed(RouteNames.manageStores);
    }
  }

  Future<void> _handleSignOut() async {
    // Show confirmation dialog first
    final shouldSignOut = await _showSignOutConfirmation();
    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
        // Navigation will be handled automatically by NavigationGuard
      } catch (e) {
        debugPrint('Sign out error: $e');
        // Show error message
        _viewModel.showErrorMessage('Failed to sign out. Please try again.');
      }
    }
  }

  Future<bool?> _showSignOutConfirmation() async {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Sign Out'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      }

      if (Platform.isWindows) {
        return await fl.showDialog<bool>(
          context: context,
          builder: (context) => fl.ContentDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              fl.Button(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              fl.FilledButton(
                child: const Text('Sign Out'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      }
    }

    // Material
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FilledButton(
            child: const Text('Sign Out'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
