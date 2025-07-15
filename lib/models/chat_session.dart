// lib/models/chat_session.dart
import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}
