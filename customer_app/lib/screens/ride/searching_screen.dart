import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/ride.dart';
import '../../services/websocket_service.dart';
import 'ride_tracking_screen.dart';

class SearchingScreen extends StatefulWidget {
  final Ride ride;

  const SearchingScreen({
    super.key,
    required this.ride,
  });

  @override
  State<SearchingScreen> createState() =>
      _SearchingScreenState();
}

class _SearchingScreenState
    extends State<SearchingScreen> {

  final WebSocketService _webSocketService =
      WebSocketService();

  StreamSubscription<Map<String, dynamic>>?
      _subscription;

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    _webSocketService.connect(
      widget.ride.customerId,
    );

    _subscription =
        _webSocketService.messages?.listen(
      handleMessage,
    );
  }

  void handleMessage(
    Map<String, dynamic> message,
  ) {
    print("WebSocket message: $message");

    if (message["type"] == "ride_accepted") {
      final status = message["status"];

      if (status == "accepted") {
        openTrackingScreen();
      }

      if (status == "cancelled") {
        showCancelledMessage();
      }
    }
  }

  void openTrackingScreen() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RideTrackingScreen(
          ride: widget.ride,
        ),
      ),
    );
  }

  void showCancelledMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "No driver accepted the ride",
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finding Driver"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),

              const SizedBox(height: 32),

              const Text(
                "Finding your driver...",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Searching nearby drivers",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "Estimated Fare: "
                "₹${widget.ride.fare.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}