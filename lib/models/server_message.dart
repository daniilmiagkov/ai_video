enum ServerMessageType {
  text,
  typing,
  error,
  done,
}

abstract class ServerMessage {
  final ServerMessageType type;

  ServerMessage(this.type);

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] ?? 'text';

    switch (typeStr) {
      case 'text':
        return TextMessage(
          id: json['id'] ?? '',
          text: json['text'] ?? '',
        );
      case 'typing':
        return TypingMessage();
      case 'error':
        return ErrorMessage(message: json['message'] ?? 'Unknown error');
      case 'done':
        return DoneMessage();
      default:
        throw Exception('Unknown server message type: $typeStr');
    }
  }
}

class TextMessage extends ServerMessage {
  final String id;
  final String text;

  TextMessage({required this.id, required this.text}) : super(ServerMessageType.text);
}

class TypingMessage extends ServerMessage {
  TypingMessage() : super(ServerMessageType.typing);
}

class ErrorMessage extends ServerMessage {
  final String message;

  ErrorMessage({required this.message}) : super(ServerMessageType.error);
}

class DoneMessage extends ServerMessage {
  DoneMessage() : super(ServerMessageType.done);
}



