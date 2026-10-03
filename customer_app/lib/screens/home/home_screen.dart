import 'package:customer_app/screens/ride/ride_history_screen.dart';
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

  static const Color background = Color(0xFF0B0B0D);
  static const Color surface = Color(0xFF151518);
  static const Color surfaceLight = Color(0xFF1D1D21);
  static const Color accent = Color(0xFFD7FF3F);

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

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

  void openBooking() {
    if (currentPosition == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          currentPosition: currentPosition!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,

        title: const Text(
          'RideX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            color: surfaceLight,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
                    Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white12,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 20,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Where to?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Get where you need to go.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              _locationCard(),

              const SizedBox(height: 14),

              _destinationCard(),

              const SizedBox(height: 24),

              _bookButton(),

              const SizedBox(height: 32),

              const Text(
                'QUICK ACCESS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _quickCard(
                      icon: Icons.history,
                      title: 'Ride history',
                      onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RideHistoryScreen(),
                  ),
                );
              },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickCard(
                      icon: Icons.favorite_border,
                      title: 'Saved places',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location,
              color: accent,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT LOCATION',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                if (isLoadingLocation)
                  const Text(
                    'Getting your location...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                else if (currentPosition != null)
                  Text(
                    '${currentPosition!.latitude.toStringAsFixed(5)}, '
                    '${currentPosition!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Text(
                    'Location unavailable',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed: loadLocation,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _destinationCard() {
    return InkWell(
      onTap: currentPosition != null ? openBooking : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white54,
            ),

            SizedBox(width: 14),

            Expanded(
              child: Text(
                'Enter destination',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookButton() {
    final enabled = currentPosition != null && !isLoadingLocation;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: enabled ? openBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          disabledBackgroundColor: surfaceLight,
          foregroundColor: Colors.black,
          disabledForegroundColor: Colors.white24,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              enabled ? 'Book a ride' : 'Waiting for location',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            if (enabled) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 21,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
