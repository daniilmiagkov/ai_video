import 'server_message.dart';
import 'user_message.dart';

enum ChatMessageType {
  textMd,
  image,
  system,
  // можно позже добавить: code, video, file, etc.
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

  /// Создание из `UserMessage` (отправка пользователем)
  factory ChatMessage.fromUser(UserMessage userMsg) {
    return ChatMessage(
      id: userMsg.id,
      isUser: true,
      type: ChatMessageType.textMd,
      body: userMsg.text,
    );
  }

  /// Создание из `ServerMessage` (ответ сервера)
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
    return {
      'id': id,
      'isUser': isUser,
      'type': type.name,
      'body': body,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      isUser: json['isUser'] ?? false,
      type: ChatMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatMessageType.textMd,
      ),
      body: json['body'],
    );
  }
}
