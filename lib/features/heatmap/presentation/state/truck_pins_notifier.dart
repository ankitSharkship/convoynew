import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../../data/datasources/truck_pins_remote_datasource.dart';
import '../../data/repositories/truck_pins_repository_impl.dart';
import '../../domain/entities/geo_box.dart';
import '../../domain/entities/truck_pin_entity.dart';
import '../../domain/usecases/truck_pins_usecases.dart';

part 'truck_pins_notifier.g.dart';

/// How long fetched pins are trusted before the next map move refetches them.
const truckPinsCacheTtl = Duration(seconds: 60);

/// The area fetched around the screen, as a fraction of the screen on each side,
/// so small pans stay inside it and cost no request.
const _fetchPadding = 0.5;

/// When the server cut the result off (keeping the pins nearest the centre), a pan
/// of more than this fraction of the screen refetches — the new view may show
/// trucks the cut-off result left out.
const _truncatedRefetchShift = 0.15;

@riverpod
TruckPinsRemoteDataSource truckPinsRemoteDataSource(
  TruckPinsRemoteDataSourceRef ref,
) {
  return TruckPinsRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
TruckPinsRepositoryImpl truckPinsRepository(TruckPinsRepositoryRef ref) {
  return TruckPinsRepositoryImpl(ref.watch(truckPinsRemoteDataSourceProvider));
}

@riverpod
GetTruckPinsUseCase getTruckPinsUseCase(GetTruckPinsUseCaseRef ref) {
  return GetTruckPinsUseCase(ref.watch(truckPinsRepositoryProvider));
}

@riverpod
GetTruckPostDetailUseCase getTruckPostDetailUseCase(
  GetTruckPostDetailUseCaseRef ref,
) {
  return GetTruckPostDetailUseCase(ref.watch(truckPinsRepositoryProvider));
}

class TruckPinsState {
  /// A request is in flight. [pins] (if any) are still the previous result.
  final bool loading;

  /// The last request failed. [pins] (if any) are still the previous result.
  final bool hasError;
  final bool isConnectivityIssue;

  final List<TruckPinEntity> pins;
  final bool truncated;

  /// Whether a request has ever succeeded (so "no pins" can mean "none here").
  final bool hasLoaded;

  const TruckPinsState({
    this.loading = false,
    this.hasError = false,
    this.isConnectivityIssue = false,
    this.pins = const [],
    this.truncated = false,
    this.hasLoaded = false,
  });
}

/// Live truck pins for the part of the map on screen. Kept alive so leaving the
/// tab and coming back doesn't throw the pins away.
@Riverpod(keepAlive: true)
class TruckPinsNotifier extends _$TruckPinsNotifier {
  /// Incremented per request; a response is applied only if no newer request has
  /// started, so a slow answer for an old viewport can't overwrite a newer one.
  int _requestToken = 0;

  GeoBox? _fetchedBox;
  GeoBox? _fetchedViewport;
  DateTime? _fetchedAt;

  @override
  TruckPinsState build() => const TruckPinsState();

  bool _canReuse(GeoBox viewport) {
    final box = _fetchedBox;
    final fetchedViewport = _fetchedViewport;
    final at = _fetchedAt;
    if (box == null || fetchedViewport == null || at == null) return false;
    if (DateTime.now().difference(at) >= truckPinsCacheTtl) return false;
    if (!box.containsBox(viewport)) return false;
    if (state.truncated) {
      final shiftLat =
          (viewport.centerLat - fetchedViewport.centerLat).abs() /
          fetchedViewport.latSpan;
      final shiftLng =
          (viewport.centerLng - fetchedViewport.centerLng).abs() /
          fetchedViewport.lngSpan;
      if (shiftLat > _truncatedRefetchShift ||
          shiftLng > _truncatedRefetchShift) {
        return false;
      }
    }
    return true;
  }

  /// Makes sure pins covering [viewport] are loaded: reuses what's loaded if it
  /// still covers the view and is fresh, otherwise fetches the view plus some
  /// padding. [force] skips the reuse check (retry / refresh). Never throws —
  /// failures land in [TruckPinsState.hasError].
  Future<void> ensureCovering(GeoBox viewport, {bool force = false}) async {
    if (!force && !state.hasError && _canReuse(viewport)) return;

    final token = ++_requestToken;
    state = TruckPinsState(
      loading: true,
      pins: state.pins,
      truncated: state.truncated,
      hasLoaded: state.hasLoaded,
    );

    final request = viewport.padded(_fetchPadding);
    try {
      final result = await ref.read(getTruckPinsUseCaseProvider).execute(request);
      if (token != _requestToken) return;
      _fetchedBox = request;
      _fetchedViewport = viewport;
      _fetchedAt = DateTime.now();
      state = TruckPinsState(
        pins: result.pins,
        truncated: result.truncated,
        hasLoaded: true,
      );
    } catch (e) {
      if (token != _requestToken) return;
      _fetchedBox = null; // so the next map move retries
      state = TruckPinsState(
        hasError: true,
        isConnectivityIssue: ApiException.isConnectivityIssueFor(e),
        pins: state.pins,
        truncated: state.truncated,
        hasLoaded: state.hasLoaded,
      );
    }
  }

  /// Full details of one truck (shown when its pin is tapped). Throws
  /// [TruckPostUnavailableException] if the post expired since the pin loaded,
  /// or an [ApiException] for any other failure.
  Future<TruckSearchResultEntity> fetchDetail(String postId) =>
      ref.read(getTruckPostDetailUseCaseProvider).execute(postId);
}
