import '../entities/location_entity.dart';
import '../entities/truck_search_result_entity.dart';

abstract class SearchRepository {
  Future<List<LocationEntity>> searchLocations(String query);

  Future<TruckSearchResultPage> searchTrucks({
    required LocationEntity? origin,
    required LocationEntity? destination,
    required String? truckType,
    required int radiusKm,
    required DateTime availableDate,
    required int page,
    required int? capacity,
  });
}
