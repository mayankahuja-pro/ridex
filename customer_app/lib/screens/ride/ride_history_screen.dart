import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class RideHistoryScreen
    extends StatefulWidget {

  const RideHistoryScreen({
    super.key,
  });

  @override
  State<RideHistoryScreen> createState() =>
      _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {

  bool isLoading = true;

  List<Ride> rides = [];

  @override
  void initState() {
    super.initState();

    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final token =
          await AuthService().getToken();

      final data =
          await ApiService().getList(
        ApiConstants.rideHistory,
        token: token,
      );

      setState(() {
        rides = data
            .map(
              (item) => Ride.fromJson(item),
            )
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Ride History",
      ),
    ),

    body: isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : rides.isEmpty
            ? const Center(
                child: Text(
                  "No rides yet",
                ),
              )
            : ListView.builder(
                itemCount: rides.length,
                itemBuilder:
                    (context, index) {
                  final ride =
                      rides[index];

                  return Card(
                    margin:
                        const EdgeInsets.all(10),
                    child: ListTile(
                      leading: const Icon(
                        Icons.two_wheeler,
                      ),

                      title: Text(
                        "Ride #${ride.id}",
                      ),

                      subtitle: Text(
                        ride.status,
                      ),

                      trailing: Text(
                        "₹${ride.fare.toStringAsFixed(0)}",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
  );
}
}