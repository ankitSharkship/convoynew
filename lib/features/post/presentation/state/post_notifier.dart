import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../../search/presentation/state/search_notifier.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/submit_post_usecase.dart';

part 'post_notifier.g.dart';

const _minQueryLength = 3;
const _debounceDuration = Duration(milliseconds: 350);
const _maxDestinations = 5;

@riverpod
PostRemoteDataSource postRemoteDataSource(PostRemoteDataSourceRef ref) {
  return PostRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
PostRepositoryImpl postRepository(PostRepositoryRef ref) {
  return PostRepositoryImpl(ref.watch(postRemoteDataSourceProvider));
}

@riverpod
SubmitPostUseCase submitPostUseCase(SubmitPostUseCaseRef ref) {
  return SubmitPostUseCase(ref.watch(postRepositoryProvider));
}

class DestinationField {
  final LocationEntity? location;
  final List<LocationEntity> suggestions;
  final bool suggestionsLoading;

  const DestinationField({
    this.location,
    this.suggestions = const [],
    this.suggestionsLoading = false,
  });

  DestinationField copyWith({
    LocationEntity? location,
    bool clearLocation = false,
    List<LocationEntity>? suggestions,
    bool? suggestionsLoading,
  }) {
    return DestinationField(
      location: clearLocation ? null : (location ?? this.location),
      suggestions: suggestions ?? this.suggestions,
      suggestionsLoading: suggestionsLoading ?? this.suggestionsLoading,
    );
  }
}

sealed class PostState {
  const PostState();
}

class PostIdle extends PostState {
  const PostIdle();
}

class PostSubmitting extends PostState {
  const PostSubmitting();
}

class PostDone extends PostState {
  final PostEntity post;
  const PostDone(this.post);
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
}

class PostFormState {
  final LocationEntity? origin;
  final bool originLocating;
  final List<DestinationField> destinations;
  final String? selectedVehicleId;
  final PostState submission;

  const PostFormState({
    this.origin,
    this.originLocating = false,
    this.destinations = const [DestinationField()],
    this.selectedVehicleId,
    this.submission = const PostIdle(),
  });

  bool get canAddDestination => destinations.length < _maxDestinations;

  bool get canSubmit =>
      origin != null &&
      destinations.isNotEmpty &&
      destinations.first.location != null &&
      selectedVehicleId != null &&
      submission is! PostSubmitting;

  PostFormState copyWith({
    LocationEntity? origin,
    bool clearOrigin = false,
    bool? originLocating,
    List<DestinationField>? destinations,
    String? selectedVehicleId,
    PostState? submission,
  }) {
    return PostFormState(
      origin: clearOrigin ? null : (origin ?? this.origin),
      originLocating: originLocating ?? this.originLocating,
      destinations: destinations ?? this.destinations,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      submission: submission ?? this.submission,
    );
  }
}

@riverpod
class PostNotifier extends _$PostNotifier {
  final Map<int, int> _destinationRequestIds = {};
  final Map<int, Timer> _destinationDebounces = {};

  @override
  PostFormState build() {
    ref.onDispose(() {
      for (final timer in _destinationDebounces.values) {
        timer.cancel();
      }
    });
    return const PostFormState();
  }

  // ── Origin ──────────────────────────────────────────────────────────────

  void clearOrigin() {
    state = state.copyWith(clearOrigin: true);
  }

  Future<void> useCurrentOriginLocation() async {
    state = state.copyWith(originLocating: true);
    try {
      final current = await ref.read(locationServiceProvider).getCurrentLocation();
      state = state.copyWith(origin: _toLocationEntity(current));
    } finally {
      state = state.copyWith(originLocating: false);
    }
  }

  // ── Destinations ────────────────────────────────────────────────────────

  void addDestination() {
    if (!state.canAddDestination) return;
    state = state.copyWith(
      destinations: [...state.destinations, const DestinationField()],
    );
  }

  void removeDestination(int index) {
    if (state.destinations.length <= 1) return;
    _destinationDebounces.remove(index)?.cancel();
    final updated = [...state.destinations]..removeAt(index);
    state = state.copyWith(destinations: updated);
  }

  void onDestinationQueryChanged(int index, String query) {
    _setDestinationAt(index, (d) => d.copyWith(clearLocation: true));
    _destinationDebounces[index]?.cancel();
    if (query.trim().length < _minQueryLength) {
      _setDestinationAt(index, (d) => d.copyWith(suggestions: const []));
      return;
    }
    _destinationDebounces[index] = Timer(
      _debounceDuration,
      () => _fetchDestinationSuggestions(index, query.trim()),
    );
  }

  Future<void> _fetchDestinationSuggestions(int index, String query) async {
    final requestId = (_destinationRequestIds[index] ?? 0) + 1;
    _destinationRequestIds[index] = requestId;
    _setDestinationAt(index, (d) => d.copyWith(suggestionsLoading: true));

    List<LocationEntity> results = const [];
    try {
      results = await ref.read(searchLocationsUseCaseProvider).execute(query);
    } catch (_) {
      results = const [];
    }

    if (_destinationRequestIds[index] != requestId) return;
    _setDestinationAt(
      index,
      (d) => d.copyWith(suggestions: results, suggestionsLoading: false),
    );
  }

  void selectDestinationSuggestion(int index, LocationEntity location) {
    _setDestinationAt(
      index,
      (d) => d.copyWith(location: location, suggestions: const []),
    );
  }

  void clearDestination(int index) {
    _destinationDebounces.remove(index)?.cancel();
    _setDestinationAt(
      index,
      (d) => d.copyWith(clearLocation: true, suggestions: const []),
    );
  }

  void _setDestinationAt(
    int index,
    DestinationField Function(DestinationField) update,
  ) {
    if (index < 0 || index >= state.destinations.length) return;
    final updated = [...state.destinations];
    updated[index] = update(updated[index]);
    state = state.copyWith(destinations: updated);
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

  // ── Vehicle ─────────────────────────────────────────────────────────────

  void selectVehicle(String? vehicleId) {
    state = state.copyWith(selectedVehicleId: vehicleId);
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  Future<void> submitPost() async {
    final origin = state.origin;
    final vehicleId = state.selectedVehicleId;
    final destinations = state.destinations
        .map((d) => d.location)
        .whereType<LocationEntity>()
        .toList();
    if (origin == null || vehicleId == null || destinations.isEmpty) return;

    state = state.copyWith(submission: const PostSubmitting());
    try {
      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) throw const ApiException();

      final post = await ref.read(submitPostUseCaseProvider).execute(
            userId: userId,
            vehicleId: vehicleId,
            origin: origin,
            destinations: destinations,
            currentLocation: origin,
            availableDate: DateTime.now(),
          );
      state = state.copyWith(submission: PostDone(post));
    } catch (e) {
      state = state.copyWith(
        submission: PostError(ApiException.messageFor(e)),
      );
    }
  }

  void resetSubmission() => state = state.copyWith(submission: const PostIdle());
}
