import '../../../search/domain/entities/location_entity.dart';
import '../entities/trip_entity.dart';

abstract class TripRepository {
  Future<List<TripEntity>> getMyTrips(String userId);

  Future<TripEntity> reactivateTrip(String tripId);

  Future<void> deleteTrip(String tripId);

  Future<TripEntity> editTrip({
    required String tripId,
    required String vehicleId,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  });
}
