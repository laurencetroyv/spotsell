import 'package:spotsell/src/data/entities/entities.dart';

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

class MessageBuyerRequest {
  final String content;
  MessageBuyerRequest({required this.content});
}
