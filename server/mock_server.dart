import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('0.0.0.0', 8080);
  print('🚀 WebSocket mock server listening on ws://localhost:8080');

  await for (var request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);

      socket.listen((data) {
        final msg = jsonDecode(data);
        final userText = msg['text'] ?? '';

        print('📩 User message: $userText');

        // typing
        socket.add(jsonEncode({'type': 'typing'}));

        // simulate delay
        Future.delayed(Duration(milliseconds: 800), () {
          final reply = {
            'type': 'text',
            'id': 'assistant-${DateTime.now().millisecondsSinceEpoch}',
            'text': '_Ответ на_: **$userText**\n\n(сгенерировано ботом)'
          };
          socket.add(jsonEncode(reply));
          socket.add(jsonEncode({'type': 'done'}));
        });
      });

      // welcome
      socket.add(jsonEncode({
        'type': 'text',
        'id': 'assistant-welcome',
        'text': '👋 Добро пожаловать в чат!',
      }));
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
    }
  }
}
