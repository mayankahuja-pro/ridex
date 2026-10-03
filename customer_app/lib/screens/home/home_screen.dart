import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
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

  Future<void> openProfile() async {
    // Replace this with however you currently get your saved token.
    final token = await AuthService().getToken();

    if (!mounted || token == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          token: token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          elevation: 0,
          titleSpacing: 20,

          title: const Text(
            "RideX",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                tooltip: "Profile",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'profile') {
                    openProfile();
                  } else if (value == 'logout') {
                    logout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 12),
                        Text("Profile"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        SizedBox(width: 12),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ],
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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

                  const SizedBox(height: 20),

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
                ],
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
