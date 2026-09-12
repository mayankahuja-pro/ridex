import 'package:flutter/material.dart';

import '../../models/ride.dart';

class RideTrackingScreen extends StatelessWidget {
  final Ride ride;

  const RideTrackingScreen({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Ride"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.two_wheeler,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              "Driver Found!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Ride #${ride.id}",
            ),
          ],
        ),
      ),
    );
  }
}