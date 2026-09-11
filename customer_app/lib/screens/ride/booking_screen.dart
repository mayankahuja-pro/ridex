import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';
class BookingScreen extends StatefulWidget {
  final Position currentPosition;

  const BookingScreen({
    super.key,
    required this.currentPosition,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final destinationController = TextEditingController();

  bool isBooking = false;

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  void bookRide() {
    if (destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter destination"),
        ),
      );
      return;
    }

    // API integration next step.
    print("Pickup:");
    print(widget.currentPosition.latitude);
    print(widget.currentPosition.longitude);

    print("Destination:");
    print(destinationController.text);
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
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pickup Location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.currentPosition.latitude}, "
                    "${widget.currentPosition.longitude}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                labelText: "Where do you want to go?",
                border: OutlineInputBorder(),
              ),
            ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapScreen(
                    currentPosition:
                        widget.currentPosition,
                  ),
                ),
              );
            },
            child: const Text("Choose on Map"),
          ),
            const Spacer(),


            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isBooking ? null : bookRide,
                child: isBooking
                    ? const CircularProgressIndicator()
                    : const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}