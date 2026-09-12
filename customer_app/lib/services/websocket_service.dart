import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>>? get messages =>
      _channel?.stream.map(
        (message) =>
            jsonDecode(message) as Map<String, dynamic>,
      );

  void connect(int userId) {
    _channel = WebSocketChannel.connect(
      Uri.parse(
        "ws://10.0.2.2:8000/ws/$userId",
      ),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}