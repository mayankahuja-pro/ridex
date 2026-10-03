import 'package:flutter/material.dart';

import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants/api_constants.dart';
import 'ratingScreen.dart';
class RideCompletedScreen extends StatefulWidget {
  final Ride ride;

  const RideCompletedScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideCompletedScreen> createState() =>
      _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {

  bool isPaying = false;

  final ApiService apiService =
      ApiService();

  final AuthService authService =
      AuthService();

  Future<void> payNow() async {
    setState(() {
      isPaying = true;
    });

    try {
      final token =
          await authService.getToken();

      final response =
          await apiService.post(
        "${ApiConstants.payments}/${widget.ride.id}/pay",
        {
          "method": "cash",
        },
        token: token,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RatingScreen(
              ride: widget.ride,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Payment failed",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isPaying = false;
        });
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Ride Completed",
      ),
      automaticallyImplyLeading: false,
    ),

    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.check_circle,
            size: 90,
          ),

          const SizedBox(height: 24),

          const Text(
            "Ride Completed!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Total Fare",
            style: TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "₹${widget.ride.fare.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  isPaying ? null : payNow,
              child: isPaying
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Pay & Continue",
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}}