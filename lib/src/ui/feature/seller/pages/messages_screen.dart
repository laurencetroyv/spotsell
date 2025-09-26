import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen(this.store, {super.key});

  final Store store;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ChatItem> _chats = [
    ChatItem(
      id: '1',
      userName: 'John Doe',
      username: '@johndoe',
      lastMessage: 'Is this item still available?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      avatarUrl: null,
      unreadCount: 2,
    ),
    ChatItem(
      id: '2',
      userName: 'Sarah Wilson',
      username: '@sarahw',
      lastMessage: 'Thank you for the quick delivery!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      avatarUrl: null,
      unreadCount: 0,
    ),
    ChatItem(
      id: '3',
      userName: 'Mike Johnson',
      username: '@mikej',
      lastMessage: 'Can you provide more details about this product?',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      avatarUrl: null,
      unreadCount: 1,
    ),
  ];

  List<ChatItem> get _filteredChats {
    if (_searchQuery.isEmpty) {
      return _chats;
    }
    return _chats.where((chat) {
      return chat.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return AdaptiveScaffold(
      backgroundColor: ThemeUtils.getBackgroundColor(context),
      appBar: _buildAppBar(context, responsive),
      child: Column(
        children: [
          _buildSearchBar(context, responsive),
          Expanded(child: _buildChatList(context, responsive)),
        ],
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
            'Messages',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
        );
      }

      if (Platform.isWindows) {
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
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.mediumSpacing,
          vertical: responsive.smallSpacing,
        ),
        decoration: BoxDecoration(
          color: ThemeUtils.getSurfaceColor(context),
          borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
          border: Border.all(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              ThemeUtils.getAdaptiveIcon(AdaptiveIcon.search),
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.5),
              size: 20,
            ),
            SizedBox(width: responsive.smallSpacing),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle:
                      ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.body,
                      )?.copyWith(
                        color: ThemeUtils.getTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: ThemeUtils.getAdaptiveTextStyle(
                  context,
                  TextStyleType.body,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Icon(
                  ThemeUtils.getAdaptiveIcon(AdaptiveIcon.close),
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final filteredChats = _filteredChats;

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
            _searchQuery.isEmpty ? 'No messages yet' : 'No messages found',
            style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.title)
                ?.copyWith(
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
          ),
          SizedBox(height: responsive.smallSpacing),
          Text(
            _searchQuery.isEmpty
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
    ChatItem chat,
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
                              chat.userName,
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
                                _formatTimestamp(chat.timestamp),
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
                              if (chat.unreadCount > 0) ...[
                                SizedBox(width: responsive.smallSpacing),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ThemeUtils.getPrimaryColor(context),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    chat.unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        chat.username,
                        style: ThemeUtils.getAdaptiveTextStyle(
                          context,
                          TextStyleType.caption,
                        )?.copyWith(color: ThemeUtils.getPrimaryColor(context)),
                      ),
                      SizedBox(height: responsive.smallSpacing * 0.5),
                      Text(
                        chat.lastMessage,
                        style:
                            ThemeUtils.getAdaptiveTextStyle(
                              context,
                              TextStyleType.body,
                            )?.copyWith(
                              color: ThemeUtils.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
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
    ChatItem chat,
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
      child: chat.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                chat.avatarUrl!,
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

  void _openChat(ChatItem chat) {
    // TODO: Navigate to individual chat screen
    debugPrint('Opening chat with ${chat.userName}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ChatItem {
  final String id;
  final String userName;
  final String username;
  final String lastMessage;
  final DateTime timestamp;
  final String? avatarUrl;
  final int unreadCount;

  ChatItem({
    required this.id,
    required this.userName,
    required this.username,
    required this.lastMessage,
    required this.timestamp,
    this.avatarUrl,
    this.unreadCount = 0,
  });
}
