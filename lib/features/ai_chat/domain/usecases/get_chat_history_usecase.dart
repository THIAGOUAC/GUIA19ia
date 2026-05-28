import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/ai_chat_repository.dart';

class GetChatHistoryUseCase {
  final AiChatRepository repository;

  const GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call(String userId) {
    return repository.getChatHistory(userId);
  }
}