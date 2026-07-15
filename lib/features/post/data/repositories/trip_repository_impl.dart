import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remote;

  TripRepositoryImpl(this._remote);

  @override
  Future<List<TripEntity>> getMyTrips(String userId) =>
      _remote.getMyTrips(userId);

  @override
  Future<TripEntity> reactivateTrip(String tripId) =>
      _remote.reactivateTrip(tripId);

  @override
  Future<void> deleteTrip(String tripId) => _remote.deleteTrip(tripId);

  @override
  Future<TripEntity> editTrip({
    required String tripId,
    required String vehicleId,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  }) => _remote.editTrip(
    tripId: tripId,
    vehicleId: vehicleId,
    destinations: destinations,
    currentLocation: currentLocation,
    contactName: contactName,
    contactNumber: contactNumber,
  );
}
