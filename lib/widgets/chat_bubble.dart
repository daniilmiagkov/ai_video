import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

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

    // 1) Если пришёл video-сообщение с url
    if (message.type == ChatMessageType.attachment &&
        message.body is Map<String, dynamic> &&
        (message.body as Map).containsKey('url')) {
      final body = message.body as Map<String, dynamic>;
      final url = body['url'] as String;
      final label = body['text'] as String? ?? 'Скачать';

      content = ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: Text(label, style: TextStyle(color: textColor)),
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: bgColor,
        ),
        onPressed: () async {
          debugPrint('🔗 Attempting to open URL: $url');
          final uri = Uri.parse(url);
          // Для Web
          if (await canLaunchUrl(uri)) {
            // Для Web можно открыть в новой вкладке:
            await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: '_blank',
            );
            debugPrint('✅ Launched $url');
          } else {
            debugPrint('❌ Cannot launch $url');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось открыть ссылку: $url')),
            );
          }
        },
      );
    }
    // 2) Обычный текст (markdown)
    else if (message.type != ChatMessageType.attachment) {
      content = MarkdownBody(
        data: message.body.toString(),
        styleSheet: MarkdownStyleSheet.fromTheme(
          Theme.of(context),
        ).copyWith(p: TextStyle(color: textColor)),
        onTapLink: (text, href, title) {
          if (href != null) {
            debugPrint('🔗 Markdown link tapped: $href');
            final uri = Uri.parse(href);
            launchUrl(uri); // без await — для простоты
          }
        },
      );
    }
    // 3) Вложение-бинарник (без видео-ссылки)
    else {
      // ... ваша существующая логика показа Image/иконки и текста ...
      content = Text('[Attachment]', style: TextStyle(color: textColor));
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
