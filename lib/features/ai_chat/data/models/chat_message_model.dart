import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.role,
    required super.timestamp,
    super.isStreaming,
    super.productId,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessageModel(
      id: doc.id,
      text: data['text'] as String? ?? '',
      role: (data['role'] as String? ?? 'model') == 'user'
          ? MessageRole.user
          : MessageRole.model,
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      productId: data['productId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'role': role == MessageRole.user ? 'user' : 'model',
      'timestamp': Timestamp.fromDate(timestamp),
      if (productId != null) 'productId': productId,
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      text: entity.text,
      role: entity.role,
      timestamp: entity.timestamp,
      isStreaming: entity.isStreaming,
      productId: entity.productId,
    );
  }

  factory ChatMessageModel.streaming(String partialText) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: partialText,
      role: MessageRole.model,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
  }
}