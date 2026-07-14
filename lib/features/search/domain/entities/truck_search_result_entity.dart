class TruckSearchLocationEntity {
  final double lat;
  final double lng;
  final String name;
  final String type;
  final String? city;
  final String? state;
  final String? pincode;

  const TruckSearchLocationEntity({
    required this.lat,
    required this.lng,
    required this.name,
    required this.type,
    this.city,
    this.state,
    this.pincode,
  });
}

class TruckSearchDestinationEntity extends TruckSearchLocationEntity {
  final String id;
  final int position;

  const TruckSearchDestinationEntity({
    required this.id,
    required this.position,
    required super.lat,
    required super.lng,
    required super.name,
    required super.type,
    super.city,
    super.state,
    super.pincode,
  });
}

class MatchedDestinationEntity extends TruckSearchLocationEntity {
  final String id;
  final double distanceKm;

  const MatchedDestinationEntity({
    required this.id,
    required this.distanceKm,
    required super.lat,
    required super.lng,
    required super.name,
    required super.type,
    super.city,
    super.state,
    super.pincode,
  });
}

class TruckSearchResultEntity {
  final String truckId;
  final String truckRouteId;
  final String truckNumber;
  final String truckType;
  final int capacity;
  final String origin;
  final double originDistanceKm;
  final String availableDate;
  final String status;
  final TruckSearchLocationEntity originLocation;
  final TruckSearchLocationEntity currentLocation;
  final List<TruckSearchDestinationEntity> destinations;
  final MatchedDestinationEntity? matchedDestination;
  final String userName;
  final String? userPhoto;
  final String userMobile;
  final int mutualsCount;
  final List<String> mutualNames;
  final DateTime createdAt;
  final DateTime expiresAt;

  const TruckSearchResultEntity({
    required this.truckId,
    required this.truckRouteId,
    required this.truckNumber,
    required this.truckType,
    required this.capacity,
    required this.origin,
    required this.originDistanceKm,
    required this.availableDate,
    required this.status,
    required this.originLocation,
    required this.currentLocation,
    required this.destinations,
    this.matchedDestination,
    required this.userName,
    this.userPhoto,
    required this.userMobile,
    required this.mutualsCount,
    required this.mutualNames,
    required this.createdAt,
    required this.expiresAt,
  });
}

class TruckSearchResultPage {
  final List<TruckSearchResultEntity> posts;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const TruckSearchResultPage({
    required this.posts,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });
}
