import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';  // ← импорт Markdown
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isSystem = message.type == ChatMessageType.system;

    final backgroundColor = isSystem
      ? Colors.grey.shade300
      : isUser
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade200;

    final textColor = isSystem
      ? Colors.black54
      : isUser
        ? Colors.white
        : Colors.black87;

    final alignment = isSystem
      ? Alignment.center
      : isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;

    final body = message.body?.toString() ?? '';

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: MarkdownBody(
          data: body,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TextStyle(color: textColor),
            // при необходимости можно настроить стили заголовков, ссылок и т.д.
          ),
        ),
      ),
    );
  }
}
