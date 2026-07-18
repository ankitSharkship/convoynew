import '../../../search/domain/entities/location_entity.dart';

class TripEntity {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String truckType;
  final int capacity;
  final String? contactName;
  final String? contactNumber;
  final LocationEntity origin;
  final List<LocationEntity> destinations;
  final LocationEntity currentLocation;
  final String originName;
  final DateTime createdAt;
  final DateTime expiresAt;

  const TripEntity({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.truckType,
    required this.capacity,
    this.contactName,
    this.contactNumber,
    required this.origin,
    required this.destinations,
    required this.currentLocation,
    required this.originName,
    required this.createdAt,
    required this.expiresAt,
  });

  /// The source of truth for whether this trip has expired — computed from
  /// [expiresAt] against the current time rather than trusting the API's
  /// own `status`/`isExpired` fields, which can lag.
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
