import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants/api_constants.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({
    super.key,
  });

  @override
  State<DriverHomeScreen> createState() =>
      _DriverHomeScreenState();
}

class _DriverHomeScreenState
    extends State<DriverHomeScreen> {

  bool isOnline = false;

  final ApiService apiService =
      ApiService();

  final AuthService authService =
      AuthService();

Future<void> toggleOnline() async {
  final token = await authService.getToken();

  if (token == null) {
    // debugPrint("TOKEN IS NULL");
    return;
  }

  final newStatus = !isOnline;

  try {
    final response = await apiService.patch(
  "${ApiConstants.driverStatus}?is_online=$newStatus",
  {},
  token: token,
);

    // debugPrint("STATUS CODE: ${response.statusCode}");
    // debugPrint("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        isOnline = newStatus;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to update status (${response.statusCode})",
          ),
        ),
      );
    }
  } catch (e) {
    // debugPrint("STATUS UPDATE ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RideX Driver"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              Icons.two_wheeler,
              size: 90,
            ),

            const SizedBox(height: 20),

            Text(
              isOnline
                  ? "You are Online"
                  : "You are Offline",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Switch(
              value: isOnline,
              onChanged: (_) {
                toggleOnline();
              },
            ),

            const SizedBox(height: 10),

            Text(
              isOnline
                  ? "Waiting for ride requests..."
                  : "Go online to receive rides",
            ),
          ],
        ),
      ),
    );
  }
}