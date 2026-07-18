import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';

LocationEntity _locationFromJson(
  Map<String, dynamic> json,
  String fallbackId,
) => LocationEntity(
  id: json['_id'] as String? ?? fallbackId,
  name: json['name'] as String? ?? '',
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  type: json['type'] as String? ?? '',
  pincode: json['pincode'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
);

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.vehicleId,
    required super.vehicleNumber,
    required super.truckType,
    required super.capacity,
    super.contactName,
    super.contactNumber,
    required super.origin,
    required super.destinations,
    required super.currentLocation,
    required super.originName,
    required super.createdAt,
    required super.expiresAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final destinations = json['destinations'] as List<dynamic>? ?? [];
    return TripModel(
      id: json['_id'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      truckType: json['truckType'] as String,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      contactName: json['contactName'] as String?,
      contactNumber: json['contactNumber'] as String?,
      origin: _locationFromJson(
        json['origin'] as Map<String, dynamic>,
        'origin',
      ),
      destinations: destinations
          .map((d) => _locationFromJson(d as Map<String, dynamic>, 'dest'))
          .toList(),
      currentLocation: _locationFromJson(
        json['currentLocation'] as Map<String, dynamic>,
        'current',
      ),
      originName: json['originName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
