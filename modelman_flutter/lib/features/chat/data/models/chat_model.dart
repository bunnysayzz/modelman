import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

/// Role of a chat message participant.
enum ChatRole {
  user,
  assistant,
  system,
  tool,
  error,
}

/// A single message in the chat history.
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    required DateTime timestamp,
    String? toolName,
    Map<String, dynamic>? toolResult,
    @Default(false) bool isStreaming,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// State of the chat interface.
enum ChatStatus {
  idle,
  sending,
  streaming,
  error,
}
