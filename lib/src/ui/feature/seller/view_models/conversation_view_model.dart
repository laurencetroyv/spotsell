import 'package:flutter/cupertino.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/conversation_repository.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ConversationViewModel extends BaseViewModel {
  ConversationViewModel(this._store);

  final Store _store;

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
    _initializeRepository();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _initializeRepository() async {
    try {
      _repository = getService<ConversationRepository>();

      final request = SellerMeta(storeId: _store.id, showAll: true);

      final response = await _repository.showSellerListAllMessage(request);

      switch (response) {
        case Ok<List<Conversation>>():
          conversations = response.value;
        case Error<List<Conversation>>():
          conversations = [];
      }
    } catch (e) {
      debugPrint('Error initializing converation repository: $e');
    }
  }
}
