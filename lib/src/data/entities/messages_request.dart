import 'package:spotsell/src/data/entities/auth_request.dart';
import 'package:spotsell/src/data/entities/store_request.dart';

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

class Message {
  final num id;
  final String content;
  final DateTime readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AuthUser sender;

  Message({
    required this.id,
    required this.content,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      readAt: DateTime.parse(json['read_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: AuthUser.fromJson(json['sender']),
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

enum SortOrder { asc, desc }

class Meta {
  num? page = 1;
  num? perPage = 15;
  String? search = '';
  bool? showAll = false;
  String? sortBy = '';
  SortOrder? sortOrder = SortOrder.asc;

  Meta({
    this.page,
    this.perPage,
    this.search,
    this.showAll,
    this.sortBy,
    this.sortOrder,
  });
}

/// Seller
class SellerMeta extends Meta {
  final num storeId;

  SellerMeta({
    required this.storeId,
    super.page,
    super.perPage,
    super.search,
    super.showAll,
    super.sortBy,
    super.sortOrder,
  });
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
