import 'package:spotsell/src/data/entities/entities.dart';

class Conversation {
  final num id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final AuthUser buyer;
  final Store seller;

  final Message latestMessage;

  Conversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.buyer,
    required this.seller,
    required this.latestMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: num.parse(json['id']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      buyer: AuthUser.fromJson(json['buyer']),
      seller: Store.fromJson(json['store']),
      latestMessage: Message.fromJson(json['latest_message']),
    );
  }
}

class ConversationRequest {
  final num storeId;
  final String message;
  final num maxMessageLength = 1000;

  ConversationRequest({required this.storeId, required this.message});

  Map<String, dynamic> toJson() {
    return {"store_id": storeId, "message": message};
  }
}

class SellerConversationRequest extends ConversationRequest {
  final num buyerId;

  SellerConversationRequest({
    required this.buyerId,
    required super.storeId,
    required super.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return {"buyer_id": buyerId, ...super.toJson()};
  }
}
