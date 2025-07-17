// lib/widgets/chat_bubble.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // common styling…
    final isUser = message.isUser;
    final isSystem = message.type == ChatMessageType.system;

    final bgColor = isSystem
      ? Colors.grey.shade300
      : isUser
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade200;

    final textColor = isUser ? Colors.white : Colors.black87;
    final alignment = isSystem
      ? Alignment.center
      : isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;

    Widget content;
    if (message.type != ChatMessageType.attachment) {
      content = MarkdownBody(
          data: message.body.toString(),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
              .copyWith(p: TextStyle(color: textColor)),
        );
    } else {
        final body = message.body as Map;
        final mime = (body['mime'] as String);
        final name = body['name'] as String;
        final bytes = body['bytes'] as Uint8List;

        if (mime.startsWith('image/')) {
          content = Image.memory(bytes, width: 200);
        } else if (mime.startsWith('video/')) {
          content = Row(
            children: [
              const Icon(Icons.videocam),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: TextStyle(color: textColor))),
            ],
          );
        } else if (mime.startsWith('audio/')) {
          content = Row(
            children: [
              const Icon(Icons.audiotrack),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: TextStyle(color: textColor))),
            ],
          );
        } else {
          content = Row(
            children: [
              const Icon(Icons.insert_drive_file),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: TextStyle(color: textColor))),
            ],
          );
        }
      }
       

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }
}
