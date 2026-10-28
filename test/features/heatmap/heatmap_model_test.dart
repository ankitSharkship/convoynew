import 'package:convoynew/features/heatmap/data/models/heatmap_model.dart';
import 'package:convoynew/features/heatmap/domain/entities/heatmap_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the server response', () {
    final heatmap = HeatmapModel.fromJson(
      {
        'success': true,
        'type': 'trucks',
        'resolution': 7,
        'minCellActivity': 1,
        'cellCount': 2,
        'truncated': false,
        'cells': [
          {'h3Cell': '8761a', 'centerLat': 28.6, 'centerLng': 77.2, 'count': 4},
          {'h3Cell': '8761b', 'centerLat': 19, 'centerLng': 72, 'count': 1},
        ],
      },
      kind: HeatmapKind.trucks,
      requestedResolution: 7,
    );
    expect(heatmap.kind, HeatmapKind.trucks);
    expect(heatmap.resolution, 7);
    expect(heatmap.cells, hasLength(2));
    expect(heatmap.cells.first.lat, 28.6);
    expect(heatmap.cells.last.lng, 72.0); // JSON ints widen to double
    expect(heatmap.cells.first.count, 4);
  });

  test('drops malformed cells instead of failing the whole map', () {
    final heatmap = HeatmapModel.fromJson(
      {
        'resolution': 6,
        'cells': [
          {'h3Cell': 'ok', 'centerLat': 1.0, 'centerLng': 2.0, 'count': 3},
          {'h3Cell': 'no-count', 'centerLat': 1.0, 'centerLng': 2.0},
          {'h3Cell': 'bad-lat', 'centerLat': 'x', 'centerLng': 2.0, 'count': 1},
          {'h3Cell': 'zero', 'centerLat': 1.0, 'centerLng': 2.0, 'count': 0},
          'not a map',
          null,
        ],
      },
      kind: HeatmapKind.reels,
      requestedResolution: 6,
    );
    expect(heatmap.cells.map((c) => c.h3Cell), ['ok']);
  });

  test('tolerates a missing or malformed cells list and missing metadata', () {
    final heatmap = HeatmapModel.fromJson(
      {'cells': 'nope'},
      kind: HeatmapKind.reels,
      requestedResolution: 5,
    );
    expect(heatmap.cells, isEmpty);
    expect(heatmap.resolution, 5); // falls back to what was requested
    expect(heatmap.minCellActivity, 1);
    expect(heatmap.truncated, isFalse);
  });

  test('keeps the privacy threshold the server reports', () {
    final heatmap = HeatmapModel.fromJson(
      {'resolution': 9, 'minCellActivity': 3, 'truncated': true, 'cells': []},
      kind: HeatmapKind.trucks,
      requestedResolution: 9,
    );
    expect(heatmap.minCellActivity, 3);
    expect(heatmap.truncated, isTrue);
  });
}
