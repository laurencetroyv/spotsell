import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:intl/intl.dart';

import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/auth_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/buyer/utils/profile_dialog_utils.dart';
import 'package:spotsell/src/ui/feature/buyer/utils/store_dialog_utils.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/profile_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/role_badge.dart';

class ProfileInfoCard extends StatefulWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.viewModel,
    required this.authService,
  });

  final AuthService authService;
  final AuthUser? user;
  final ProfileViewModel viewModel;

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  late AuthService _authService;
  late AuthUser? _user;
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService;
    _user = widget.user;
    _viewModel = widget.viewModel;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    final isVerified = _user?.verifiedAt != null;
    return Container(
      padding: EdgeInsets.all(responsive.largeSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeUtils.getPrimaryColor(context).withValues(alpha: 0.02),
            ThemeUtils.getPrimaryColor(context).withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture with Status Indicator
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isVerified
                        ? [Colors.green.shade100, Colors.green.shade50]
                        : [
                            ThemeUtils.getPrimaryColor(
                              context,
                            ).withValues(alpha: 0.1),
                            ThemeUtils.getPrimaryColor(
                              context,
                            ).withValues(alpha: 0.05),
                          ],
                  ),
                  border: Border.all(
                    color: isVerified
                        ? Colors.green.shade300
                        : ThemeUtils.getPrimaryColor(
                            context,
                          ).withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isVerified
                                  ? Colors.green
                                  : ThemeUtils.getPrimaryColor(context))
                              .withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _user?.attachments?.isNotEmpty == true
                    ? ClipOval(
                        child: Image.network(
                          _user!.attachments!.first.url,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(context),
                        ),
                      )
                    : _buildDefaultAvatar(context),
              ),

              // Verification Badge
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeUtils.getBackgroundColor(context),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isVerified ? Icons.verified : Icons.pending,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.largeSpacing),

          // User Info Section
          Column(
            children: [
              // Username with Role Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '@${_user?.username ?? 'username'}',
                      style: ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.title,
                      )?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: responsive.smallSpacing),
                  RoleBadge('buyer'),
                ],
              ),

              // Full Name
              if (_user?.firstName != null && _user?.lastName != null) ...[
                SizedBox(height: responsive.smallSpacing),
                Text(
                  '${_user!.firstName} ${_user!.lastName}',
                  style:
                      ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.body,
                      )?.copyWith(
                        color: ThemeUtils.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                ),
              ],

              SizedBox(height: responsive.mediumSpacing),

              // Verification Status Card
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.mediumSpacing,
                  vertical: responsive.smallSpacing,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isVerified
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified
                          ? Icons.shield_outlined
                          : Icons.warning_outlined,
                      color: isVerified
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                      size: 18,
                    ),
                    SizedBox(width: responsive.smallSpacing),
                    Text(
                      isVerified ? 'Verified Account' : 'Pending Verification',
                      style:
                          ThemeUtils.getAdaptiveTextStyle(
                            context,
                            TextStyleType.body,
                          )?.copyWith(
                            color: isVerified
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                    ),
                    if (!isVerified) ...[
                      SizedBox(width: responsive.smallSpacing),
                      GestureDetector(
                        onTap: _handleVerification,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Verify Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.largeSpacing),

          // Stats Row (if needed)
          _buildStatsRow(responsive),

          SizedBox(height: responsive.mediumSpacing),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  onPressed: _handleEditProfile,
                  type: AdaptiveButtonType.secondary,
                  size: AdaptiveButtonSize.medium,
                  child: const Text('Edit Profile'),
                ),
              ),
              SizedBox(width: responsive.mediumSpacing),

              Expanded(
                child: AdaptiveButton(
                  onPressed: _handleBecomeSellerOrManageStore,
                  type: AdaptiveButtonType.primary,
                  size: AdaptiveButtonSize.medium,
                  child: Text(
                    _authService.isSeller ? 'Manage Store' : 'Start Selling',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Icon(
      ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile),
      size: 40,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  Widget _buildStatsRow(ResponsiveBreakpoints responsive) {
    final joinded = DateFormat('MMM. dd, yyyy').format(_user!.createdAt);

    final stats = [
      {'label': 'Items Sold', 'value': '12'},
      {'label': 'Reviews', 'value': '4.8⭐'},
      {'label': 'Joined', 'value': joinded.toString()},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.mediumSpacing),
      child: IntrinsicHeight(
        child: Row(
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;

            return Expanded(
              child: Row(
                children: [
                  if (index > 0)
                    Container(
                      width: 1,
                      height: double.infinity,
                      color: ThemeUtils.getTextColor(
                        context,
                      ).withValues(alpha: 0.2),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          stat['value']!,
                          style:
                              ThemeUtils.getAdaptiveTextStyle(
                                context,
                                TextStyleType.title,
                              )?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: ThemeUtils.getPrimaryColor(context),
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat['label']!,
                          style:
                              ThemeUtils.getAdaptiveTextStyle(
                                context,
                                TextStyleType.caption,
                              )?.copyWith(
                                color: ThemeUtils.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showCreateStoreDialog() async {
    try {
      final newStore = await StoreDialogUtils.showCreateStoreDialog(context);

      if (newStore != null) {
        // Store created successfully
        setState(() {
          _viewModel.userStores.add(newStore);
        });

        // Refresh auth service to update user roles if needed
        await _authService.refreshUser(_authService.currentUser?.token);

        // Show success and guide user
        _showStoreCreatedGuidance(newStore);
      }
    } catch (e) {
      debugPrint('Error creating store: $e');
      _viewModel.showErrorMessage('Failed to create store. Please try again.');
    }
  }

  Future<void> _handleBecomeSellerOrManageStore() async {
    if (_authService.isSeller) {
      context.pushNamed(RouteNames.manageStores);
    } else {
      // Show create store dialog to become a seller
      await _showCreateStoreDialog();
    }
  }

  void _showStoreCreatedGuidance(Store store) {
    final message =
        'Congratulations! Your store "${store.name}" has been created. '
        'You can now start adding products and managing your inventory.';

    // Show a guidance dialog or snackbar
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Store Created!'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Got it'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Store "${store.name}" created successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Store "${store.name}" created successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleEditProfile() async {
    if (_user == null) {
      _viewModel.showErrorMessage('User information not available');
      return;
    }

    try {
      final updatedUser = await ProfileDialogUtils.showEditProfileDialog(
        context,
        _user!,
      );

      if (updatedUser != null) {
        // Update the local user state
        setState(() {
          _user = updatedUser;
        });

        // Show success message
        _showProfileUpdateSuccess();

        // Optional: Refresh auth service to ensure consistency
        try {
          await _authService.refreshUser(_authService.currentUser?.token);
        } catch (e) {
          debugPrint('Failed to refresh user after profile update: $e');
          // Don't show error to user as the profile was updated successfully
        }
      }
    } catch (e) {
      debugPrint('Error editing profile: $e');
      _viewModel.showErrorMessage(
        'Failed to update profile. Please try again.',
      );
    }
  }

  // Add this method to show success message
  void _showProfileUpdateSuccess() {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        // iOS users expect more subtle feedback
        HapticFeedback.lightImpact();
        return;
      }

      if (Platform.isWindows) {
        fl.displayInfoBar(
          context,
          builder: (context, close) => fl.InfoBar(
            title: const Text('Success'),
            content: const Text('Your profile has been updated successfully'),
            severity: fl.InfoBarSeverity.success,
            action: fl.IconButton(
              icon: const Icon(fl.FluentIcons.clear),
              onPressed: close,
            ),
          ),
          duration: const Duration(seconds: 3),
        );
        return;
      }
    }

    // Material and fallback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleVerification() {
    // TODO: Navigate to verification screen
    debugPrint('Verification tapped');
  }
}
