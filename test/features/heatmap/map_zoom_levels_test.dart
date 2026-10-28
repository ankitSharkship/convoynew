import 'package:convoynew/features/heatmap/presentation/rendering/heat_field.dart';
import 'package:convoynew/features/heatmap/presentation/rendering/map_zoom_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('truckPinsModeFor', () {
    test('zoomed out is heat, a city on screen is pins', () {
      expect(truckPinsModeFor(5, currentlyPins: false), isFalse);
      expect(truckPinsModeFor(11.99, currentlyPins: false), isFalse);
      expect(truckPinsModeFor(12.0, currentlyPins: false), isTrue);
      expect(truckPinsModeFor(16, currentlyPins: false), isTrue);
    });

    test('has hysteresis: pins stay until a little below the enter zoom', () {
      expect(truckPinsModeFor(11.9, currentlyPins: true), isTrue);
      expect(truckPinsModeFor(11.8, currentlyPins: true), isTrue);
      expect(truckPinsModeFor(11.79, currentlyPins: true), isFalse);
      // ...and heat does not flip to pins until the full enter zoom.
      expect(truckPinsModeFor(11.9, currentlyPins: false), isFalse);
    });

    test('hovering around the boundary never flickers every frame', () {
      var pins = false;
      var flips = 0;
      for (final z in [11.95, 12.0, 11.95, 11.9, 11.85, 12.0, 11.9, 11.82]) {
        final next = truckPinsModeFor(z, currentlyPins: pins);
        if (next != pins) flips++;
        pins = next;
      }
      expect(flips, 1); // switched to pins once at 12.0 and stayed
    });

    test('exit is below enter', () {
      expect(truckPinsExitZoom, lessThan(truckPinsEnterZoom));
    });
  });

  group('pinGroupingCellPx', () {
    test('groups into big cells below 15, overlaps only up to 17.5, none above', () {
      expect(pinGroupingCellPx(12), pinClusterCellPx);
      expect(pinGroupingCellPx(14.99), pinClusterCellPx);
      expect(pinGroupingCellPx(15), pinOverlapCellPx);
      expect(pinGroupingCellPx(17.49), pinOverlapCellPx);
      expect(pinGroupingCellPx(17.5), isNull);
      expect(pinGroupingCellPx(18), isNull);
    });

    test('the overlap cell is finer than the cluster cell', () {
      expect(pinOverlapCellPx, lessThan(pinClusterCellPx));
    });
  });

  group('groupByGrid', () {
    test('every point lands in exactly one group', () {
      final points = [
        for (var i = 0; i < 200; i++) ((i * 37 % 500).toDouble(), (i * 91 % 700).toDouble()),
      ];
      final groups = groupByGrid(points, 70);
      final all = groups.expand((g) => g).toList()..sort();
      expect(all, List.generate(200, (i) => i));
    });

    test('points in the same cell group together, different cells stay apart', () {
      final groups = groupByGrid(
        [(10, 10), (20, 30), (69, 69), (71, 10), (10, 71), (500, 500)],
        70,
      );
      groups.sort((a, b) => a.first.compareTo(b.first));
      expect(groups, [
        [0, 1, 2],
        [3],
        [4],
        [5],
      ]);
    });

    test('handles negative coordinates and the cell edges consistently', () {
      final groups = groupByGrid([(-1, 5), (-69, 5), (-71, 5), (0, 5)], 70);
      groups.sort((a, b) => a.first.compareTo(b.first));
      expect(groups, [
        [0, 1],
        [2],
        [3],
      ]);
    });

    test('empty input gives no groups', () {
      expect(groupByGrid([], 70), isEmpty);
    });
  });

  reelsZoomCapTests();
}

void reelsZoomCapTests() {
  group('Reels zoom cap', () {
    test('stops at city level, below where Trucks switch to pins', () {
      expect(reelsMaxZoom, lessThan(truckPinsEnterZoom));
      expect(reelsMaxZoom, greaterThanOrEqualTo(10)); // a city, not a country
    });

    test('Reels never reach the fine resolutions the server hides', () {
      // 8 and 9 only return cells with >= 3 reels; the Reels tab must not use them.
      expect(heatResolutionForZoom(reelsMaxZoom), lessThanOrEqualTo(7));
      for (var z = 0.0; z <= reelsMaxZoom; z += 0.1) {
        expect(heatResolutionForZoom(z), lessThanOrEqualTo(7));
      }
    });

    test('Trucks can still zoom to street level for the pins', () {
      expect(trucksMaxZoom, greaterThan(pinOverlapGroupBelowZoom));
    });
  });
}
