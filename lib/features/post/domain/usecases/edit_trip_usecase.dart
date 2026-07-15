import '../../../search/domain/entities/location_entity.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class EditTripUseCase {
  final TripRepository _repository;

  EditTripUseCase(this._repository);

  Future<TripEntity> execute({
    required String tripId,
    required String vehicleId,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  }) => _repository.editTrip(
    tripId: tripId,
    vehicleId: vehicleId,
    destinations: destinations,
    currentLocation: currentLocation,
    contactName: contactName,
    contactNumber: contactNumber,
  );
}
