import 'location_entity.dart';

class SearchHistoryEntity {
  final LocationEntity? origin;
  final LocationEntity? destination;
  final String? truckType;
  final int? capacity;
  final int radiusKm;
  final DateTime searchedAt;

  const SearchHistoryEntity({
    this.origin,
    this.destination,
    this.truckType,
    this.capacity,
    required this.radiusKm,
    required this.searchedAt,
  });
}
