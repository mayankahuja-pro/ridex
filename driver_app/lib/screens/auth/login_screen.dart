// import 'package:customer_app/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../core/constants/api_constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../home/driver_home_screen.dart';
import 'dart:convert';

import '../../models/token_response.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final apiService = ApiService();
  final authService = AuthService();

  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.post(
        ApiConstants.login,
        {
          "phone": phoneController.text.trim(),
          "password": passwordController.text,
        },
      );

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);

  final tokenResponse =
      TokenResponse.fromJson(data);

  await authService.saveToken(
    tokenResponse.accessToken,
  );

  await NotificationService().initialize();

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const DriverHomeScreen(),
    ),
  );
} else {
        showError("Invalid phone or password");
      }
    } catch (e) {
      showError("Something went wrong");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "RideX",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Login"),
                ),
              ),
              const SizedBox(height: 12),

              // TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => const RegisterScreen(),
              //       ),
              //     );
              //   },
              //   child: const Text(
              //     "Create a new account",
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}