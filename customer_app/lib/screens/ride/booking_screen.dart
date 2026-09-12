import 'package:customer_app/models/fare_estimate.dart';
import 'package:customer_app/screens/ride/searching_screen.dart';
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

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => SearchingScreen(
        ride: ride,
      ),
    ),
  );
}
    else {
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


  Future<void> getFareEstimate() async {
  if (destinationLocation == null) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final token = await authService.getToken();

    final response = await apiService.post(
      ApiConstants.fareEstimate,
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final estimate =
          FareEstimate.fromJson(data);

      if (!mounted) return;

      showFarePreview(estimate);
    } else {
      final data = jsonDecode(response.body);

      showMessage(
        data["detail"] ?? "Unable to calculate fare",
      );
    }
  } catch (e, stackTrace) {
  debugPrint("❌ Fare estimate error: $e");
  debugPrint("❌ Stack trace: $stackTrace");

  showMessage("Error: $e");
}
   finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

void showFarePreview(
  FareEstimate estimate,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Ride Estimate",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bike"),
                Text(
                  "₹${estimate.fare.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              "${estimate.distanceKm.toStringAsFixed(2)} km",
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  createRide();
                },
                child: const Text(
                  "Confirm Ride",
                ),
              ),
            ),
          ],
        ),
      );
    },
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
            onPressed: isLoading? null: getFareEstimate,
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