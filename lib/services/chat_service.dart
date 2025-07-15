import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatService {
  // Placeholder: in real case, connect to API/WebSocket
  Future<ChatMessage> sendMessage(
      ChatSession session, String text) async {
    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
    );
    session.messages.add(userMsg);

    // Simulate assistant response
    await Future.delayed(const Duration(seconds: 1));
    final botMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: 'This is a simulated response to "\$text"',
      isUser: false,
    );
    session.messages.add(botMsg);

    return botMsg;
  }
}