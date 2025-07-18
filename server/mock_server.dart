import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() async {
  final random = Random();
  final videoFile = File('assets/video.MOV');

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('🚀 Server running on http://localhost:8080');

  await for (var request in server) {
    final uri = request.uri;
    print('➡️ HTTP ${request.method} ${uri.path} from '
          '${request.connectionInfo!.remoteAddress.address}');

    // 1) GET /video.mp4
    if (request.method == 'GET' && uri.path == '/video.MOV') {
      if (await videoFile.exists()) {
        request.response.headers.contentType = ContentType('video', 'MOV');
        await request.response.addStream(videoFile.openRead());
        await request.response.close();
        print('📹 Served video to ${request.connectionInfo!.remoteAddress.address}');
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('File not found')
          ..close();
        print('❌ Video file not found');
      }
      continue;
    }

    // 2) WebSocket Upgrade
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      print('❌ Rejecting non-WebSocket request');
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
      continue;
    }

    final socket = await WebSocketTransformer.upgrade(request);
    final clientIp = request.connectionInfo!.remoteAddress.address;
    print('🔌 WS connected from $clientIp');

    // Hello
    socket.add(jsonEncode({
      'type': 'text',
      'id': 'assistant-welcome',
      'text': '👋 Привет! Напишите "video" чтобы получить файл.',
    }));

    socket.listen((raw) async {
      print('⬅️ WS from $clientIp: '
            '${(raw as String).substring(0, raw.length.clamp(0,200))}');

      Map<String, dynamic> msg;
      try {
        msg = jsonDecode(raw);
      } catch (e) {
        print('❌ JSON parse error: $e');
        socket.add(jsonEncode({'type':'error','message':'Invalid JSON'}));
        return;
      }

      final text = (msg['text'] as String?)?.trim().toLowerCase() ?? '';
      // Command "video"
      if (text == 'video' || text == 'видео') {
        String host;
if (Platform.isAndroid) {
  host = '10.0.2.2';        // эмулятор Android
} else {
  host = request.connectionInfo!.remoteAddress.address;
}

final videoUrl = 'http://$host:8080/video.mp4';
        print('🎞️ Sending video link to $clientIp: $videoUrl');
        socket.add(jsonEncode({
          'type': 'video',
          'id': 'assistant-video-${DateTime.now().millisecondsSinceEpoch}',
          'url': videoUrl,
          'text': 'Скачать видео: $videoUrl',
        }));
        socket.add(jsonEncode({'type':'done'}));
        return;
      }

      // Other branches...
      // (attachments, text) — как в вашем коде, с `print(...)` в начале каждой
      // ветки и перед каждым `socket.add(...)`
    },
    onDone:   () => print('🔒 WS disconnected from $clientIp'),
    onError:  (e) => print('❌ WS error from $clientIp: $e'),
    cancelOnError: true);
  }
}
