import 'package:flutter/cupertino.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/conversation_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ConversationViewModel extends BaseViewModel {
  late ConversationRepository _repository;

  final TextEditingController controller = TextEditingController();

  String searchQuery = '';
  List<Conversation> conversations = [];

  List<Conversation> get filteredConversation {
    if (searchQuery.isEmpty) {
      return conversations;
    }

    if (conversations.isEmpty) {
      return conversations;
    }

    return conversations.where((chat) {
      return chat.buyer!.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          chat.buyer!.username.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          chat.latestMessage!.content.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  void initialize() {
    super.initialize();
    _repository = getService<ConversationRepository>();
    _initializeRepository();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _initializeRepository() async {
    final request = BuyerConversationMeta(showAll: true);

    final response = await executeAsyncResult<List<Conversation>>(
      () => _repository.showBuyerListAllMessage(request),
      showLoading: false,
      onSuccess: (conversations) {
        this.conversations = conversations;
        safeNotifyListeners();
      },
    );

    if (!response) {
      debugPrint('Failed to load conversations');
    }
  }
}
