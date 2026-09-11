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
  late LatLng currentLocation;

  @override
  void initState() {
    super.initState();
    currentLocation = LatLng(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Pickup Location"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 16.0,
              onTap: (tapPosition, point) {
                setState(() {
                  currentLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.customer_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          
          // Bottom Info Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Lat: ${currentLocation.latitude.toStringAsFixed(5)}, "
                            "Lng: ${currentLocation.longitude.toStringAsFixed(5)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, currentLocation);
                        },
                        child: const Text("Confirm Location"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          _mapController.move(
            LatLng(
              widget.currentPosition.latitude,
              widget.currentPosition.longitude,
            ),
            16.0,
          );
          setState(() {
            currentLocation = LatLng(
              widget.currentPosition.latitude,
              widget.currentPosition.longitude,
            );
          });
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}