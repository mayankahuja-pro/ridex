import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_screen.dart';

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

  LatLng? destinationLocation;

  bool isLoading = false;

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
                onPressed: continueBooking,
                child: const Text(
                  "Continue",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}