import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class ReactivateTripUseCase {
  final TripRepository _repository;

  ReactivateTripUseCase(this._repository);

  Future<TripEntity> execute(String tripId) =>
      _repository.reactivateTrip(tripId);
}
