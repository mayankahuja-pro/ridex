import 'dart:convert';
import '/core/constants/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>>? get messages =>
      _channel?.stream.map(
        (message) =>
            jsonDecode(message) as Map<String, dynamic>,
      );

  void connect(int userId) {
    final apiUri = Uri.parse(ApiConstants.baseUrl);
    final websocketScheme = switch (apiUri.scheme) {
      "https" => "wss",
      "http" => "ws",
      _ => throw ArgumentError(
          "API base URL must use http or https: ${apiUri.scheme}",
        ),
    };
    final websocketUri = apiUri.replace(
      scheme: websocketScheme,
      path: "/ws/$userId",
    );

    _channel = WebSocketChannel.connect(websocketUri);
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