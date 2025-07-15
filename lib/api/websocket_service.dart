import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import '../models/server_message.dart';
import '../models/user_message.dart';

class ChatService {
  final String url;
  WebSocket? _socket;

  // Поток для входящих сообщений
  final StreamController<ServerMessage> _messageController = StreamController.broadcast();
  Stream<ServerMessage> get messages => _messageController.stream;

  // Колбэки для событий
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  void Function(Object error)? onError;

  ChatService(this.url) {
    _connect();
  }

  Future<void> _connect() async {
    try {
      _socket = await WebSocket.connect(url);

      onConnected?.call();

      _socket!.listen(
        (data) {
          try {
            final Map<String, dynamic> json = jsonDecode(data);
            final msg = ServerMessage.fromJson(json);
            _messageController.add(msg);
          } catch (e) {
            onError?.call(e);
          }
        },
        onDone: () {
          onDisconnected?.call();
          _reconnect();
        },
        onError: (error) {
          onError?.call(error);
          _reconnect();
        },
      );
    } catch (e) {
      onError?.call(e);
      // Можно попытаться переподключиться позже
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      _connect();
    });
  }

  void sendUserMessage(UserMessage userMessage) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode(userMessage.toJson()));
    } else {
      onError?.call('WebSocket is not connected');
    }
  }

  void dispose() {
    _messageController.close();
    _socket?.close();
  }
}