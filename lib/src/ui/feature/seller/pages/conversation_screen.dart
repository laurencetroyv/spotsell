import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/feature/seller/view_models/conversation_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen(this.store, {super.key});

  final Store store;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationViewModel _viewModel;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = ConversationViewModel(widget.store);
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return AdaptiveScaffold(
      isLoading: _viewModel.isLoading,
      appBar: _buildAppBar(context, responsive),
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              children: [
                _buildSearchBar(context, responsive),
                Expanded(child: _buildChatList(context, responsive)),
              ],
            ),
          );
        },
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
      if (Platform.isWindows || Platform.isMacOS || Platform.isIOS) {
        return null;
      }
    }

    // Material
    return AppBar(
      title: const Text('Messages'),
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Padding(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      child: AdaptiveTextField(
        controller: _viewModel.controller,
        onChanged: (value) {
          setState(() {
            _viewModel.searchQuery = value;
          });
        },
        placeholder: 'Search messages...',
      ),
    );
  }

  Widget _buildChatList(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final filteredChats = _viewModel.filteredConversation;

    if (filteredChats.isEmpty) {
      return _buildEmptyState(context, responsive);
    }

    return ListView.builder(
      itemCount: filteredChats.length,
      padding: EdgeInsets.symmetric(horizontal: responsive.mediumSpacing),
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return _buildChatCard(context, responsive, chat);
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ThemeUtils.getAdaptiveIcon(AdaptiveIcon.messages),
            size: 64,
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: responsive.mediumSpacing),
          Text(
            _viewModel.searchQuery.isEmpty
                ? 'No messages yet'
                : 'No messages found',
            style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.title)
                ?.copyWith(
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
          ),
          SizedBox(height: responsive.smallSpacing),
          Text(
            _viewModel.searchQuery.isEmpty
                ? 'Messages from customers will appear here'
                : 'Try a different search term',
            style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body)
                ?.copyWith(
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    Conversation chat,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.smallSpacing),
      decoration: ThemeUtils.getAdaptiveCardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChat(chat),
          borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
          child: Padding(
            padding: EdgeInsets.all(responsive.mediumSpacing),
            child: Row(
              children: [
                _buildAvatar(context, responsive, chat),
                SizedBox(width: responsive.mediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat.buyer?.name ?? '',
                              style: ThemeUtils.getAdaptiveTextStyle(
                                context,
                                TextStyleType.body,
                              )?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _formatTimestamp(chat.updatedAt),
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
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        chat.buyer?.email ?? '',
                        style: ThemeUtils.getAdaptiveTextStyle(
                          context,
                          TextStyleType.caption,
                        )?.copyWith(color: ThemeUtils.getPrimaryColor(context)),
                      ),
                      SizedBox(height: responsive.smallSpacing * 0.5),
                      Text(
                        chat.latestMessage?.content ?? '',
                        style:
                            ThemeUtils.getAdaptiveTextStyle(
                              context,
                              TextStyleType.body,
                            )?.copyWith(
                              color: ThemeUtils.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    Conversation chat,
  ) {
    const double avatarSize = 48;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeUtils.getPrimaryColor(context).withValues(alpha: 0.1),
        border: Border.all(
          color: ThemeUtils.getPrimaryColor(context).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child:
          chat.buyer?.attachments != null && chat.buyer!.attachments!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                chat.buyer!.attachments!.first.url,
                fit: BoxFit.cover,
                width: avatarSize,
                height: avatarSize,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(context),
              ),
            )
          : _buildDefaultAvatar(context),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Icon(
      ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile),
      size: 24,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _openChat(Conversation chat) {
    context.pushNamed(RouteNames.message, arguments: chat);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
