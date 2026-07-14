import '../../domain/entities/truck_search_result_entity.dart';

TruckSearchLocationEntity _locationFromJson(Map<String, dynamic> json) =>
    TruckSearchLocationEntity(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );

TruckSearchDestinationEntity _destinationFromJson(Map<String, dynamic> json) =>
    TruckSearchDestinationEntity(
      id: json['_id'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );

MatchedDestinationEntity? _matchedDestinationFromJson(
    Map<String, dynamic>? json) {
  if (json == null) return null;
  return MatchedDestinationEntity(
    id: json['_id'] as String,
    distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? '',
    city: json['city'] as String?,
    state: json['state'] as String?,
    pincode: json['pincode'] as String?,
  );
}

TruckSearchResultEntity truckSearchResultFromJson(Map<String, dynamic> json) {
  final mutuals = json['mutuals'] as Map<String, dynamic>? ?? const {};
  return TruckSearchResultEntity(
    truckId: json['truck_id'] as String,
    truckRouteId: json['truck_route_id'] as String,
    truckNumber: json['truck_number'] as String,
    truckType: json['truck_type'] as String,
    capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    origin: json['origin'] as String,
    originDistanceKm: (json['origin_distance_km'] as num?)?.toDouble() ?? 0,
    availableDate: json['available_date'] as String,
    status: json['status'] as String,
    originLocation:
        _locationFromJson(json['originLocation'] as Map<String, dynamic>),
    currentLocation:
        _locationFromJson(json['currentLocation'] as Map<String, dynamic>),
    destinations: (json['destinations'] as List<dynamic>? ?? [])
        .map((e) => _destinationFromJson(e as Map<String, dynamic>))
        .toList(),
    matchedDestination: _matchedDestinationFromJson(
        json['matchedDestination'] as Map<String, dynamic>?),
    userName: json['userName'] as String? ?? '',
    userPhoto: json['userPhoto'] as String?,
    userMobile: json['userMobile'] as String? ?? '',
    mutualsCount: (mutuals['count'] as num?)?.toInt() ?? 0,
    mutualNames: (mutuals['names'] as List<dynamic>? ?? []).cast<String>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

TruckSearchResultPage truckSearchResultPageFromJson(
    Map<String, dynamic> json) {
  final posts = (json['posts'] as List<dynamic>? ?? [])
      .map((e) => truckSearchResultFromJson(e as Map<String, dynamic>))
      .toList();
  return TruckSearchResultPage(
    posts: posts,
    page: (json['page'] as num?)?.toInt() ?? 1,
    pageSize: (json['pageSize'] as num?)?.toInt() ?? posts.length,
    totalCount: (json['totalCount'] as num?)?.toInt() ?? posts.length,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
  );
}
