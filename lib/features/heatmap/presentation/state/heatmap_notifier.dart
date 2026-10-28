import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/heatmap_remote_datasource.dart';
import '../../data/repositories/heatmap_repository_impl.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../../domain/usecases/get_heatmap_usecase.dart';

part 'heatmap_notifier.g.dart';

/// How long a fetched resolution is reused before it's fetched again. Zooming
/// back and forth inside this window is instant and costs no requests.
const heatmapCacheTtl = Duration(minutes: 2);

@riverpod
HeatmapRemoteDataSource heatmapRemoteDataSource(
  HeatmapRemoteDataSourceRef ref,
) {
  return HeatmapRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
HeatmapRepositoryImpl heatmapRepository(HeatmapRepositoryRef ref) {
  return HeatmapRepositoryImpl(ref.watch(heatmapRemoteDataSourceProvider));
}

@riverpod
GetHeatmapUseCase getHeatmapUseCase(GetHeatmapUseCaseRef ref) {
  return GetHeatmapUseCase(ref.watch(heatmapRepositoryProvider));
}

class HeatmapLayerState {
  /// A request is in flight. [cells] (if any) are still the previous result.
  final bool loading;

  /// The last request failed. [cells] (if any) are still the previous result.
  final bool hasError;
  final bool isConnectivityIssue;

  /// H3 resolution [cells] belong to; null until the first load succeeds.
  final int? resolution;
  final int minCellActivity;
  final bool truncated;
  final List<HeatCellEntity> cells;

  const HeatmapLayerState({
    this.loading = false,
    this.hasError = false,
    this.isConnectivityIssue = false,
    this.resolution,
    this.minCellActivity = 1,
    this.truncated = false,
    this.cells = const [],
  });

  bool get hasLoaded => resolution != null;

  /// Loaded successfully, nothing to draw.
  bool get isEmpty => hasLoaded && cells.isEmpty;
}

class _CacheEntry {
  final HeatmapEntity heatmap;
  final DateTime fetchedAt;

  _CacheEntry(this.heatmap, this.fetchedAt);
}

/// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
/// the screen) doesn't throw the fetched resolutions away.
@Riverpod(keepAlive: true)
class HeatmapNotifier extends _$HeatmapNotifier {
  final Map<int, _CacheEntry> _cache = {};

  /// Incremented per network request; a response is applied only if no newer
  /// request has started since, so a slow answer for an old zoom level can't
  /// overwrite the newer one the user is actually looking at.
  int _requestToken = 0;

  @override
  HeatmapLayerState build(HeatmapKind kind) => const HeatmapLayerState();

  /// Makes [resolution] the one on screen: from cache if fresh, otherwise
  /// from the server. [force] skips the cache (pull-to-refresh / retry).
  /// Never throws — failures land in [HeatmapLayerState.hasError].
  Future<void> ensureResolution(int resolution, {bool force = false}) async {
    final cached = _cache[resolution];
    if (!force &&
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) < heatmapCacheTtl) {
      _requestToken++; // a still-running older request is now irrelevant
      _apply(cached.heatmap);
      return;
    }

    final token = ++_requestToken;
    state = HeatmapLayerState(
      loading: true,
      resolution: state.resolution,
      minCellActivity: state.minCellActivity,
      truncated: state.truncated,
      cells: state.cells,
    );

    try {
      final heatmap = await ref
          .read(getHeatmapUseCaseProvider)
          .execute(kind, resolution);
      _cache[resolution] = _CacheEntry(heatmap, DateTime.now());
      if (token != _requestToken) return;
      _apply(heatmap);
    } catch (e) {
      if (token != _requestToken) return;
      state = HeatmapLayerState(
        hasError: true,
        isConnectivityIssue: ApiException.isConnectivityIssueFor(e),
        resolution: state.resolution,
        minCellActivity: state.minCellActivity,
        truncated: state.truncated,
        cells: state.cells,
      );
    }
  }

  void _apply(HeatmapEntity heatmap) {
    state = HeatmapLayerState(
      resolution: heatmap.resolution,
      minCellActivity: heatmap.minCellActivity,
      truncated: heatmap.truncated,
      cells: heatmap.cells,
    );
  }
}
