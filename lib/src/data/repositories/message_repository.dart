import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';

abstract class MessageRepository {
  Future<Result<List<Message>>> getAllMessages(
    Meta request,
    num id,
    bool isSeller,
  );

  Future<Result<Message>> createMessage(
    MessageRequest request,
    num id,
    bool isSeller,
  );

  Future<Result<void>> markMessageAsRead(num id, bool isSeller);
}
