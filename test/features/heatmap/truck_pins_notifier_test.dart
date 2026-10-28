import 'dart:async';

import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/heatmap/domain/entities/geo_box.dart';
import 'package:convoynew/features/heatmap/domain/entities/truck_pin_entity.dart';
import 'package:convoynew/features/heatmap/domain/failures/truck_post_unavailable_exception.dart';
import 'package:convoynew/features/heatmap/domain/repositories/truck_pins_repository.dart';
import 'package:convoynew/features/heatmap/domain/usecases/truck_pins_usecases.dart';
import 'package:convoynew/features/heatmap/presentation/state/truck_pins_notifier.dart';
import 'package:convoynew/features/search/domain/entities/truck_search_result_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _city = GeoBox(minLat: 28.5, minLng: 77.1, maxLat: 28.7, maxLng: 77.3);

TruckPinsEntity _pins(List<String> ids, {bool truncated = false}) =>
    TruckPinsEntity(
      truncated: truncated,
      pins: [
        for (final id in ids)
          TruckPinEntity(id: id, lat: 28.6, lng: 77.2, truckType: 'Open Body', capacity: 9),
      ],
    );

class _FakeRepository implements TruckPinsRepository {
  final List<(GeoBox, Completer<TruckPinsEntity>)> pinCalls = [];
  final List<String> detailCalls = [];
  Object? detailError;

  @override
  Future<TruckPinsEntity> getPins(GeoBox box) {
    final completer = Completer<TruckPinsEntity>();
    pinCalls.add((box, completer));
    return completer.future;
  }

  @override
  Future<TruckSearchResultEntity> getPostDetail(String postId) async {
    detailCalls.add(postId);
    if (detailError != null) throw detailError!;
    throw UnimplementedError('detail success is covered by the model tests');
  }
}

void main() {
  late _FakeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeRepository();
    container = ProviderContainer(
      overrides: [
        getTruckPinsUseCaseProvider.overrideWithValue(GetTruckPinsUseCase(repository)),
        getTruckPostDetailUseCaseProvider.overrideWithValue(
          GetTruckPostDetailUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  TruckPinsState read() => container.read(truckPinsNotifierProvider);
  TruckPinsNotifier notifier() => container.read(truckPinsNotifierProvider.notifier);

  test('starts empty and not loaded', () {
    expect(read().hasLoaded, isFalse);
    expect(read().pins, isEmpty);
  });

  test('fetches the viewport padded, and exposes the pins', () async {
    final future = notifier().ensureCovering(_city);
    expect(read().loading, isTrue);
    final requested = repository.pinCalls.single.$1;
    expect(requested.containsBox(_city), isTrue);
    expect(requested.latSpan, greaterThan(_city.latSpan)); // padded

    repository.pinCalls.single.$2.complete(_pins(['a', 'b']));
    await future;
    expect(read().loading, isFalse);
    expect(read().hasLoaded, isTrue);
    expect(read().pins.map((p) => p.id), ['a', 'b']);
  });

  test('a small pan inside the fetched area costs no request', () async {
    final first = notifier().ensureCovering(_city);
    repository.pinCalls.single.$2.complete(_pins(['a']));
    await first;

    const panned = GeoBox(minLat: 28.52, minLng: 77.13, maxLat: 28.72, maxLng: 77.33);
    await notifier().ensureCovering(panned);
    expect(repository.pinCalls, hasLength(1));
  });

  test('panning outside the fetched area fetches again', () async {
    final first = notifier().ensureCovering(_city);
    repository.pinCalls.single.$2.complete(_pins(['a']));
    await first;

    const far = GeoBox(minLat: 19.0, minLng: 72.8, maxLat: 19.2, maxLng: 73.0);
    final second = notifier().ensureCovering(far);
    expect(repository.pinCalls, hasLength(2));
    repository.pinCalls.last.$2.complete(_pins(['m']));
    await second;
    expect(read().pins.single.id, 'm');
  });

  test('after a truncated result, a noticeable pan refetches even inside the area', () async {
    final first = notifier().ensureCovering(_city);
    repository.pinCalls.single.$2.complete(_pins(['a'], truncated: true));
    await first;
    expect(read().truncated, isTrue);

    // Still inside the padded box, but the centre moved by a third of the screen.
    const shifted = GeoBox(minLat: 28.5, minLng: 77.17, maxLat: 28.7, maxLng: 77.37);
    final second = notifier().ensureCovering(shifted);
    expect(repository.pinCalls, hasLength(2));
    repository.pinCalls.last.$2.complete(_pins(['b']));
    await second;
  });

  test('force bypasses the reuse check', () async {
    final first = notifier().ensureCovering(_city);
    repository.pinCalls.single.$2.complete(_pins(['a']));
    await first;

    final forced = notifier().ensureCovering(_city, force: true);
    expect(repository.pinCalls, hasLength(2));
    repository.pinCalls.last.$2.complete(_pins(['a', 'z']));
    await forced;
    expect(read().pins, hasLength(2));
  });

  test('a slow answer for an old viewport cannot overwrite a newer one', () async {
    final slow = notifier().ensureCovering(_city);
    const other = GeoBox(minLat: 19.0, minLng: 72.8, maxLat: 19.2, maxLng: 73.0);
    final fast = notifier().ensureCovering(other);
    repository.pinCalls[1].$2.complete(_pins(['mumbai']));
    await fast;
    repository.pinCalls[0].$2.complete(_pins(['delhi']));
    await slow;

    expect(read().pins.single.id, 'mumbai');
    expect(read().loading, isFalse);
  });

  test('failure keeps the previous pins and flags the error; the next move retries', () async {
    final ok = notifier().ensureCovering(_city);
    repository.pinCalls.single.$2.complete(_pins(['a']));
    await ok;

    final failing = notifier().ensureCovering(_city, force: true);
    repository.pinCalls.last.$2.completeError(const ApiException());
    await failing; // never throws

    expect(read().hasError, isTrue);
    expect(read().loading, isFalse);
    expect(read().pins.single.id, 'a');

    // Even a view the old data covered is fetched again after an error.
    final retry = notifier().ensureCovering(_city);
    expect(repository.pinCalls, hasLength(3));
    repository.pinCalls.last.$2.complete(_pins(['a', 'b']));
    await retry;
    expect(read().hasError, isFalse);
    expect(read().pins, hasLength(2));
  });

  test('fetchDetail passes a gone post through as TruckPostUnavailableException', () async {
    repository.detailError = const TruckPostUnavailableException();
    await expectLater(
      notifier().fetchDetail('p1'),
      throwsA(isA<TruckPostUnavailableException>()),
    );
    expect(repository.detailCalls, ['p1']);
  });
}
