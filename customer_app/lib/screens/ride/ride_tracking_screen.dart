import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/websocket_service.dart';

class RideTrackingScreen extends StatefulWidget {
  final Ride ride;
  final String? initialStatus;

  const RideTrackingScreen({
    super.key,
    required this.ride,
    this.initialStatus,
  });

  @override
  State<RideTrackingScreen> createState() =>
      _RideTrackingScreenState();
}

class _RideTrackingScreenState
    extends State<RideTrackingScreen> {

  final WebSocketService _webSocketService =
      WebSocketService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  StreamSubscription<Map<String, dynamic>>?
      _subscription;

  late String rideStatus;

  @override
  void initState() {
    super.initState();

    rideStatus = widget.initialStatus ?? widget.ride.status;

    connectWebSocket();
  }

  Future<void> connectWebSocket() async {
    debugPrint("Connecting WebSocket...");

    _webSocketService.connect(widget.ride.customerId);

    _subscription = _webSocketService.messages?.listen(
      (message) {
        debugPrint("MESSAGE RECEIVED ON SCREEN: $message");

        handleMessage(message);
      },
    );

    await refreshRideStatus();
  }

  Future<void> refreshRideStatus() async {
    final token = await _authService.getToken();
    if (token == null) return;

    final response = await _apiService.get(
      "${ApiConstants.rides}/${widget.ride.id}",
      token: token,
    );

    if (!mounted || response.statusCode != 200) return;

    final ride = Ride.fromJson(jsonDecode(response.body));
    setState(() {
      rideStatus = ride.status;
    });
  }


  void handleMessage(
    Map<String, dynamic> message,
  ) {
    final messageType = message["type"];

    if (messageType != "ride_accepted" &&
        messageType != "ride_status") {
      return;
    }

    if (int.tryParse(message["ride_id"].toString()) !=
        widget.ride.id) {
      return;
    }

    final status = message["status"]?.toString();
    if (status == null) return;

    if (!mounted) return;

    setState(() {
      rideStatus = status;
    });

    debugPrint("Ride status: $status");
  }

  String getStatusTitle() {
    switch (rideStatus) {
      case "accepted":
        return "Driver Accepted";

      case "arriving":
        return "Driver is Arriving";

      case "arrived":
        return "Driver Has Arrived";

      case "started":
        return "Ride Started";

      case "completed":
        return "Ride Completed";

      case "cancelled":
        return "Ride Cancelled";

      default:
        return "Searching for Driver";
    }
  }

  IconData getStatusIcon() {
    switch (rideStatus) {
      case "accepted":
        return Icons.check_circle;

      case "arriving":
        return Icons.two_wheeler;

      case "arrived":
        return Icons.location_on;

      case "started":
        return Icons.navigation;

      case "completed":
        return Icons.flag;

      case "cancelled":
        return Icons.cancel;

      default:
        return Icons.search;
    }
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
        title: Text("Ride #${widget.ride.id}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 40),

            Icon(
              getStatusIcon(),
              size: 80,
            ),

            const SizedBox(height: 24),

            Text(
              getStatusTitle(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Status: $rideStatus",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            RideStatusTimeline(
              currentStatus: rideStatus,
            ),

            const Spacer(),

            Text(
              "Fare: ₹${widget.ride.fare.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    
  }
}


class RideStatusTimeline extends StatelessWidget {
  final String currentStatus;

  const RideStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  final List<String> statuses = const [
    "accepted",
    "arriving",
    "arrived",
    "started",
    "completed",
  ];

  String getLabel(String status) {
    switch (status) {
      case "accepted":
        return "Driver Accepted";

      case "arriving":
        return "Driver Arriving";

      case "arrived":
        return "Driver Arrived";

      case "started":
        return "Ride Started";

      case "completed":
        return "Ride Completed";

      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        statuses.indexOf(currentStatus);

    return Column(
      children: List.generate(
        statuses.length,
        (index) {
          final isCompleted =
              currentIndex >= index;

          return Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),

              const SizedBox(width: 12),

              Text(
                getLabel(statuses[index]),
              ),
            ],
          );
        },
      ),
    );
  }
}