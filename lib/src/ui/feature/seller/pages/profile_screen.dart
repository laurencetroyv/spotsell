import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/seller/view_models/profile_view_model.dart';
import 'package:spotsell/src/ui/feature/seller/widgets/profile_info_card.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this.store, {super.key, required this.authService});

  final Store store;
  final AuthService authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  late AuthService _authService;
  late AuthUser? _user;
  late Store _store;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _viewModel.initialize();

    _authService = widget.authService;
    _user = _authService.currentUser;
    _store = widget.store;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return SafeArea(
      child: AdaptiveScaffold(
        isLoading: _viewModel.isLoading,
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

    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(
          'Store Profile',
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _handleSignOut,
          child: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.signOut)),
        ),
      );
    }

    // Material
    return AppBar(
      title: const Text('Store Profile'),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: responsive.screenHeight),
        child: Column(
          children: [
            SizedBox(height: responsive.mediumSpacing),

            ProfileInfoCard(
              user: _user,
              store: _store,
              authService: _authService,
            ),
            SizedBox(height: responsive.largeSpacing),

            SizedBox(height: responsive.mediumSpacing),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    // Show confirmation dialog first
    final shouldSignOut = await _showSignOutConfirmation();
    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
      } catch (e) {
        debugPrint('Sign out error: $e');
        _viewModel.showErrorMessage('Failed to sign out. Please try again.');
      }
    }
  }

  Future<bool?> _showSignOutConfirmation() async {
    if (Platform.isIOS) {
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
