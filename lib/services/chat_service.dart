import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../models/server_message.dart';
import '../models/user_message.dart';

// Импортируем кроссплатформенную функцию создания канала
import '../ws/websocket_platform.dart';

class ChatService {
  final String url;
  late final WebSocketChannel _channel;

  final _controller = StreamController<ServerMessage>.broadcast();
  Stream<ServerMessage> get messages => _controller.stream;

  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  void Function(Object error)? onError;

  ChatService(this.url) {
    _connect();
  }

  void _connect() {
    try {
      _channel = createWebSocket(url); // ✅ кроссплатформенный канал

      onConnected?.call();

      _channel.stream.listen(
        (data) {
          try {
            final jsonMap = jsonDecode(data);
            final msg = ServerMessage.fromJson(jsonMap);
            _controller.add(msg);
          } catch (e) {
            onError?.call(e);
          }
        },
        onDone: () => onDisconnected?.call(),
        onError: (err) => onError?.call(err),
      );
    } catch (e) {
      onError?.call(e);
    }
  }

  void sendUserMessage(UserMessage msg) {
    try {
      _channel.sink.add(jsonEncode(msg.toJson()));
    } catch (e) {
      onError?.call(e);
    }
  }

  void dispose() {
    _channel.sink.close(status.goingAway);
    _controller.close();
  }
}
