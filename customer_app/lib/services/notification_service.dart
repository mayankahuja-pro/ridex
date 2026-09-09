import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _requestPermission();

    final token = await _messaging.getToken();

    print("FCM TOKEN: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) {
        print("NEW FCM TOKEN: $newToken");
      },
    );
  }

  Future<void> _requestPermission() async {
    final settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
      "Notification permission: "
      "${settings.authorizationStatus}",
    );
  }
}