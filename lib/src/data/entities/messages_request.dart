import 'package:spotsell/src/data/entities/entities.dart';

class Message {
  final num id;
  final String content;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AuthUser? sender;

  Message({
    required this.id,
    required this.content,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: json['sender'] != null
          ? AuthUser.fromJson(json['sender'], fromMessage: true)
          : null,
    );
  }
}

class MessageRequest {
  final String content;
  MessageRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {"content": content};
  }
}
