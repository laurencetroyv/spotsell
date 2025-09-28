import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';

class ProfileInfoCard extends StatefulWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.store,
    required this.authService,
  });

  final AuthService authService;
  final AuthUser? user;
  final Store store;

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  late AuthService _authService;
  late AuthUser? _user;
  late Store _store;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService;
    _user = widget.user;
    _store = widget.store;
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

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _store.name,
                      style: ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.title,
                      )?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (_store.description != null) ...[
                SizedBox(height: responsive.smallSpacing),
                Text(
                  _store.description ?? '',
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
            ],
          ),

          SizedBox(height: responsive.largeSpacing),

          _buildStatsRow(responsive),

          SizedBox(height: responsive.mediumSpacing),

          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  onPressed: _handleEditStoreDetails,
                  type: AdaptiveButtonType.secondary,
                  size: AdaptiveButtonSize.medium,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ThemeUtils.getAdaptiveIcon(AdaptiveIcon.settings),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Edit Store'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: responsive.mediumSpacing),

              Expanded(
                child: AdaptiveButton(
                  onPressed: _switchToBuyer,
                  type: AdaptiveButtonType.primary,
                  size: AdaptiveButtonSize.medium,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _authService.isSeller ? Icons.store : Icons.storefront,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text('Switch to Buyer'),
                    ],
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
    final joinded = DateFormat('MMM. dd, yyyy').format(_store.createdAt);

    final stats = [
      {'label': 'Products', 'value': '12'},
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

  Future<void> _handleEditStoreDetails() async {}

  Future<void> _switchToBuyer() async {
    await context.pushNamedAndClearStack(RouteNames.home);
  }
}
