import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/truck_search_result_entity.dart';
import '../../domain/usecases/search_locations_usecase.dart';
import '../../domain/usecases/search_trucks_usecase.dart';

part 'search_notifier.g.dart';

const _minQueryLength = 3;
const _debounceDuration = Duration(milliseconds: 350);
const _defaultRadiusKm = 150;

const sortByNearestOrigin = 'nearest_origin';
const sortByNearestDestination = 'nearest_destination';

@riverpod
SearchRemoteDataSource searchRemoteDataSource(SearchRemoteDataSourceRef ref) {
  return SearchRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
SearchRepositoryImpl searchRepository(SearchRepositoryRef ref) {
  return SearchRepositoryImpl(ref.watch(searchRemoteDataSourceProvider));
}

@riverpod
SearchLocationsUseCase searchLocationsUseCase(SearchLocationsUseCaseRef ref) {
  return SearchLocationsUseCase(ref.watch(searchRepositoryProvider));
}

@riverpod
SearchTrucksUseCase searchTrucksUseCase(SearchTrucksUseCaseRef ref) {
  return SearchTrucksUseCase(ref.watch(searchRepositoryProvider));
}

class SearchState {
  final LocationEntity? originLocation;
  final LocationEntity? destinationLocation;
  final List<LocationEntity> originSuggestions;
  final List<LocationEntity> destinationSuggestions;
  final bool originSuggestionsLoading;
  final bool destinationSuggestionsLoading;
  final bool originSuggestionsDismissed;
  final bool destinationSuggestionsDismissed;
  final bool originLocating;
  final bool destinationLocating;
  final String? selectedTruckType;
  final String? selectedCapacity;
  final bool searching;
  final bool refreshing;
  final String? searchError;
  final TruckSearchResultPage? resultPage;
  final DateTime? lastSearchedDate;
  final String sortBy;

  const SearchState({
    this.originLocation,
    this.destinationLocation,
    this.originSuggestions = const [],
    this.destinationSuggestions = const [],
    this.originSuggestionsLoading = false,
    this.destinationSuggestionsLoading = false,
    this.originSuggestionsDismissed = false,
    this.destinationSuggestionsDismissed = false,
    this.originLocating = false,
    this.destinationLocating = false,
    this.selectedTruckType,
    this.selectedCapacity,
    this.searching = false,
    this.refreshing = false,
    this.searchError,
    this.resultPage,
    this.lastSearchedDate,
    this.sortBy = sortByNearestOrigin,
  });

  bool get canSearch =>
      (originLocation != null || destinationLocation != null) && !searching;

  bool get showOriginSuggestions =>
      !originSuggestionsDismissed &&
      (originSuggestionsLoading || originSuggestions.isNotEmpty);

  bool get showDestinationSuggestions =>
      !destinationSuggestionsDismissed &&
      (destinationSuggestionsLoading || destinationSuggestions.isNotEmpty);

  SearchState copyWith({
    LocationEntity? originLocation,
    bool clearOriginLocation = false,
    LocationEntity? destinationLocation,
    bool clearDestinationLocation = false,
    List<LocationEntity>? originSuggestions,
    List<LocationEntity>? destinationSuggestions,
    bool? originSuggestionsLoading,
    bool? destinationSuggestionsLoading,
    bool? originSuggestionsDismissed,
    bool? destinationSuggestionsDismissed,
    bool? originLocating,
    bool? destinationLocating,
    String? selectedTruckType,
    String? selectedCapacity,
    bool? searching,
    bool? refreshing,
    String? searchError,
    bool clearSearchError = false,
    TruckSearchResultPage? resultPage,
    bool clearResultPage = false,
    DateTime? lastSearchedDate,
    String? sortBy,
  }) {
    return SearchState(
      originLocation: clearOriginLocation
          ? null
          : (originLocation ?? this.originLocation),
      destinationLocation: clearDestinationLocation
          ? null
          : (destinationLocation ?? this.destinationLocation),
      originSuggestions: originSuggestions ?? this.originSuggestions,
      destinationSuggestions:
          destinationSuggestions ?? this.destinationSuggestions,
      originSuggestionsLoading:
          originSuggestionsLoading ?? this.originSuggestionsLoading,
      destinationSuggestionsLoading:
          destinationSuggestionsLoading ?? this.destinationSuggestionsLoading,
      originSuggestionsDismissed:
          originSuggestionsDismissed ?? this.originSuggestionsDismissed,
      destinationSuggestionsDismissed:
          destinationSuggestionsDismissed ??
          this.destinationSuggestionsDismissed,
      originLocating: originLocating ?? this.originLocating,
      destinationLocating: destinationLocating ?? this.destinationLocating,
      selectedTruckType: selectedTruckType ?? this.selectedTruckType,
      selectedCapacity: selectedCapacity ?? this.selectedCapacity,
      searching: searching ?? this.searching,
      refreshing: refreshing ?? this.refreshing,
      searchError: clearSearchError ? null : (searchError ?? this.searchError),
      resultPage: clearResultPage ? null : (resultPage ?? this.resultPage),
      lastSearchedDate: lastSearchedDate ?? this.lastSearchedDate,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  int _originRequestId = 0;
  int _destinationRequestId = 0;
  Timer? _originDebounce;
  Timer? _destinationDebounce;

  @override
  SearchState build() {
    ref.onDispose(() {
      _originDebounce?.cancel();
      _destinationDebounce?.cancel();
    });
    return const SearchState();
  }

  void onOriginQueryChanged(String query) {
    state = state.copyWith(
      clearOriginLocation: true,
      originSuggestionsDismissed: false,
    );
    _originDebounce?.cancel();
    if (query.trim().length < _minQueryLength) {
      state = state.copyWith(originSuggestions: const []);
      return;
    }
    _originDebounce = Timer(
      _debounceDuration,
      () => _fetchSuggestions(query: query.trim(), isOrigin: true),
    );
  }

  void onDestinationQueryChanged(String query) {
    state = state.copyWith(
      clearDestinationLocation: true,
      destinationSuggestionsDismissed: false,
    );
    _destinationDebounce?.cancel();
    if (query.trim().length < _minQueryLength) {
      state = state.copyWith(destinationSuggestions: const []);
      return;
    }
    _destinationDebounce = Timer(
      _debounceDuration,
      () => _fetchSuggestions(query: query.trim(), isOrigin: false),
    );
  }

  void dismissOriginSuggestions() {
    state = state.copyWith(originSuggestionsDismissed: true);
  }

  void dismissDestinationSuggestions() {
    state = state.copyWith(destinationSuggestionsDismissed: true);
  }

  void clearOrigin() {
    state = state.copyWith(
      clearOriginLocation: true,
      originSuggestions: const [],
    );
  }

  void clearDestination() {
    state = state.copyWith(
      clearDestinationLocation: true,
      destinationSuggestions: const [],
    );
  }

  Future<void> _fetchSuggestions({
    required String query,
    required bool isOrigin,
  }) async {
    final requestId = isOrigin ? ++_originRequestId : ++_destinationRequestId;
    state = isOrigin
        ? state.copyWith(originSuggestionsLoading: true)
        : state.copyWith(destinationSuggestionsLoading: true);

    List<LocationEntity> results = const [];
    try {
      results = await ref.read(searchLocationsUseCaseProvider).execute(query);
    } catch (_) {
      results = const [];
    }

    final isStale = isOrigin
        ? requestId != _originRequestId
        : requestId != _destinationRequestId;
    if (isStale) return;

    state = isOrigin
        ? state.copyWith(
            originSuggestions: results,
            originSuggestionsLoading: false,
          )
        : state.copyWith(
            destinationSuggestions: results,
            destinationSuggestionsLoading: false,
          );
  }

  void selectOriginSuggestion(LocationEntity location) {
    state = state.copyWith(
      originLocation: location,
      originSuggestions: const [],
    );
  }

  void selectDestinationSuggestion(LocationEntity location) {
    state = state.copyWith(
      destinationLocation: location,
      destinationSuggestions: const [],
    );
  }

  Future<void> useCurrentOriginLocation() async {
    state = state.copyWith(originLocating: true);
    try {
      final current = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      selectOriginSuggestion(_toLocationEntity(current));
    } finally {
      state = state.copyWith(originLocating: false);
    }
  }

  Future<void> useCurrentDestinationLocation() async {
    state = state.copyWith(destinationLocating: true);
    try {
      final current = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      selectDestinationSuggestion(_toLocationEntity(current));
    } finally {
      state = state.copyWith(destinationLocating: false);
    }
  }

  LocationEntity _toLocationEntity(CurrentLocation current) => LocationEntity(
    id: 'current',
    name: current.name,
    lat: current.lat,
    lng: current.lng,
    type: 'current',
    city: current.city,
    state: current.state,
    pincode: current.pincode,
  );

  void selectTruckType(String? type) {
    state = state.copyWith(selectedTruckType: type);
  }

  void selectCapacity(String? capacity) {
    state = state.copyWith(selectedCapacity: capacity);
  }

  /// Nearest-to-origin is the default whenever an origin was given (with or
  /// without a destination); with only a destination, there's no origin to
  /// sort by, so nearest-to-destination is the only sensible default.
  String _defaultSortBy(LocationEntity? origin) =>
      origin != null ? sortByNearestOrigin : sortByNearestDestination;

  /// Re-runs a past search from history. Replaces the whole state (rather
  /// than merging via copyWith) so stale criteria from an unrelated search
  /// don't leak into this one.
  Future<void> repeatSearch({
    LocationEntity? origin,
    LocationEntity? destination,
    String? truckType,
    String? capacityDisplay,
  }) async {
    state = SearchState(
      originLocation: origin,
      destinationLocation: destination,
      selectedTruckType: truckType,
      selectedCapacity: capacityDisplay,
      sortBy: _defaultSortBy(origin),
    );
    await findTrucks();
  }

  Future<void> findTrucks() async {
    if (state.originLocation == null && state.destinationLocation == null) {
      return;
    }
    state = state.copyWith(
      clearResultPage: true,
      lastSearchedDate: DateTime.now(),
      sortBy: _defaultSortBy(state.originLocation),
    );
    await _search(page: 1);
  }

  /// Called when the user taps a sort option on the results screen —
  /// re-runs the current search (same criteria, page 1) with the new sort.
  Future<void> setSortBy(String sortBy) async {
    if (state.sortBy == sortBy) return;
    state = state.copyWith(sortBy: sortBy);
    await _search(page: 1);
  }

  Future<void> goToNextPage() async {
    final resultPage = state.resultPage;
    if (resultPage == null || resultPage.page >= resultPage.totalPages) {
      return;
    }
    await _search(page: resultPage.page + 1);
  }

  Future<void> goToPreviousPage() async {
    final resultPage = state.resultPage;
    if (resultPage == null || resultPage.page <= 1) return;
    await _search(page: resultPage.page - 1);
  }

  /// Pull-to-refresh on the results screen — re-fetches the current page
  /// with the same criteria. Uses [refreshing] rather than [searching] so
  /// the existing results stay on screen (with just the pull-to-refresh
  /// spinner showing) instead of being replaced by the full skeleton.
  Future<void> refresh() async {
    final resultPage = state.resultPage;
    if (resultPage == null) return;
    if (state.originLocation == null && state.destinationLocation == null) {
      return;
    }

    state = state.copyWith(refreshing: true, clearSearchError: true);
    try {
      final refreshed = await _fetchPage(page: resultPage.page);
      state = state.copyWith(refreshing: false, resultPage: refreshed);
    } catch (e) {
      state = state.copyWith(
        refreshing: false,
        searchError: ApiException.messageFor(e),
      );
    }
  }

  Future<void> _search({required int page}) async {
    final origin = state.originLocation;
    final destination = state.destinationLocation;
    if (origin == null && destination == null) return;

    state = state.copyWith(searching: true, clearSearchError: true);

    try {
      final resultPage = await _fetchPage(page: page);
      state = state.copyWith(searching: false, resultPage: resultPage);
    } catch (e) {
      state = state.copyWith(
        searching: false,
        searchError: ApiException.messageFor(e),
      );
    }
  }

  Future<TruckSearchResultPage> _fetchPage({required int page}) {
    return ref
        .read(searchTrucksUseCaseProvider)
        .execute(
          origin: state.originLocation,
          destination: state.destinationLocation,
          truckType: state.selectedTruckType,
          radiusKm: _defaultRadiusKm,
          availableDate: state.lastSearchedDate ?? DateTime.now(),
          page: page,
          capacity: _parseCapacity(state.selectedCapacity),
          sortBy: state.sortBy,
        );
  }

  int? _parseCapacity(String? value) {
    if (value == null) return null;
    final match = RegExp(r'\d+').firstMatch(value);
    return match == null ? null : int.parse(match.group(0)!);
  }
}
