import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() async {
  final random = Random();
  final server = await HttpServer.bind('0.0.0.0', 8080);
  print('🚀 WebSocket mock server listening on ws://localhost:8080');

  await for (var request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);

      // Приветственное сообщение
      socket.add(jsonEncode({
        'type': 'text',
        'id': 'assistant-welcome',
        'text': '''
👋 **Привет!** Добро пожаловать в чат.

> Я здесь, чтобы помочь вам с любыми вопросами.

**Попробуйте написать что‑нибудь — и я отвечу замоканным Markdown.**
'''
      }));

      socket.listen((data) {
        final msg = jsonDecode(data as String);
        final userText = msg['text']?.toString().trim() ?? '';
        print('📩 User message: $userText');

        // Сигнал «печатает»
        socket.add(jsonEncode({'type': 'typing'}));

        // Эмулируем задержку
        Future.delayed(Duration(milliseconds: 400 + random.nextInt(600)), () {
          // Общие шаблоны Markdown‑ответов
          final templates = [
            () => '''
#### Ваш запрос
> **${userText}**

Вот мой короткий ответ с **жирным**, _курсивом_ и [ссылкой](https://example.com).
''',
            () => '''
**Список действий по теме "${userText}":**
1. Шаг **первый**  
2. Шаг _второй_  
3. **Завершение**

_Удачи!_ 🚀
''',
            () => '''
| Параметр        | Значение                      |
|-----------------|-------------------------------|
| Запрос          | `${userText}`                 |
| Время           | ${DateTime.now().toIso8601String()} |
| Случайное число | ${random.nextInt(100)}        |
''',
            () => '''
> "Это пример цитаты по теме **${userText}**."

- Пункт A  
- Пункт B  

**Конец цитаты**
''',
            () => '''
```json
{
  "request": "${userText}",
  "status": "ok",
  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"
}
Надеюсь, было полезно!
'''
];

      final responseText = templates[random.nextInt(templates.length)]();

      // Отправляем основной ответ
      socket.add(jsonEncode({
        'type': 'text',
        'id': 'assistant-${DateTime.now().millisecondsSinceEpoch}',
        'text': responseText,
      }));
      // Отправляем done
      socket.add(jsonEncode({'type': 'done'}));
    });
  });

} else {
  request.response
    ..statusCode = HttpStatus.forbidden
    ..close();
}
}
}