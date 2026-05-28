import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/ai_chat_repository.dart';

class SendMessageParams {
  final String message;
  final String? productContext;

  const SendMessageParams({
    required this.message,
    this.productContext,
  });
}

class SendMessageStreamingUseCase {
  final AiChatRepository repository;

  const SendMessageStreamingUseCase(this.repository);

  Stream<Either<Failure, String>> call(SendMessageParams params) {
    return repository.sendMessageStreaming(
      message: params.message,
      productContext: params.productContext,
    );
  }
}

class SendMessageUseCase {
  final AiChatRepository repository;

  const SendMessageUseCase(this.repository);

  Future<Either<Failure, ChatMessageEntity>> call(
    SendMessageParams params,
  ) {
    return repository.sendMessage(
      message: params.message,
      productContext: params.productContext,
    );
  }
}