import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Position currentPosition;

  const MapScreen({
    super.key,
    required this.currentPosition,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  late LatLng pickupLocation;

  LatLng? destinationLocation;

  @override
  void initState() {
    super.initState();

    pickupLocation = LatLng(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
  }

  void selectDestination(LatLng position) {
    setState(() {
      destinationLocation = position;
    });

    print("Destination Latitude: ${position.latitude}");
    print("Destination Longitude: ${position.longitude}");
  }

  void continueBooking() {
    if (destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tap on the map to select destination"),
        ),
      );
      return;
    }

    print("========== RIDE ==========");
    print("Pickup: ${pickupLocation.latitude}, "
        "${pickupLocation.longitude}");

    print("Destination: ${destinationLocation!.latitude}, "
        "${destinationLocation!.longitude}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: pickupLocation,
              zoom: 16,
            ),

            myLocationEnabled: true,
            myLocationButtonEnabled: true,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onTap: selectDestination,

            markers: {
              Marker(
                markerId: const MarkerId("pickup"),
                position: pickupLocation,
                infoWindow: const InfoWindow(
                  title: "Pickup",
                ),
              ),

              if (destinationLocation != null)
                Marker(
                  markerId: const MarkerId("destination"),
                  position: destinationLocation!,
                  infoWindow: const InfoWindow(
                    title: "Destination",
                  ),
                ),
            },
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [

                  Text(
                    destinationLocation == null
                        ? "Tap on the map to select destination"
                        : "Destination selected",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
          ),
        ],
      ),
    );
  }
}