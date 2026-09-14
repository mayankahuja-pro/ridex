import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'active_ride_screen.dart';

class RideRequestScreen extends StatefulWidget {
  final int rideId;

  final double pickupLat;
  final double pickupLng;

  final double destinationLat;
  final double destinationLng;

  final double fare;
  final int expiresIn;

  const RideRequestScreen({
    super.key,
    required this.rideId,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.fare,
    required this.expiresIn,
  });

  @override
  State<RideRequestScreen> createState() =>
      _RideRequestScreenState();
}

class _RideRequestScreenState
    extends State<RideRequestScreen> {

  late int secondsLeft;

  Timer? timer;

  bool isLoading = false;

  final ApiService apiService =
      ApiService();

  final AuthService authService =
      AuthService();

  @override
  void initState() {
    super.initState();

    secondsLeft = widget.expiresIn;

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (secondsLeft <= 1) {
          timer?.cancel();

          if (mounted) {
            Navigator.pop(context);
          }

          return;
        }

        if (mounted) {
          setState(() {
            secondsLeft--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> acceptRide() async {
  setState(() {
    isLoading = true;
  });

  try {
    final token =
        await authService.getToken();

    final response =
        await apiService.post(
      "${ApiConstants.rides}/${widget.rideId}/accept",
      {},
      token: token,
    );

    if (response.statusCode == 200) {
      timer?.cancel();

      if (!mounted) return;

      final ride = Ride.fromJson(
        jsonDecode(response.body),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveRideScreen(
            ride: ride,
          ),
        ),
      );
    } else {
      final data =
          jsonDecode(response.body);

      showMessage(
        data["detail"] ??
            "Unable to accept ride",
      );
    }
  } catch (e) {
    showMessage(
      "Something went wrong",
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "New Ride Request",
      ),
      automaticallyImplyLeading: false,
    ),

    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 20),

          Center(
            child: Text(
              "$secondsLeft",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Center(
            child: Text(
              "seconds remaining",
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Pickup",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "${widget.pickupLat}, "
            "${widget.pickupLng}",
          ),

          const SizedBox(height: 24),

          const Text(
            "Destination",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "${widget.destinationLat}, "
            "${widget.destinationLng}",
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              "₹${widget.fare.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          timer?.cancel();
                          Navigator.pop(context);
                        },
                  child: const Text(
                    "Reject",
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : acceptRide,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Text(
                          "Accept",
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

}