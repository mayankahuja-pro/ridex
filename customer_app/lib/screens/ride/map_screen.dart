import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final MapController _mapController = MapController();

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
        content: Text(
          "Tap on the map to select destination",
        ),
      ),
    );
    return;
  }

  Navigator.pop(
    context,
    destinationLocation,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Destination"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pickupLocation,
              initialZoom: 16.0,
              onTap: (tapPosition, point) {
                selectDestination(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.customer_app',
              ),
              MarkerLayer(
                markers: [
                  // Pickup Marker (Green)
                  Marker(
                    point: pickupLocation,
                    width: 70,
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(blurRadius: 4, color: Colors.black26),
                            ],
                          ),
                          child: const Text(
                            "Pickup",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_pin,
                          color: Colors.green,
                          size: 38,
                        ),
                      ],
                    ),
                  ),

                  // Destination Marker (Red)
                  if (destinationLocation != null)
                    Marker(
                      point: destinationLocation!,
                      width: 80,
                      height: 70,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Colors.black26),
                              ],
                            ),
                            child: const Text(
                              "Destination",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 38,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Re-center on user position button
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _mapController.move(pickupLocation, 16.0);
              },
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // Bottom card for Continue Booking
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
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    destinationLocation == null
                        ? "Tap on the map to select destination"
                        : "Destination selected: ${destinationLocation!.latitude.toStringAsFixed(4)}, ${destinationLocation!.longitude.toStringAsFixed(4)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: continueBooking,
                      child: const Text("Continue"),
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