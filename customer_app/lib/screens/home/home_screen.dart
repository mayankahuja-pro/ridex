import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../ride/booking_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService locationService = LocationService();

  Position? currentPosition;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    try {
      final position = await locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        currentPosition = null;
        isLoadingLocation = false;
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RideX"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: logout,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Where do you want to go?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            if (isLoadingLocation)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Getting your location..."),
                ],
              ),

            if (!isLoadingLocation && currentPosition != null)
              Column(
                children: [
                  const Text(
                    "Current Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Lat: ${currentPosition!.latitude}",
                  ),

                  Text(
                    "Lng: ${currentPosition!.longitude}",
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: loadLocation,
                    icon: const Icon(Icons.location_on),
                    label: const Text("Refresh Location"),
                  ),
                ],
              ),

              if (!isLoadingLocation && currentPosition != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          currentPosition: currentPosition!,
                        ),
                      ),
                    );
                  },
                  child: const Text("Book a Ride"),
                ),
              ),

            if (!isLoadingLocation && currentPosition == null)
              Column(
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 50,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Unable to get your location",
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: loadLocation,
                    child: const Text("Try Again"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
