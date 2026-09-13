import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  StreamSubscription<Map<String, dynamic>>? _subscription;

  late String rideStatus;

  LatLng? driverLocation;

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
      onError: (error) {
        debugPrint("WebSocket error: $error");
      },
    );

    await refreshRideStatus();
  }

  Future<void> refreshRideStatus() async {
    try {
      final token = await _authService.getToken();

      if (token == null) return;

      final response = await _apiService.get(
        "${ApiConstants.rides}/${widget.ride.id}",
        token: token,
      );

      if (!mounted || response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);

      final ride = Ride.fromJson(decoded);

      if (!mounted) return;

      setState(() {
        rideStatus = ride.status;
      });
    } catch (e) {
      debugPrint("Failed to refresh ride status: $e");
    }
  }

  void handleMessage(Map<String, dynamic> message) {
    final messageType = message["type"];

    // ------------------------------------------------------------
    // Driver live location
    // ------------------------------------------------------------
    if (messageType == "driver_location") {
      final rideId = int.tryParse(
        message["ride_id"]?.toString() ?? "",
      );

      if (rideId != null && rideId != widget.ride.id) {
        return;
      }

      final latitudeValue = message["latitude"];
      final longitudeValue = message["longitude"];

      if (latitudeValue == null || longitudeValue == null) {
        return;
      }

      final latitude = double.tryParse(
        latitudeValue.toString(),
      );

      final longitude = double.tryParse(
        longitudeValue.toString(),
      );

      if (latitude == null || longitude == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        driverLocation = LatLng(
          latitude,
          longitude,
        );
      });

      debugPrint(
        "Driver location updated: $latitude, $longitude",
      );

      return;
    }

    // ------------------------------------------------------------
    // Ride status
    // ------------------------------------------------------------
    if (messageType != "ride_accepted" &&
        messageType != "ride_status") {
      return;
    }

    final rideId = int.tryParse(
      message["ride_id"]?.toString() ?? "",
    );

    if (rideId != widget.ride.id) {
      return;
    }

    final status = message["status"]?.toString();

    if (status == null || status.isEmpty) {
      return;
    }

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
    final pickupLocation = LatLng(
      widget.ride.pickupLat,
      widget.ride.pickupLng,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Ride #${widget.ride.id}"),
      ),
      body: Column(
        children: [
          // ------------------------------------------------------
          // MAP
          // ------------------------------------------------------
          Expanded(
            flex: 5,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: pickupLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ridex.customer',
                ),

                MarkerLayer(
                  markers: [
                    // Pickup marker
                    Marker(
                      point: pickupLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),

                    // Live driver marker
                    if (driverLocation != null)
                      Marker(
                        point: driverLocation!,
                        width: 55,
                        height: 55,
                        child: const Icon(
                          Icons.two_wheeler,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // RIDE STATUS
          // ------------------------------------------------------
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Icon(
                    getStatusIcon(),
                    size: 60,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    getStatusTitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Status: $rideStatus",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (driverLocation != null)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 10,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Driver location is live",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  if (driverLocation == null)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Waiting for driver location...",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  RideStatusTimeline(
                    currentStatus: rideStatus,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Fare: ₹${widget.ride.fare.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
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

  static const List<String> statuses = [
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
    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      children: List.generate(
        statuses.length,
        (index) {
          final isCompleted = currentIndex >= index;
          final isLast = index == statuses.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted
                        ? Colors.green
                        : Colors.grey,
                  ),

                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: currentIndex > index
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                ],
              ),

              const SizedBox(width: 12),

              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  getLabel(statuses[index]),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isCompleted
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
