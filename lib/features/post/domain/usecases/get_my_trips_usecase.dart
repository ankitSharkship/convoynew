import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetMyTripsUseCase {
  final TripRepository _repository;

  GetMyTripsUseCase(this._repository);

  Future<List<TripEntity>> execute(String userId) =>
      _repository.getMyTrips(userId);
}
