import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/location_service.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../../../search/presentation/state/search_notifier.dart';

part 'truck_map_notifier.g.dart';

const _radiusKm = 150;

class TruckMapState {
  final bool loading;
  final String? error;
  final CurrentLocation? userLocation;
  final List<TruckSearchResultEntity> trucks;

  const TruckMapState({
    this.loading = false,
    this.error,
    this.userLocation,
    this.trucks = const [],
  });

  TruckMapState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    CurrentLocation? userLocation,
    List<TruckSearchResultEntity>? trucks,
  }) {
    return TruckMapState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      userLocation: userLocation ?? this.userLocation,
      trucks: trucks ?? this.trucks,
    );
  }
}

@riverpod
class TruckMapNotifier extends _$TruckMapNotifier {
  @override
  TruckMapState build() => const TruckMapState();

  /// Resolves the user's live location, then pages through
  /// `/api/search/trucks` (origin-only, no truck type/capacity filters)
  /// until every post within [_radiusKm] has been collected — a single
  /// page isn't enough since the endpoint paginates like the search screen
  /// does. A [LocationServiceException] is left uncaught so the screen can
  /// show the same permission/settings dialog used elsewhere in the app.
  Future<void> loadNearbyTrucks() async {
    state = state.copyWith(loading: true, clearError: true);

    final CurrentLocation current;
    try {
      current = await ref.read(locationServiceProvider).getCurrentLocation();
    } on LocationServiceException {
      state = state.copyWith(loading: false);
      rethrow;
    }

    final origin = LocationEntity(
      id: 'current',
      name: current.name,
      lat: current.lat,
      lng: current.lng,
      type: 'current',
      city: current.city,
      state: current.state,
      pincode: current.pincode,
    );

    try {
      final trucks = <TruckSearchResultEntity>[];
      var page = 1;
      while (true) {
        final resultPage = await ref
            .read(searchTrucksUseCaseProvider)
            .execute(
              origin: origin,
              destination: null,
              truckType: null,
              radiusKm: _radiusKm,
              page: page,
              capacity: null,
              sortBy: sortByNearestOrigin,
            );
        trucks.addAll(resultPage.posts);
        if (page >= resultPage.totalPages) break;
        page++;
      }

      state = state.copyWith(
        loading: false,
        userLocation: current,
        trucks: trucks,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        userLocation: current,
        error: ApiException.messageFor(e),
      );
    }
  }
}
