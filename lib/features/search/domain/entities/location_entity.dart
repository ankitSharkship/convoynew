class LocationEntity {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String? pincode;
  final String? city;
  final String? state;

  const LocationEntity({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    this.pincode,
    this.city,
    this.state,
  });

  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'type': type,
        'pincode': pincode,
        'city': city,
        'state': state,
      };
}
