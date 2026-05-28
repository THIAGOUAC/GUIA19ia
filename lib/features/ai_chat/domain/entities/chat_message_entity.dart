import 'package:equatable/equatable.dart';

enum MessageRole {
  user,
  model,
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final bool isStreaming;
  final String? productId;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
    this.productId,
  });

  bool get isFromModel => role == MessageRole.model;

  bool get isNotEmpty => text.trim().isNotEmpty;

  ChatMessageEntity copyWith({
    String? text,
    bool? isStreaming,
  }) {
    return ChatMessageEntity(
      id: id,
      text: text ?? this.text,
      role: role,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      productId: productId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        role,
        timestamp,
        isStreaming,
        productId,
      ];
}