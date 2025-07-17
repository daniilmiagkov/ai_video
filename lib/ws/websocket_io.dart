import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel createWebSocket(String url) {
  return IOWebSocketChannel.connect(Uri.parse(url));
}
