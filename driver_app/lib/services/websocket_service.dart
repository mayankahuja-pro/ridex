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
        "ws://127.0.0.1:8000/ws/$userId",
      ),
    );
  }

  void sendDriverLocation({
    required int driverId,
    required double latitude,
    required double longitude,
  }) {
    _channel?.sink.add(
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