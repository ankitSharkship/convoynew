import '../../domain/entities/truck_pin_entity.dart';

class TruckPinsModel {
  /// Malformed pins are skipped so one bad entry can't fail the whole map.
  static TruckPinEntity? _pinFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    final lat = json['lat'];
    final lng = json['lng'];
    if (id is! String || lat is! num || lng is! num) return null;
    return TruckPinEntity(
      id: id,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      truckType: json['truckType'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    );
  }

  static TruckPinsEntity fromJson(Map<String, dynamic> json) {
    final raw = json['pins'];
    return TruckPinsEntity(
      pins: [
        if (raw is List)
          for (final item in raw) ?_pinFromJson(item),
      ],
      truncated: json['truncated'] as bool? ?? false,
    );
  }
}
