import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

class ChatState {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessageStreamingUseCase _sendStreaming;
  final GetChatHistoryUseCase _getHistory;
  final Uuid _uuid = const Uuid();

  ChatNotifier(
    this._sendStreaming,
    this._getHistory,
  ) : super(const ChatState());

  Future<void> loadHistory(String userId) async {
    state = state.copyWith(isLoading: true);

    final result = await _getHistory(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (messages) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> sendMessage({
    required String text,
    String? productContext,
  }) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageEntity(
      id: _uuid.v4(),
      text: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
      productId: productContext,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    final modelMessageId = _uuid.v4();

    final streamingMessage = ChatMessageEntity(
      id: modelMessageId,
      text: '',
      role: MessageRole.model,
      timestamp: DateTime.now(),
      isStreaming: true,
      productId: productContext,
    );

    state = state.copyWith(
      messages: [...state.messages, streamingMessage],
    );

    final params = SendMessageParams(
      message: text.trim(),
      productContext: productContext,
    );

    var accumulated = '';

    await for (final chunk in _sendStreaming(params)) {
      chunk.fold(
        (failure) {
          final updatedMessages = state.messages.map((message) {
            if (message.id == modelMessageId) {
              return message.copyWith(
                text: 'Error: ${failure.message}',
                isStreaming: false,
              );
            }

            return message;
          }).toList();

          state = state.copyWith(
            messages: updatedMessages,
            isLoading: false,
            error: failure.message,
          );
        },
        (token) {
          accumulated += token;

          final updatedMessages = state.messages.map((message) {
            if (message.id == modelMessageId) {
              return message.copyWith(text: accumulated);
            }

            return message;
          }).toList();

          state = state.copyWith(
            messages: updatedMessages,
            error: null,
          );
        },
      );
    }

    final finalMessages = state.messages.map((message) {
      if (message.id == modelMessageId) {
        return message.copyWith(isStreaming: false);
      }

      return message;
    }).toList();

    state = state.copyWith(
      messages: finalMessages,
      isLoading: false,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ChatState();
    sl<AiChatRepository>().resetSession();
  }
}

final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) {
    return ChatNotifier(
      sl<SendMessageStreamingUseCase>(),
      sl<GetChatHistoryUseCase>(),
    );
  },
);