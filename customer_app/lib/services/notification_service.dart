import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      print("FCM TOKEN: $token");

      await sendTokenToBackend(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        print("FCM TOKEN REFRESHED: $newToken");

        await sendTokenToBackend(newToken);
      },
    );
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> sendTokenToBackend(
    String token,
  ) async {
    // API call yahan karenge
  }
}