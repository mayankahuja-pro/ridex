class Ride {
  final int id;
  final int customerId;
  final int? driverId;

  final double pickupLat;
  final double pickupLng;

  final double destinationLat;
  final double destinationLng;

  final double fare;
  final String status;

  Ride({
    required this.id,
    required this.customerId,
    required this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.fare,
    required this.status,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json["id"],
      customerId: json["customer_id"],
      driverId: json["driver_id"],
      pickupLat: (json["pickup_lat"] as num).toDouble(),
      pickupLng: (json["pickup_lng"] as num).toDouble(),
      destinationLat:
          (json["destination_lat"] as num).toDouble(),
      destinationLng:
          (json["destination_lng"] as num).toDouble(),
      fare: (json["fare"] as num).toDouble(),
      status: json["status"],
    );
  }
}