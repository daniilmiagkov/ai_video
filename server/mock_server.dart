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
    print('🔌 Client connected');

    // Приветственное сообщение
    socket.add(jsonEncode({
      'type': 'text',
      'id': 'assistant-welcome',
      'text': '👋 **Привет!** Добро пожаловать.\n'
              '> Отправьте текст и/или вложения.',
    }));

    socket.listen((raw) async {
      print('⬅️ Raw length: ${(raw as String).length}');
      Map<String, dynamic> msg;
      try {
        msg = jsonDecode(raw);
      } catch (e) {
        socket.add(jsonEncode({'type': 'error', 'message': 'Invalid JSON'}));
        return;
      }

      // Если пришли вложения
      if (msg['type'] == 'attachment') {
        final text = (msg['text'] as String?)?.trim() ?? '';
        final atts = (msg['attachments'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];

        print('📩 Received text="$text", attachments=${atts.length}');

        final buffer = StringBuffer()
          ..writeln('### Обработка вложений (${atts.length}):');

        for (var a in atts) {
          final name = a['name'] as String? ?? 'file';
          final mime = a['mime'] as String? ?? 'application/octet-stream';
          final dataB64 = a['data'] as String? ?? '';
          late List<int> bytes;
          try {
            bytes = base64Decode(dataB64);
          } catch (_) {
            bytes = [];
          }
          buffer.writeln('- **$name** (`$mime`) — ${bytes.length} байт');
          print('   • $name: ${bytes.length} bytes');
        }

        if (text.isNotEmpty) {
          buffer.writeln('\n**Текст:** $text');
        }

        // Отправляем результат
        socket.add(jsonEncode({
          'type': 'text',
          'id': 'assistant-${DateTime.now().millisecondsSinceEpoch}',
          'text': buffer.toString(),
        }));
        socket.add(jsonEncode({'type': 'done'}));
        return;
      }

      // Обычное текстовое сообщение
      final userText = (msg['text'] as String?) ?? '';
      print('💬 Text: $userText');
      socket.add(jsonEncode({'type': 'typing'}));
      await Future.delayed(Duration(milliseconds: 500 + random.nextInt(500)));

      socket.add(jsonEncode({
        'type': 'text',
        'id': 'assistant-${DateTime.now().millisecondsSinceEpoch}',
        'text': 'Ваш запрос: **$userText** — обработан.',
      }));
      socket.add(jsonEncode({'type': 'done'}));
    },
    onError: (e) => print('❌ WS error: $e'),
    onDone: () => print('🔒 Disconnected'),
    cancelOnError: true);
  }
}
