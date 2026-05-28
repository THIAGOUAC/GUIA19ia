import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/gemini_datasource.dart';
import '../models/chat_message_model.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final GeminiDataSource geminiDataSource;
  final FirebaseFirestore firestore;
  final Uuid uuid;

  AiChatRepositoryImpl({
    required this.geminiDataSource,
    required this.firestore,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Stream<Either<Failure, String>> sendMessageStreaming({
    required String message,
    String? productContext,
  }) async* {
    try {
      final stream = geminiDataSource.sendMessageStreaming(
        message: message,
        productContext: productContext,
      );

      await for (final chunk in stream) {
        yield Right(chunk);
      }
    } catch (e) {
      yield Left(AiChatFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String message,
    String? productContext,
  }) async {
    try {
      final text = await geminiDataSource.sendMessage(
        message: message,
        productContext: productContext,
      );

      final response = ChatMessageModel(
        id: uuid.v4(),
        text: text,
        role: MessageRole.model,
        timestamp: DateTime.now(),
        productId: productContext,
      );

      return Right(response);
    } catch (e) {
      return Left(AiChatFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory(
    String userId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();

      final messages = snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();

      return Right(messages);
    } catch (e) {
      return Left(FirestoreHistoryFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMessage({
    required String userId,
    required ChatMessageEntity message,
  }) async {
    try {
      final model = ChatMessageModel.fromEntity(message);

      await firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .doc(model.id)
          .set(model.toFirestore());

      return const Right(unit);
    } catch (e) {
      return Left(FirestoreHistoryFailure(message: e.toString()));
    }
  }

  @override
  void resetSession() {
    geminiDataSource.resetSession();
  }
}