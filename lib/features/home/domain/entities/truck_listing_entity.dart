class TruckListingEntity {
  final String id;
  final String driverName;
  final String initials;
  final String truckType;
  final String capacity;
  final String origin;
  final List<String> destinations;
  final int minutesAgo;
  final double rating;
  final int mutualConnections;
  final bool isVerified;
  final bool isNearby;
  final double distanceKm;
  final String phone;

  const TruckListingEntity({
    required this.id,
    required this.driverName,
    required this.initials,
    required this.truckType,
    required this.capacity,
    required this.origin,
    required this.destinations,
    required this.minutesAgo,
    required this.rating,
    required this.mutualConnections,
    required this.isVerified,
    required this.isNearby,
    required this.distanceKm,
    required this.phone,
  });
}
