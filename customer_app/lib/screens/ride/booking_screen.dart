import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';
import 'dart:convert';

import '../../core/constants/api_constants.dart';
import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';


class BookingScreen extends StatefulWidget {
  final Position currentPosition;

  

  const BookingScreen({
    super.key,
    required this.currentPosition,
  });


  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  final apiService = ApiService();
  final authService = AuthService();

  Ride? createdRide;


  LatLng? destinationLocation;

  bool isLoading = false;

  Future<void> createRide() async {
  if (destinationLocation == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select destination"),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final token = await authService.getToken();

    if (token == null) {
      throw Exception("Authentication token missing");
    }

    final response = await apiService.post(
      ApiConstants.rides,
      {
        "pickup_lat":
            widget.currentPosition.latitude,
        "pickup_lng":
            widget.currentPosition.longitude,
        "destination_lat":
            destinationLocation!.latitude,
        "destination_lng":
            destinationLocation!.longitude,
      },
      token: token,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final ride = Ride.fromJson(data);

      setState(() {
        createdRide = ride;
      });

      print("Ride created: ${ride.id}");
      print("Fare: ₹${ride.fare}");
      print("Status: ${ride.status}");
    } else {
      final data = jsonDecode(response.body);

      showMessage(
        data["detail"] ?? "Unable to create ride",
      );
    }
  } catch (e) {
    showMessage("Something went wrong");
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

  Future<void> chooseDestination() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          currentPosition: widget.currentPosition,
        ),
      ),
    );

    if (result is LatLng) {
      setState(() {
        destinationLocation = result;
      });
    }
  }

  void continueBooking() {
    if (destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select destination"),
        ),
      );
      return;
    }

    print(
      "Pickup: "
      "${widget.currentPosition.latitude}, "
      "${widget.currentPosition.longitude}",
    );

    print(
      "Destination: "
      "${destinationLocation!.latitude}, "
      "${destinationLocation!.longitude}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Ride"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // Pickup
            ListTile(
              leading: const Icon(
                Icons.my_location,
              ),
              title: const Text("Pickup"),
              subtitle: Text(
                "${widget.currentPosition.latitude}, "
                "${widget.currentPosition.longitude}",
              ),
            ),

            const Divider(),

            // Destination
            ListTile(
              onTap: chooseDestination,
              leading: const Icon(
                Icons.location_on,
              ),
              title: const Text("Destination"),
              subtitle: Text(
                destinationLocation == null
                    ? "Choose destination on map"
                    : "${destinationLocation!.latitude}, "
                      "${destinationLocation!.longitude}",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
            ),

            const Spacer(),

            SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : createRide,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Book Ride"),
          ),
        ),
          ],
        ),
      ),
    );
  }
}