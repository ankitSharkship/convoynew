import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.name,
    required super.lat,
    required super.lng,
    required super.type,
    super.pincode,
    super.city,
    super.state,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['_id'] as String,
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        type: json['type'] as String? ?? 'google',
        pincode: json['pincode'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
      );
}
