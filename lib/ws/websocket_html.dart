import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel createWebSocket(String url) {
  return HtmlWebSocketChannel.connect(url);
}
