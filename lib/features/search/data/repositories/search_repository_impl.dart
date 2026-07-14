import '../../domain/entities/location_entity.dart';
import '../../domain/entities/truck_search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remote;

  SearchRepositoryImpl(this._remote);

  @override
  Future<List<LocationEntity>> searchLocations(String query) =>
      _remote.searchLocations(query);

  @override
  Future<TruckSearchResultPage> searchTrucks({
    required LocationEntity? origin,
    required LocationEntity? destination,
    required String? truckType,
    required int radiusKm,
    required DateTime availableDate,
    required int page,
    required int? capacity,
  }) =>
      _remote.searchTrucks(
        origin: origin,
        destination: destination,
        truckType: truckType,
        radiusKm: radiusKm,
        availableDate: availableDate,
        page: page,
        capacity: capacity,
      );
}
