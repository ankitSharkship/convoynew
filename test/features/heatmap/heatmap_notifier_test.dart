import 'dart:async';

import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/heatmap/domain/entities/heatmap_entity.dart';
import 'package:convoynew/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:convoynew/features/heatmap/domain/usecases/get_heatmap_usecase.dart';
import 'package:convoynew/features/heatmap/presentation/state/heatmap_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

HeatmapEntity _heatmap(HeatmapKind kind, int resolution, int count) =>
    HeatmapEntity(
      kind: kind,
      resolution: resolution,
      minCellActivity: resolution >= 8 ? 3 : 1,
      truncated: false,
      cells: [
        HeatCellEntity(h3Cell: 'c$resolution', lat: 20, lng: 78, count: count),
      ],
    );

/// Answers each request from a completer the test controls, so it can decide
/// which response arrives first.
class _FakeRepository implements HeatmapRepository {
  final List<(HeatmapKind, int, Completer<HeatmapEntity>)> calls = [];

  @override
  Future<HeatmapEntity> getHeatmap(HeatmapKind kind, int resolution) {
    final completer = Completer<HeatmapEntity>();
    calls.add((kind, resolution, completer));
    return completer.future;
  }
}

void main() {
  late _FakeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeRepository();
    container = ProviderContainer(
      overrides: [
        getHeatmapUseCaseProvider.overrideWithValue(
          GetHeatmapUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  HeatmapLayerState read(HeatmapKind kind) =>
      container.read(heatmapNotifierProvider(kind));
  HeatmapNotifier notifier(HeatmapKind kind) =>
      container.read(heatmapNotifierProvider(kind).notifier);

  test('starts empty and not loaded', () {
    final s = read(HeatmapKind.trucks);
    expect(s.loading, isFalse);
    expect(s.hasLoaded, isFalse);
    expect(s.isEmpty, isFalse); // "not loaded yet" is not "loaded and empty"
  });

  test('loads a resolution and exposes its cells', () async {
    final future = notifier(HeatmapKind.trucks).ensureResolution(6);
    expect(read(HeatmapKind.trucks).loading, isTrue);
    expect(repository.calls.single.$1, HeatmapKind.trucks);
    expect(repository.calls.single.$2, 6);

    repository.calls.single.$3.complete(_heatmap(HeatmapKind.trucks, 6, 4));
    await future;

    final s = read(HeatmapKind.trucks);
    expect(s.loading, isFalse);
    expect(s.hasError, isFalse);
    expect(s.resolution, 6);
    expect(s.cells.single.count, 4);
  });

  test('a loaded response with no cells is "empty", not an error', () async {
    final future = notifier(HeatmapKind.reels).ensureResolution(9);
    repository.calls.single.$3.complete(
      HeatmapEntity(
        kind: HeatmapKind.reels,
        resolution: 9,
        minCellActivity: 3,
        truncated: false,
        cells: const [],
      ),
    );
    await future;
    final s = read(HeatmapKind.reels);
    expect(s.isEmpty, isTrue);
    expect(s.hasError, isFalse);
    expect(s.minCellActivity, 3);
  });

  test('a fresh cached resolution is reused without another request', () async {
    final first = notifier(HeatmapKind.trucks).ensureResolution(6);
    repository.calls.single.$3.complete(_heatmap(HeatmapKind.trucks, 6, 1));
    await first;

    final second = notifier(HeatmapKind.trucks).ensureResolution(6);
    await second;
    expect(repository.calls, hasLength(1));
    expect(read(HeatmapKind.trucks).loading, isFalse);
  });

  test('force bypasses the cache', () async {
    final first = notifier(HeatmapKind.trucks).ensureResolution(6);
    repository.calls.single.$3.complete(_heatmap(HeatmapKind.trucks, 6, 1));
    await first;

    final forced = notifier(HeatmapKind.trucks).ensureResolution(6, force: true);
    expect(repository.calls, hasLength(2));
    repository.calls.last.$3.complete(_heatmap(HeatmapKind.trucks, 6, 9));
    await forced;
    expect(read(HeatmapKind.trucks).cells.single.count, 9);
  });

  test('a slow answer for an old zoom cannot overwrite the newer one', () async {
    final slow = notifier(HeatmapKind.trucks).ensureResolution(5);
    final fast = notifier(HeatmapKind.trucks).ensureResolution(6);
    expect(repository.calls, hasLength(2));

    // Newer request (res 6) answers first, then the stale one (res 5).
    repository.calls[1].$3.complete(_heatmap(HeatmapKind.trucks, 6, 2));
    await fast;
    repository.calls[0].$3.complete(_heatmap(HeatmapKind.trucks, 5, 7));
    await slow;

    final s = read(HeatmapKind.trucks);
    expect(s.resolution, 6);
    expect(s.cells.single.count, 2);
    expect(s.loading, isFalse);
  });

  test('a stale failure cannot clobber a newer success', () async {
    final stale = notifier(HeatmapKind.trucks).ensureResolution(5);
    final current = notifier(HeatmapKind.trucks).ensureResolution(6);
    repository.calls[1].$3.complete(_heatmap(HeatmapKind.trucks, 6, 2));
    await current;
    repository.calls[0].$3.completeError(const ApiException());
    await stale;

    final s = read(HeatmapKind.trucks);
    expect(s.hasError, isFalse);
    expect(s.resolution, 6);
  });

  test('failure keeps the previous cells and flags the error; retry recovers',
      () async {
    final ok = notifier(HeatmapKind.trucks).ensureResolution(6);
    repository.calls.single.$3.complete(_heatmap(HeatmapKind.trucks, 6, 3));
    await ok;

    final failing = notifier(HeatmapKind.trucks).ensureResolution(7);
    repository.calls.last.$3.completeError(const ApiException());
    await failing; // never throws

    var s = read(HeatmapKind.trucks);
    expect(s.hasError, isTrue);
    expect(s.loading, isFalse);
    expect(s.resolution, 6); // still showing what worked
    expect(s.cells.single.count, 3);

    final retry = notifier(HeatmapKind.trucks).ensureResolution(7, force: true);
    repository.calls.last.$3.complete(_heatmap(HeatmapKind.trucks, 7, 5));
    await retry;
    s = read(HeatmapKind.trucks);
    expect(s.hasError, isFalse);
    expect(s.resolution, 7);
  });

  test('trucks and reels keep separate state and caches', () async {
    final t = notifier(HeatmapKind.trucks).ensureResolution(6);
    final r = notifier(HeatmapKind.reels).ensureResolution(6);
    expect(repository.calls, hasLength(2));
    repository.calls[0].$3.complete(_heatmap(HeatmapKind.trucks, 6, 11));
    repository.calls[1].$3.complete(_heatmap(HeatmapKind.reels, 6, 22));
    await Future.wait([t, r]);

    expect(read(HeatmapKind.trucks).cells.single.count, 11);
    expect(read(HeatmapKind.reels).cells.single.count, 22);
  });
}
