import '../repositories/trip_repository.dart';

class DeleteTripUseCase {
  final TripRepository _repository;

  DeleteTripUseCase(this._repository);

  Future<void> execute(String tripId) => _repository.deleteTrip(tripId);
}
