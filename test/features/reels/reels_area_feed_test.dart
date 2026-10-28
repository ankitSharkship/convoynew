import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convoynew/core/network/token_storage.dart';
import 'package:convoynew/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:convoynew/features/reels/domain/entities/reel_entity.dart';
import 'package:convoynew/features/reels/domain/entities/reels_feed_key.dart';
import 'package:convoynew/features/reels/domain/repositories/reels_repository.dart';
import 'package:convoynew/features/reels/domain/usecases/get_reels_usecase.dart';
import 'package:convoynew/features/reels/presentation/state/reels_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ReelEntity _reel(String id) => ReelEntity(
  id: id,
  userId: 'u',
  title: 'Reel $id',
  status: 'ready',
  createdAt: DateTime(2026, 10, 1),
);

/// Answers `getReels` from a queue the test controls and records each call.
class _FakeReelsRepository implements ReelsRepository {
  final calls = <({int offset, String? categoryId, String? areaCell, ReelsSort sort})>[];
  final pages = <ReelsPageEntity>[];

  @override
  Future<ReelsPageEntity> getReels({
    required int limit,
    required int offset,
    String? categoryId,
    String? areaCell,
    ReelsSort sort = ReelsSort.latest,
  }) async {
    calls.add((offset: offset, categoryId: categoryId, areaCell: areaCell, sort: sort));
    return pages.removeAt(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A Dio whose every response is [body], recording the request it received.
class _RecordingAdapter implements HttpClientAdapter {
  final Map<String, dynamic> body;
  RequestOptions? last;

  _RecordingAdapter(this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('datasource', () {
    Future<(_RecordingAdapter, ReelsPageEntity)> fetch({
      required Map<String, dynamic> body,
      String? areaCell,
      ReelsSort sort = ReelsSort.latest,
    }) async {
      final adapter = _RecordingAdapter(body);
      final dio = Dio()..httpClientAdapter = adapter;
      // ignore: avoid_dynamic_calls
      final remote = ReelsRemoteDataSourceImpl(dio, _NoTokens());
      final page = await remote.getReels(
        limit: 10,
        offset: 0,
        areaCell: areaCell,
        sort: sort,
      );
      return (adapter, page);
    }

    test('the plain feed request is unchanged (no area, no sort)', () async {
      final (adapter, page) = await fetch(
        body: {'reels': [], 'total': 0, 'offset': 0},
      );
      expect(adapter.last!.queryParameters.keys, containsAll(['limit', 'offset']));
      expect(adapter.last!.queryParameters.containsKey('h3Cell'), isFalse);
      expect(adapter.last!.queryParameters.containsKey('sort'), isFalse);
      expect(page.area, isNull);
    });

    test('an area request sends h3Cell and sort, and parses the area info', () async {
      final (adapter, page) = await fetch(
        areaCell: '8642c084fffffff',
        sort: ReelsSort.popular,
        body: {
          'reels': [],
          'total': 68,
          'offset': 0,
          'area': {
            'h3Cell': '8642c084fffffff',
            'resolution': 6,
            'label': 'Kandla, Gujarat',
            'total': 68,
            'capped': false,
          },
        },
      );
      expect(adapter.last!.queryParameters['h3Cell'], '8642c084fffffff');
      expect(adapter.last!.queryParameters['sort'], 'popular');
      expect(page.area!.label, 'Kandla, Gujarat');
      expect(page.area!.total, 68);
      expect(page.area!.h3Cell, '8642c084fffffff');
    });

    test('an area without a label is fine; a malformed area is ignored', () async {
      final (_, withoutLabel) = await fetch(
        areaCell: 'c',
        body: {
          'reels': [],
          'total': 0,
          'area': {'h3Cell': 'c', 'label': null, 'total': 0},
        },
      );
      expect(withoutLabel.area!.label, isNull);
      final (_, malformed) = await fetch(
        areaCell: 'c',
        body: {'reels': [], 'total': 0, 'area': 'nope'},
      );
      expect(malformed.area, isNull);
    });
  });

  group('feed notifier', () {
    late _FakeReelsRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeReelsRepository();
      container = ProviderContainer(
        overrides: [
          getReelsUseCaseProvider.overrideWithValue(GetReelsUseCase(repository)),
        ],
      );
      addTearDown(container.dispose);
    });

    // The feed is auto-disposed, so keep it alive for the duration of a test.
    ReelsFeedState load(ReelsFeedKey key) {
      container.listen(reelsFeedNotifierProvider(key), (_, _) {});
      return container.read(reelsFeedNotifierProvider(key));
    }

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('a plain feed asks for newest-first with no area', () async {
      repository.pages.add(ReelsPageEntity(items: [_reel('a')], hasMore: false));
      load(const ReelsFeedKey());
      await settle();
      expect(repository.calls.single.areaCell, isNull);
      expect(repository.calls.single.sort, ReelsSort.latest);
    });

    test('an area feed asks for that area, popular, and keeps the area info', () async {
      repository.pages.add(
        ReelsPageEntity(
          items: [_reel('a'), _reel('b')],
          hasMore: false,
          area: const ReelsAreaEntity(h3Cell: 'cell', label: 'Delhi, Delhi', total: 2),
        ),
      );
      const key = ReelsFeedKey(areaCell: 'cell');
      load(key);
      await settle();
      expect(repository.calls.single.areaCell, 'cell');
      expect(repository.calls.single.sort, ReelsSort.popular);
      final state = container.read(reelsFeedNotifierProvider(key));
      expect(state.items.map((r) => r.id), ['a', 'b']);
      expect(state.area!.label, 'Delhi, Delhi');
    });

    test('a category narrows the area feed further', () async {
      repository.pages.add(ReelsPageEntity(items: [], hasMore: false));
      load(const ReelsFeedKey(categoryId: 'c1', areaCell: 'cell'));
      await settle();
      expect(repository.calls.single.categoryId, 'c1');
      expect(repository.calls.single.areaCell, 'cell');
    });

    test('a reel that comes back on the next page is not shown twice', () async {
      repository.pages
        ..add(ReelsPageEntity(items: [_reel('a'), _reel('b')], hasMore: true))
        // popularity moved between requests: "b" returns, plus a new one.
        ..add(ReelsPageEntity(items: [_reel('b'), _reel('c')], hasMore: false));
      const key = ReelsFeedKey(areaCell: 'cell');
      load(key);
      await settle();
      await container.read(reelsFeedNotifierProvider(key).notifier).loadNextPage();
      final ids = container.read(reelsFeedNotifierProvider(key)).items.map((r) => r.id);
      expect(ids, ['a', 'b', 'c']);
    });

    test('refresh replaces the list and keeps asking for the same area', () async {
      repository.pages
        ..add(ReelsPageEntity(items: [_reel('a')], hasMore: false))
        ..add(
          ReelsPageEntity(
            items: [_reel('z')],
            hasMore: false,
            area: const ReelsAreaEntity(h3Cell: 'cell', total: 1),
          ),
        );
      const key = ReelsFeedKey(areaCell: 'cell');
      load(key);
      await settle();
      await container.read(reelsFeedNotifierProvider(key).notifier).refresh();
      final state = container.read(reelsFeedNotifierProvider(key));
      expect(state.items.map((r) => r.id), ['z']);
      expect(repository.calls.last.areaCell, 'cell');
      expect(repository.calls.last.offset, 0);
    });

    test('two feeds with different keys are loaded separately', () async {
      repository.pages
        ..add(ReelsPageEntity(items: [_reel('plain')], hasMore: false))
        ..add(ReelsPageEntity(items: [_reel('area')], hasMore: false));
      load(const ReelsFeedKey());
      load(const ReelsFeedKey(areaCell: 'cell'));
      await settle();
      expect(container.read(reelsFeedNotifierProvider(const ReelsFeedKey())).items.single.id, 'plain');
      expect(
        container.read(reelsFeedNotifierProvider(const ReelsFeedKey(areaCell: 'cell'))).items.single.id,
        'area',
      );
    });
  });

  group('appendNewReels', () {
    test('keeps order, drops ids already present, and dedupes within a page', () {
      final result = appendNewReels(
        [_reel('a'), _reel('b')],
        [_reel('b'), _reel('c'), _reel('c'), _reel('d')],
      );
      expect(result.map((r) => r.id), ['a', 'b', 'c', 'd']);
    });
  });

  group('selected area', () {
    test('survives with nobody listening (the heatmap sets it before the Reels tab exists)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedReelAreaProvider.notifier).select('cell');
      await Future<void>.delayed(const Duration(milliseconds: 50)); // let a frame's worth of disposal run
      expect(container.read(selectedReelAreaProvider), 'cell');
      container.read(selectedReelAreaProvider.notifier).select(null);
      expect(container.read(selectedReelAreaProvider), isNull);
    });
  });
}

class _NoTokens implements TokenStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
