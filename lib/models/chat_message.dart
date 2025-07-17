import 'dart:typed_data';
import 'server_message.dart';
import 'user_message.dart';

enum ChatMessageType {
  textMd,
  system,
  attachment,
}

class ChatMessage {
  final String id;
  final bool isUser;
  final ChatMessageType type;
  final dynamic body;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.type,
    required this.body,
  });

  /// Единая фабрика для сообщений от пользователя (текст + вложение)
  factory ChatMessage.fromUser(UserMessage msg) {
    if (msg.fileBytes != null) {
      // вложение + (опционально) текст
      return ChatMessage(
        id: msg.id,
        isUser: true,
        type: ChatMessageType.attachment,
        body: {
          'bytes': msg.fileBytes,
          'name': msg.fileName,
          'mime': msg.mimeType,
          'text': msg.text,      // сохраняем и текст, если был введён
        },
      );
    } else {
      // просто текст
      return ChatMessage(
        id: msg.id,
        isUser: true,
        type: ChatMessageType.textMd,
        body: msg.text,
      );
    }
  }

  /// Фабрика для сообщений от сервера (осталось без изменений)
 factory ChatMessage.fromServer(ServerMessage serverMsg) {
    if (serverMsg is TextMessage) {
      return ChatMessage(
        id: serverMsg.id,
        isUser: false,
        type: ChatMessageType.textMd,
        body: serverMsg.text,
      );
    } else if (serverMsg is TypingMessage) {
      return ChatMessage(
        id: 'typing-${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        type: ChatMessageType.system,
        body: '🤖 Печатает...',
      );
    } else if (serverMsg is ErrorMessage) {
      return ChatMessage(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        type: ChatMessageType.system,
        body: '⚠️ Ошибка: ${serverMsg.message}',
      );
    } else if (serverMsg is DoneMessage) {
      // Можно проигнорировать или отобразить системно
      return ChatMessage(
        id: 'done-${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        type: ChatMessageType.system,
        body: '✅ Ответ завершён',
      );
    }

    throw Exception('Unknown ServerMessage type');
  }
  Map<String, dynamic> toJson() {
    final base = {
      'id': id,
      'isUser': isUser,
      'type': type.name,
    };

    if (type == ChatMessageType.attachment && body is Map) {
      final map = body as Map<String, dynamic>;
      base.addAll({
        'name': map['name'],
        'mime': map['mime'],
        'text': map['text'],
        // байты в list<int> для JSON
        'data': (map['bytes'] as Uint8List).toList(),
      });
    } else {
      base['body'] = body;
    }
    return base;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final type = ChatMessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ChatMessageType.textMd,
    );

    if (type == ChatMessageType.attachment) {
      final dataList = List<int>.from(json['data'] as List<dynamic>);
      return ChatMessage(
        id: json['id'] ?? '',
        isUser: json['isUser'] ?? false,
        type: type,
        body: {
          'name': json['name'],
          'mime': json['mime'],
          'text': json['text'] ?? '',
          'bytes': Uint8List.fromList(dataList),
        },
      );
    }

    return ChatMessage(
      id: json['id'] ?? '',
      isUser: json['isUser'] ?? false,
      type: type,
      body: json['body'],
    );
  }
}
