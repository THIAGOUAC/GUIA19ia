import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_message_entity.dart';

abstract class AiChatRepository {
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String message,
    String? productContext,
  });

  Stream<Either<Failure, String>> sendMessageStreaming({
    required String message,
    String? productContext,
  });

  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory(
    String userId,
  );

  Future<Either<Failure, Unit>> saveMessage({
    required String userId,
    required ChatMessageEntity message,
  });

  void resetSession();
}