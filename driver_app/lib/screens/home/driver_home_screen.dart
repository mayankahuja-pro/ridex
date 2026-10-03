import 'dart:async';
import 'dart:convert';

import 'package:driver_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/api_constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/websocket_service.dart';
import '../ride/ride_request_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({
    super.key,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isOnline = false;

  final ApiService apiService = ApiService();
  final AuthService authService = AuthService();
  final LocationService locationService = LocationService();
  final WebSocketService webSocketService = WebSocketService();

  StreamSubscription<Position>? locationSubscription;

  StreamSubscription<Map<String, dynamic>>?
      webSocketSubscription;

  int? driverId;
  int? userId;

  @override
  void initState() {
    super.initState();

    loadDriverProfile();
  }

  void stopLocationTracking() {
    locationSubscription?.cancel();
    locationSubscription = null;

    webSocketSubscription?.cancel();
    webSocketSubscription = null;

    webSocketService.disconnect();
  }

  void startLocationTracking() {
  if (driverId == null) {
    debugPrint("❌ Cannot start WebSocket: driverId is null");
    return;
  }

  debugPrint("🟢 Starting WebSocket for driverId: $driverId");

  webSocketService.connect(userId!);


  debugPrint("🟢 WebSocket connect() called");

  listenToMessages();

  locationSubscription =
      locationService.getLocationStream().listen(
    (Position position) {
      debugPrint(
        "📍 Driver Location: "
        "${position.latitude}, "
        "${position.longitude}",
      );

      webSocketService.sendDriverLocation(
        driverId: driverId!,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    },
    onError: (error) {
      debugPrint("❌ Location stream error: $error");
    },
  );
}

void listenToMessages() {
  debugPrint("👂 Starting WebSocket message listener...");

  webSocketSubscription?.cancel();

  final messages = webSocketService.messages;

  if (messages == null) {
    debugPrint("❌ WebSocket messages stream is NULL");
    return;
  }

  debugPrint("✅ WebSocket messages stream exists");

  webSocketSubscription = messages.listen(
    (message) {
      debugPrint("📨 INCOMING WEBSOCKET MESSAGE:");
      debugPrint(message.toString());

      handleMessage(message);
    },
    onError: (error) {
      debugPrint("❌ WebSocket stream error: $error");
    },
    onDone: () {
      debugPrint("⚠️ WebSocket stream CLOSED");
    },
  );
}

void handleMessage(Map<String, dynamic> message) {
  debugPrint("🔵 handleMessage() called");
  debugPrint("🔵 Message: $message");
  debugPrint("🔵 Message type: ${message["type"]}");

  if (message["type"] == "ride_request") {
    debugPrint("🚕 RIDE REQUEST RECEIVED!");

    openRideRequest(message);
  } else {
    debugPrint("⚠️ Unknown WebSocket message type");
  }
}


  void openRideRequest(
    Map<String, dynamic> message,
  ) {
    if (!mounted) return;

    try {
      final pickup = message["pickup"];
      final destination = message["destination"];

      if (pickup is! Map<String, dynamic> ||
          destination is! Map<String, dynamic>) {
        debugPrint(
          "Invalid ride request location data: $message",
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RideRequestScreen(
            rideId: message["ride_id"],
            pickupLat:
                (pickup["lat"] as num).toDouble(),
            pickupLng:
                (pickup["lng"] as num).toDouble(),
            destinationLat:
                (destination["lat"] as num).toDouble(),
            destinationLng:
                (destination["lng"] as num).toDouble(),
            fare:
                (message["fare"] as num).toDouble(),
            expiresIn:
                message["expires_in"] ?? 10,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        "Failed to open ride request: $e",
      );
    }
  }

  Future<void> toggleOnline() async {
    final token = await authService.getToken();

    if (token == null) {
      return;
    }

    final newStatus = !isOnline;

    final hasPermission =
        await locationService.checkPermission();

    if (newStatus && !hasPermission) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission is required",
          ),
        ),
      );

      return;
    }

    try {
      final response = await apiService.patch(
        "${ApiConstants.driverStatus}?is_online=$newStatus",
        {},
        token: token,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          isOnline = newStatus;
        });

        if (newStatus) {
          startLocationTracking();
        } else {
          stopLocationTracking();
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Unable to update status (${response.statusCode})",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

 Future<void> loadDriverProfile() async {
  try {
    final token = await authService.getToken();

    if (token == null) {
      debugPrint("❌ Token is null");
      return;
    }

    debugPrint("🔵 Loading driver profile...");

    final response = await apiService.get(
      ApiConstants.driverProfile,
      token: token,
    );

    debugPrint("🔵 Profile status: ${response.statusCode}");
    debugPrint("🔵 Profile response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      debugPrint("🔵 Decoded profile: $data");
      debugPrint("🔵 Driver ID from API: ${data["id"]}");
      debugPrint("🔵 Driver ID type: ${data["id"].runtimeType}");

      if (!mounted) return;

      setState(() {
        userId = data["user_id"];
        driverId = data["id"];
        isOnline = data["is_online"] ?? false;
      });

      debugPrint("✅ driverId after setState: $driverId");
      debugPrint("✅ isOnline: $isOnline");

      if (isOnline) {
        startLocationTracking();
      }
    } else {
      debugPrint(
        "❌ Failed to load driver profile: ${response.statusCode}",
      );
    }
  } catch (e, stackTrace) {
    debugPrint("❌ Failed to load driver profile: $e");
    debugPrint("$stackTrace");
  }
}

  Future<void> logout() async {
    await AuthService().clearToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    webSocketSubscription?.cancel();

    webSocketService.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RideX Rider"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: logout,
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
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
