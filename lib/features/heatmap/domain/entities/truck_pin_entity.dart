/// One live truck as a pin on the map — just enough to draw it. Everything
/// else (poster, contact, route) is fetched when the pin is tapped.
class TruckPinEntity {
  final String id;
  final double lat;
  final double lng;
  final String truckType;
  final int capacity;

  const TruckPinEntity({
    required this.id,
    required this.lat,
    required this.lng,
    required this.truckType,
    required this.capacity,
  });
}

class TruckPinsEntity {
  final List<TruckPinEntity> pins;

  /// True when the server stopped at its cap, keeping the pins nearest the
  /// centre of the requested area.
  final bool truncated;

  const TruckPinsEntity({required this.pins, required this.truncated});
}
