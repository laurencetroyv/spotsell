import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';

abstract class ConversationRepository {
  Future<Result<List<Conversation>>> showBuyerListAllMessage(Meta request);

  Future<Result<List<Conversation>>> showSellerListAllMessage(
    SellerMeta request,
  );

  Future<Result<Conversation>> createBuyerConversation(
    ConversationRequest request,
  );

  Future<Result<Conversation>> createSellerConversation(
    SellerConversationRequest request,
  );

  Future<Result<Conversation>> showBuyerConversation(num id);

  Future<Result<Conversation>> showSellerConversation(num id);
}
