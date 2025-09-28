import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/message_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late MessageViewModel _viewModel;
  late AuthService _authService;
  late Conversation _conversation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _conversation = ModalRoute.of(context)!.settings.arguments! as Conversation;

    _viewModel = MessageViewModel();
    _authService = getService<AuthService>();
    _viewModel.initialize();
    _viewModel.setConversationId(_conversation.id);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SafeArea(
          child: AdaptiveScaffold(
            backgroundColor: ThemeUtils.getBackgroundColor(context),
            appBar: _buildAppBar(context, responsive),
            child: Column(
              children: [
                Expanded(child: _buildMessageList(context, responsive)),
                _buildMessageInput(context, responsive),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final title = _conversation.seller!.name;

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationBar(
          middle: Text(title),
          backgroundColor: ThemeUtils.getBackgroundColor(context),
        );
      }
      if (Platform.isWindows) {
        return null; // Fluent UI handles its own navigation
      }
    }

    // Material
    return AppBar(
      title: Text(title),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ThemeUtils.getBackgroundColor(context),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ThemeUtils.getAdaptiveIcon(AdaptiveIcon.error),
              size: 64,
              color: ThemeUtils.getTextColor(context).withValues(alpha: 0.3),
            ),
            SizedBox(height: responsive.mediumSpacing),
            Text(
              'Error loading messages',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.title,
                  )?.copyWith(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              _viewModel.errorMessage ?? 'Something went wrong',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.body,
                  )?.copyWith(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.mediumSpacing),
            AdaptiveButton(
              type: AdaptiveButtonType.secondary,
              onPressed: _viewModel.refreshConversation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_viewModel.messages.isEmpty) {
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
              'No messages yet',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.title,
                  )?.copyWith(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              'Start the conversation by sending a message',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.body,
                  )?.copyWith(
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

    return ListView.builder(
      controller: _viewModel.scrollController,
      padding: EdgeInsets.all(responsive.mediumSpacing),
      itemCount: _viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = _viewModel.messages[index];
        return _buildMessageBubble(context, responsive, message);
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    Message message,
  ) {
    final currentUser = _authService.currentUser;
    final isMyMessage = currentUser?.id == message.sender?.id;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.smallSpacing * 0.5),
      child: Row(
        mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) _buildAvatar(context, message.sender),
          if (!isMyMessage) SizedBox(width: responsive.smallSpacing),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(responsive.mediumSpacing),
              decoration: BoxDecoration(
                color: isMyMessage
                    ? ThemeUtils.getPrimaryColor(context)
                    : ThemeUtils.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isMyMessage ? const Radius.circular(4) : null,
                  bottomLeft: !isMyMessage ? const Radius.circular(4) : null,
                ),
                border: !isMyMessage
                    ? Border.all(
                        color: ThemeUtils.getTextColor(
                          context,
                        ).withValues(alpha: 0.1),
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style:
                        ThemeUtils.getAdaptiveTextStyle(
                          context,
                          TextStyleType.body,
                        )?.copyWith(
                          color: isMyMessage
                              ? Colors.white
                              : ThemeUtils.getTextColor(context),
                        ),
                  ),
                  SizedBox(height: responsive.smallSpacing * 0.5),
                  Text(
                    _formatTimestamp(message.createdAt),
                    style:
                        ThemeUtils.getAdaptiveTextStyle(
                          context,
                          TextStyleType.caption,
                        )?.copyWith(
                          color: isMyMessage
                              ? Colors.white.withValues(alpha: 0.7)
                              : ThemeUtils.getTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (isMyMessage) SizedBox(width: responsive.smallSpacing),
          if (isMyMessage) _buildAvatar(context, message.sender),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, AuthUser? user) {
    const double avatarSize = 32;

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
      child: user?.attachments != null && user!.attachments!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                user.attachments!.first.url,
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
      size: 18,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: ThemeUtils.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AdaptiveTextField(
              controller: _viewModel.messageController,
              placeholder: 'Type a message...',
              maxLines: 3,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: responsive.smallSpacing),
          AdaptiveButton(
            onPressed: _sendMessage,
            isLoading: _viewModel.isLoading,
            icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.send), size: 20),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _sendMessage() {
    if (_viewModel.messageController.text.trim().isNotEmpty) {
      _viewModel.sendMessage();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
