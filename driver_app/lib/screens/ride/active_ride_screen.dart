import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/api_constants.dart';
import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ActiveRideScreen extends StatefulWidget {
  final Ride ride;

  const ActiveRideScreen({
    super.key,
    required this.ride,
  });

  @override
  State<ActiveRideScreen> createState() =>
      _ActiveRideScreenState();
}

class _ActiveRideScreenState
    extends State<ActiveRideScreen> {

  late String rideStatus;

  final ApiService apiService =
      ApiService();

  final AuthService authService =
      AuthService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    rideStatus = widget.ride.status;
  }

  String getStatusText() {
    switch (rideStatus) {
      case "accepted":
        return "Ride Accepted";

      case "arriving":
        return "Going to Pickup";

      case "arrived":
        return "Driver Arrived";

      case "started":
        return "Ride In Progress";

      case "completed":
        return "Ride Completed";

      default:
        return rideStatus;
    }
  }
  String? getNextStatus() {
  switch (rideStatus) {
    case "accepted":
      return "arriving";

    case "arriving":
      return "arrived";

    case "arrived":
      return "started";

    case "started":
      return "completed";

    default:
      return null;
  }
}
String getButtonText() {
  switch (rideStatus) {
    case "accepted":
      return "Start Arriving";

    case "arriving":
      return "I've Arrived";

    case "arrived":
      return "Start Ride";

    case "started":
      return "Complete Ride";

    case "completed":
      return "Ride Completed";

    default:
      return "Unavailable";
  }
}

Future<void> updateRideStatus() async {
  final nextStatus = getNextStatus();

  if (nextStatus == null) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final token =
        await authService.getToken();

   final response = await apiService.patch(
  "${ApiConstants.rides}/${widget.ride.id}/status?new_status=$nextStatus",
  {},
  token: token,
);

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      final updatedRide =
          Ride.fromJson(data);

      if (!mounted) return;

      setState(() {
        rideStatus = updatedRide.status;
      });

      if (nextStatus == "completed") {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Ride completed successfully",
            ),
          ),
        );
      }
    } else {
      final data =
          jsonDecode(response.body);

      showMessage(
        data["detail"] ??
            "Unable to update ride",
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
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
Widget buildMap() {
  return FlutterMap(
    options: MapOptions(
      initialCenter: LatLng(
        widget.ride.pickupLat,
        widget.ride.pickupLng,
      ),
      initialZoom: 14,
    ),

    children: [

      TileLayer(
        urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

        userAgentPackageName:
            'com.ridex.driver',
      ),

      MarkerLayer(
        markers: [

          Marker(
            point: LatLng(
              widget.ride.pickupLat,
              widget.ride.pickupLng,
            ),
            width: 50,
            height: 50,
            child: const Icon(
              Icons.location_pin,
              size: 45,
            ),
          ),

          Marker(
            point: LatLng(
              widget.ride.destinationLat,
              widget.ride.destinationLng,
            ),
            width: 50,
            height: 50,
            child: const Icon(
              Icons.flag,
              size: 40,
            ),
          ),

        ],
      ),
    ],
  );
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Ride #${widget.ride.id}",
      ),
    ),

    body: Column(
      children: [

        Expanded(
          child: buildMap(),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                getStatusText(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Fare: ₹${widget.ride.fare.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              if (getNextStatus() != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : updateRideStatus,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(),
                          )
                        : Text(
                            getButtonText(),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}}