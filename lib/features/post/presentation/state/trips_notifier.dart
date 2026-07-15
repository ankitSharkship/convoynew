import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/trip_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/usecases/delete_trip_usecase.dart';
import '../../domain/usecases/get_my_trips_usecase.dart';
import '../../domain/usecases/reactivate_trip_usecase.dart';

part 'trips_notifier.g.dart';

@riverpod
TripRemoteDataSource tripRemoteDataSource(TripRemoteDataSourceRef ref) {
  return TripRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
TripRepositoryImpl tripRepository(TripRepositoryRef ref) {
  return TripRepositoryImpl(ref.watch(tripRemoteDataSourceProvider));
}

@riverpod
GetMyTripsUseCase getMyTripsUseCase(GetMyTripsUseCaseRef ref) {
  return GetMyTripsUseCase(ref.watch(tripRepositoryProvider));
}

@riverpod
ReactivateTripUseCase reactivateTripUseCase(ReactivateTripUseCaseRef ref) {
  return ReactivateTripUseCase(ref.watch(tripRepositoryProvider));
}

@riverpod
DeleteTripUseCase deleteTripUseCase(DeleteTripUseCaseRef ref) {
  return DeleteTripUseCase(ref.watch(tripRepositoryProvider));
}

@riverpod
class TripsNotifier extends _$TripsNotifier {
  @override
  Future<List<TripEntity>> build() async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();
    return ref.read(getMyTripsUseCaseProvider).execute(userId);
  }

  Future<void> reactivate(String tripId) async {
    final updated = await ref
        .read(reactivateTripUseCaseProvider)
        .execute(tripId);

    final current = await future;
    state = AsyncData([
      for (final trip in current)
        if (trip.id == tripId) updated else trip,
    ]);
  }

  Future<void> delete(String tripId) async {
    await ref.read(deleteTripUseCaseProvider).execute(tripId);

    final current = await future;
    state = AsyncData(current.where((t) => t.id != tripId).toList());
  }
}
