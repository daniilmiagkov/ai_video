// lib/widgets/chat_bubble.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      // Обычный текст или системное сообщение
      content = MarkdownBody(
        data: message.body.toString(),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
            .copyWith(p: TextStyle(color: textColor)),
      );
    } else {
      // Вложение: body может быть Map с ключом "attachments" (множественные)
      final body = message.body as Map<String, dynamic>;

      if (body.containsKey('attachments')) {
        // Множественные вложения
        final atts = body['attachments'] as List<dynamic>;
        final List<Widget> widgets = [];

        for (var item in atts) {
          final map = item as Map<String, dynamic>;
          final mime = map['mime'] as String? ?? '';
          final name = map['name'] as String? ?? 'file';
          final bytes = map['bytes'] as Uint8List;

          Widget w;
          if (mime.startsWith('image/')) {
            w = Image.memory(bytes, width: 100, height: 100, fit: BoxFit.cover);
          } else {
            // Для видео, аудио, документов — просто иконка + имя
            final icon = mime.startsWith('video/')
                ? Icons.videocam
                : mime.startsWith('audio/')
                    ? Icons.audiotrack
                    : Icons.insert_drive_file;
            w = Row(
              children: [
                Icon(icon, color: textColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(name, style: TextStyle(color: textColor)),
                ),
              ],
            );
          }

          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: w,
          ));
        }

        // Если вместе с вложениями есть текст
        final txt = body['text'] as String?;
        if (txt != null && txt.isNotEmpty) {
          widgets.add(MarkdownBody(
            data: txt,
            styleSheet: MarkdownStyleSheet.fromTheme(context as ThemeData)
                .copyWith(p: TextStyle(color: textColor)),
          ));
        }

        content = Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: widgets,
        );
      } else {
        // Одиночное вложение (устаревшая схема)
        final mime = body['mime'] as String? ?? '';
        final name = body['name'] as String? ?? 'file';
        final bytes = body['bytes'] as Uint8List;

        if (mime.startsWith('image/')) {
          content = Image.memory(bytes, width: 200);
        } else {
          final icon = mime.startsWith('video/')
              ? Icons.videocam
              : mime.startsWith('audio/')
                  ? Icons.audiotrack
                  : Icons.insert_drive_file;
          content = Row(
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: TextStyle(color: textColor))),
            ],
          );
        }
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
