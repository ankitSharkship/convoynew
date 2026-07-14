import '../entities/location_entity.dart';
import '../entities/truck_search_result_entity.dart';
import '../repositories/search_repository.dart';

class SearchTrucksUseCase {
  final SearchRepository _repository;

  SearchTrucksUseCase(this._repository);

  Future<TruckSearchResultPage> execute({
    required LocationEntity? origin,
    required LocationEntity? destination,
    required String? truckType,
    required int radiusKm,
    required DateTime availableDate,
    required int page,
    required int? capacity,
  }) =>
      _repository.searchTrucks(
        origin: origin,
        destination: destination,
        truckType: truckType,
        radiusKm: radiusKm,
        availableDate: availableDate,
        page: page,
        capacity: capacity,
      );
}
