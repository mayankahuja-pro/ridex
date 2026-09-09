import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';

 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const RideXApp());
}

class RideXApp extends StatelessWidget {
  const RideXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text("RideX"),
        ),
      ),
    );
  }
}