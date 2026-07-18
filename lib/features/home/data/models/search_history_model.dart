import '../../../search/domain/entities/location_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';

LocationEntity? _locationFromJson(
  Map<String, dynamic>? json,
  String fallbackId,
) {
  if (json == null) return null;
  return LocationEntity(
    id: fallbackId,
    name: json['name'] as String? ?? '',
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    type: json['type'] as String? ?? '',
    pincode: json['pincode'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
  );
}

SearchHistoryEntity searchHistoryFromJson(Map<String, dynamic> json) {
  return SearchHistoryEntity(
    origin: _locationFromJson(
      json['origin'] as Map<String, dynamic>?,
      'origin',
    ),
    destination: _locationFromJson(
      json['destination'] as Map<String, dynamic>?,
      'destination',
    ),
    truckType: json['truckType'] as String?,
    capacity: (json['capacity'] as num?)?.toInt(),
    radiusKm: (json['radius_km'] as num?)?.toInt() ?? 0,
    searchedAt: DateTime.parse(json['searchedAt'] as String),
  );
}
