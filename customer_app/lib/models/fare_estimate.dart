class FareEstimate {
  final double distanceKm;
  final double fare;

  FareEstimate({
    required this.distanceKm,
    required this.fare,
  });

  factory FareEstimate.fromJson(
    Map<String, dynamic> json,
  ) {
    return FareEstimate(
      distanceKm:
          (json["distance_km"] as num).toDouble(),
      fare:
          (json["fare"] as num).toDouble(),
    );
  }
}