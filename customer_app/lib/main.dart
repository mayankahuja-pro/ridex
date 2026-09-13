import 'package:customer_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/notification_service.dart';

import 'core/theme/app_theme.dart';
// import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const RideXApp());

  if (!kIsWeb) {
    await Firebase.initializeApp();

    final notificationService = NotificationService();
    await notificationService.initialize();
  }
}

class RideXApp extends StatelessWidget {
  const RideXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "RideX",
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
