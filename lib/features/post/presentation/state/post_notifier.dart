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
import '../../domain/entities/trip_entity.dart';
import '../../domain/usecases/edit_trip_usecase.dart';
import '../../domain/usecases/submit_post_usecase.dart';
import 'trips_notifier.dart';

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

@riverpod
EditTripUseCase editTripUseCase(EditTripUseCaseRef ref) {
  return EditTripUseCase(ref.watch(tripRepositoryProvider));
}

class DestinationField {
  final LocationEntity? location;
  final List<LocationEntity> suggestions;
  final bool suggestionsLoading;
  final bool suggestionsDismissed;

  const DestinationField({
    this.location,
    this.suggestions = const [],
    this.suggestionsLoading = false,
    this.suggestionsDismissed = false,
  });

  bool get showSuggestions =>
      !suggestionsDismissed && (suggestionsLoading || suggestions.isNotEmpty);

  DestinationField copyWith({
    LocationEntity? location,
    bool clearLocation = false,
    List<LocationEntity>? suggestions,
    bool? suggestionsLoading,
    bool? suggestionsDismissed,
  }) {
    return DestinationField(
      location: clearLocation ? null : (location ?? this.location),
      suggestions: suggestions ?? this.suggestions,
      suggestionsLoading: suggestionsLoading ?? this.suggestionsLoading,
      suggestionsDismissed: suggestionsDismissed ?? this.suggestionsDismissed,
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

/// Emitted after successfully saving changes to an existing trip (edit mode),
/// as opposed to [PostDone] which is for a newly created post.
class PostEditSaved extends PostState {
  const PostEditSaved();
}

enum ContactMode { me, someoneElse }

class PostFormState {
  final LocationEntity? origin;
  final bool originLocating;
  final List<DestinationField> destinations;
  final String? selectedVehicleId;
  final ContactMode contactMode;
  final String contactName;
  final String contactNumber;
  final PostState submission;
  final String? editingTripId;

  const PostFormState({
    this.origin,
    this.originLocating = false,
    this.destinations = const [DestinationField()],
    this.selectedVehicleId,
    this.contactMode = ContactMode.me,
    this.contactName = '',
    this.contactNumber = '',
    this.submission = const PostIdle(),
    this.editingTripId,
  });

  bool get isEditing => editingTripId != null;

  bool get canAddDestination => destinations.length < _maxDestinations;

  bool get contactNumberValid => contactNumber.length == 10;

  bool get contactValid =>
      contactMode == ContactMode.me ||
      (contactName.trim().isNotEmpty && contactNumberValid);

  bool get canSubmit =>
      origin != null &&
      destinations.isNotEmpty &&
      destinations.first.location != null &&
      selectedVehicleId != null &&
      contactValid &&
      submission is! PostSubmitting;

  PostFormState copyWith({
    LocationEntity? origin,
    bool clearOrigin = false,
    bool? originLocating,
    List<DestinationField>? destinations,
    String? selectedVehicleId,
    ContactMode? contactMode,
    String? contactName,
    String? contactNumber,
    PostState? submission,
    String? editingTripId,
  }) {
    return PostFormState(
      origin: clearOrigin ? null : (origin ?? this.origin),
      originLocating: originLocating ?? this.originLocating,
      destinations: destinations ?? this.destinations,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      contactMode: contactMode ?? this.contactMode,
      contactName: contactName ?? this.contactName,
      contactNumber: contactNumber ?? this.contactNumber,
      submission: submission ?? this.submission,
      editingTripId: editingTripId ?? this.editingTripId,
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
      final current = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
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
    _setDestinationAt(
      index,
      (d) => d.copyWith(clearLocation: true, suggestionsDismissed: false),
    );
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

  void dismissDestinationSuggestions(int index) {
    _setDestinationAt(index, (d) => d.copyWith(suggestionsDismissed: true));
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

  // ── Edit mode ───────────────────────────────────────────────────────────

  /// Prefills the form from an existing trip so the user can edit it.
  /// The origin field stays tied to `currentLocation` — refreshing it (GPS)
  /// re-detects the current location, matching how a fresh post works.
  void startEditing(TripEntity trip) {
    final hasContact = trip.contactName != null && trip.contactName!.isNotEmpty;
    final rawNumber = trip.contactNumber ?? '';
    final digits = rawNumber.replaceAll(RegExp(r'\D'), '');
    final contactNumber = digits.length > 10
        ? digits.substring(digits.length - 10)
        : digits;

    state = state.copyWith(
      origin: trip.currentLocation,
      destinations: trip.destinations.isEmpty
          ? const [DestinationField()]
          : trip.destinations
                .map((d) => DestinationField(location: d))
                .toList(),
      selectedVehicleId: trip.vehicleId,
      contactMode: hasContact ? ContactMode.someoneElse : ContactMode.me,
      contactName: trip.contactName ?? '',
      contactNumber: contactNumber,
      editingTripId: trip.id,
    );
  }

  // ── Contact ─────────────────────────────────────────────────────────────

  void setContactMode(ContactMode mode) {
    state = state.copyWith(
      contactMode: mode,
      contactName: mode == ContactMode.me ? '' : state.contactName,
      contactNumber: mode == ContactMode.me ? '' : state.contactNumber,
    );
  }

  void updateContactName(String value) {
    state = state.copyWith(contactName: value);
  }

  void updateContactNumber(String value) {
    state = state.copyWith(contactNumber: value.replaceAll(RegExp(r'\D'), ''));
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
    if (!state.contactValid) return;

    final isAltContact = state.contactMode == ContactMode.someoneElse;
    final contactName = isAltContact ? state.contactName.trim() : null;
    final contactNumber = isAltContact ? state.contactNumber : null;
    final editingTripId = state.editingTripId;

    state = state.copyWith(submission: const PostSubmitting());
    try {
      if (editingTripId != null) {
        await ref
            .read(editTripUseCaseProvider)
            .execute(
              tripId: editingTripId,
              vehicleId: vehicleId,
              destinations: destinations,
              currentLocation: origin,
              contactName: contactName,
              contactNumber: contactNumber,
            );
        state = state.copyWith(submission: const PostEditSaved());
        return;
      }

      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) throw const ApiException();

      final post = await ref
          .read(submitPostUseCaseProvider)
          .execute(
            userId: userId,
            vehicleId: vehicleId,
            origin: origin,
            destinations: destinations,
            currentLocation: origin,
            availableDate: DateTime.now(),
            contactName: contactName,
            contactNumber: contactNumber,
          );
      state = state.copyWith(submission: PostDone(post));
    } catch (e) {
      state = state.copyWith(submission: PostError(ApiException.messageFor(e)));
    }
  }

  void resetSubmission() =>
      state = state.copyWith(submission: const PostIdle());
}
