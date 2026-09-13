import 'package:firebase_messaging/firebase_messaging.dart';

import 'api_service.dart';
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    await _requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      print("FCM TOKEN: $token");

      await sendTokenToBackend(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        print("NEW FCM TOKEN: $newToken");

        await sendTokenToBackend(newToken);
      },
    );
  }

  Future<void> sendTokenToBackend(String token) async {
    final jwt = await _authService.getToken();

    if (jwt == null) {
      return;
    }

    final response = await _apiService.post(
      ApiConstants.fcmToken,
      {
        "token": token,
      },
      token: jwt,
    );

    print(
      "FCM token upload status: ${response.statusCode}",
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