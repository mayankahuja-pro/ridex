
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/api_constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/websocket_service.dart';

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

  int? driverId;

  @override
  void initState() {
    super.initState();

    loadDriverProfile();
  }

  void stopLocationTracking() {
    locationSubscription?.cancel();
    locationSubscription = null;

    webSocketService.disconnect();
  }

  void startLocationTracking() {
    if (driverId == null) {
      return;
    }

    webSocketService.connect(driverId!);

    locationSubscription =
        locationService.getLocationStream().listen(
      (Position position) {
        debugPrint(
          "Driver Location: "
          "${position.latitude}, "
          "${position.longitude}",
        );

        webSocketService.sendDriverLocation(
          driverId: driverId!,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      },
    );
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

      if (token == null) return;

      final response = await apiService.get(
        ApiConstants.driverProfile,
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          driverId = data["id"];
          isOnline = data["is_online"] ?? false;
        });

        // If driver was already online when the screen loaded,
        // start location tracking.
        if (isOnline) {
          startLocationTracking();
        }
      }
    } catch (e) {
      debugPrint("Failed to load driver profile: $e");
    }
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    webSocketService.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RideX Driver"),
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
 
