import '../entities/location_entity.dart';
import '../repositories/search_repository.dart';

class SearchLocationsUseCase {
  final SearchRepository _repository;

  SearchLocationsUseCase(this._repository);

  Future<List<LocationEntity>> execute(String query) =>
      _repository.searchLocations(query);
}
