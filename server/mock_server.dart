import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() async {
  final random = Random();
  final server = await HttpServer.bind('0.0.0.0', 8080);
  print('🚀 WebSocket mock server listening on ws://localhost:8080');

  await for (var request in server) {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
      continue;
    }

    final socket = await WebSocketTransformer.upgrade(request);
    print('🔌 Client connected from ${request.connectionInfo?.remoteAddress.address}');

    // Приветственное сообщение
    final welcome = {
      'type': 'text',
      'id': 'assistant-welcome',
      'text': '''
👋 **Привет!** Добро пожаловать в чат.

> Я здесь, чтобы помочь вам с любыми вопросами.

**Попробуйте отправить текст или вложение — и я отвечу!**
'''
    };
    socket.add(jsonEncode(welcome));
    print('➡️ Sent welcome message');

    socket.listen(
      (data) {
        print('⬅️ Raw data received: ${data.runtimeType}, length: ${data.toString().length}');
        Map<String, dynamic> msg;
        try {
          msg = jsonDecode(data as String) as Map<String, dynamic>;
        } catch (e) {
          print('❌ JSON decode error: $e');
          socket.add(jsonEncode({
            'type': 'error',
            'message': 'Invalid JSON',
          }));
          return;
        }

        // Если вложение приходит как Base64
        if (msg['type'] == 'attachment') {
          final name = msg['fileName'] ?? 'file';
          final mime = msg['mimeType'] ?? 'application/octet-stream';
          final b64 = msg['data'] as String? ?? '';
          List<int> bytes;
          try {
            bytes = base64Decode(b64);
          } catch (e) {
            print('❌ Base64 decode error: $e');
            socket.add(jsonEncode({
              'type': 'error',
              'message': 'Invalid attachment data',
            }));
            return;
          }
          final size = bytes.length;
          print('📩 Attachment: name=$name, mime=$mime, size=$size bytes');

          // Ответ о файле
          final reply = {
            'type': 'text',
            'id': 'assistant-${DateTime.now().millisecondsSinceEpoch}',
            'text': '''
### Вложение получено
- **Имя файла:** $name  
- **MIME‑тип:** $mime  
- **Размер:** $size байт  

_Файл успешно загружен!_ 🎉
'''
          };
          socket.add(jsonEncode(reply));
          print('➡️ Sent attachment info');
          socket.add(jsonEncode({'type': 'done'}));
          print('➡️ Sent done after attachment');
          return;
        }

        // Обычное текстовое сообщение
        final userText = msg['text']?.toString().trim() ?? '';
        print('📩 Text message: "$userText"');

        socket.add(jsonEncode({'type': 'typing'}));
        print('➡️ Sent typing');

        Future.delayed(Duration(milliseconds: 400 + random.nextInt(600)), () {
          final templates = [
            () => '''
#### Ваш запрос
> **$userText**

Вот мой короткий ответ: **жирным**, _курсив_, [ссылка](https://example.com).
''',
            () => '''
**Шаги по теме «$userText»:**
1. Шаг **1**  
2. Шаг _2_  
3. ✔️ Завершено
''',
            () => '''
```json
{
  "request": "$userText",
  "status": "ok",
  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"
}
'''
];
      final responseText = templates[random.nextInt(templates.length)]();
final reply = {
'type': 'text',
'id': 'assistant-${DateTime.now().millisecondsSinceEpoch}',
'text': responseText,
};
socket.add(jsonEncode(reply));
print('➡️ Sent text reply');
socket.add(jsonEncode({'type': 'done'}));
print('➡️ Sent done');
});
},
onError: (err) {
print('❌ WebSocket error: $err');
},
onDone: () {
print('🔒 Client disconnected');
},
cancelOnError: true,
);
}
}