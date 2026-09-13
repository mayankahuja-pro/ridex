import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(int userId) {
    _channel = WebSocketChannel.connect(
      Uri.parse(
        "ws://127.0.0.1:8000/ws/$userId",
      ),
    );
  }

  void sendDriverLocation({
    required int driverId,
    required double latitude,
    required double longitude,
  }) {
    if (_channel == null) {
      return;
    }

    _channel!.sink.add(
      jsonEncode({
        "type": "driver_location",
        "driver_id": driverId,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}