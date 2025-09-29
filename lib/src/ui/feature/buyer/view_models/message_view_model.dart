import 'dart:async';

import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/message_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class MessageViewModel extends BaseViewModel {
  late MessageRepository _repository;
  late bool _isSeller;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Message> _messages = [];
  Timer? _refreshTimer;

  List<Message> get messages => _messages;

  num? _conversationId;

  @override
  void initialize() {
    _repository = getService<MessageRepository>();
    super.initialize();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void setConversationId(num conversationId, bool isSeller) {
    _conversationId = conversationId;
    _isSeller = isSeller;
    _loadMessages();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      refreshConversationSilently();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  void resumeAutoRefresh() {
    if (_conversationId != null) {
      _startAutoRefresh();
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;

    final request = Meta(perPage: 15, page: 1);

    final success = await executeAsyncResult<List<Message>>(
      () => _repository.getAllMessages(request, _conversationId!, _isSeller),
      errorMessage: 'Failed to load messages',
      onSuccess: (messages) {
        _messages = messages;
        _scrollToBottom();
      },
    );

    if (!success) {
      debugPrint('Failed to load messages');
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || _conversationId == null) return;

    final request = MessageRequest(content: content);

    messageController.clear();

    final success = await executeAsyncResult<Message>(
      () => _repository.createMessage(request, _conversationId!, _isSeller),
      errorMessage: 'Failed to send message',
      onSuccess: (sentMessage) {
        _messages.add(sentMessage);
        _scrollToBottom();
        safeNotifyListeners();
      },
    );

    if (!success) {
      messageController.text = content;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> refreshConversation() async {
    await _loadMessages();
  }

  Future<void> refreshConversationSilently() async {
    if (_conversationId == null) return;

    final request = Meta(perPage: 3, page: 1);

    // Load messages without showing loading indicator
    final success = await executeAsyncResult<List<Message>>(
      () => _repository.getAllMessages(request, _conversationId!, _isSeller),
      errorMessage: 'Failed to load messages',
      showLoading: false, // Don't show loading for automatic refresh
      onSuccess: (messages) {
        _messages = messages;
        safeNotifyListeners();
      },
    );

    if (!success) {
      debugPrint('Failed to silently refresh messages');
    }
  }
}
