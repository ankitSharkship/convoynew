import 'dart:math' as math;
import 'dart:typed_data';

import 'package:convoynew/features/heatmap/presentation/rendering/heat_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('heatResolutionForZoom', () {
    test('follows the web POC zoom steps', () {
      expect(heatResolutionForZoom(0), 4);
      expect(heatResolutionForZoom(5.99), 4);
      expect(heatResolutionForZoom(6), 5);
      expect(heatResolutionForZoom(7.9), 5);
      expect(heatResolutionForZoom(8), 6);
      expect(heatResolutionForZoom(10), 7);
      expect(heatResolutionForZoom(12), 8);
      expect(heatResolutionForZoom(14), 9);
      expect(heatResolutionForZoom(18), 9);
    });

    test('only ever asks for resolutions the server accepts (3..9)', () {
      for (var z = 0.0; z <= 22; z += 0.25) {
        expect(heatResolutionForZoom(z), inInclusiveRange(3, 9));
      }
    });
  });

  group('radius and opacity', () {
    test('radius in pixels stays inside the readable clamp', () {
      for (final res in heatRadiusMetersByResolution.keys) {
        for (var z = 3.0; z <= 18; z += 1) {
          final px = heatRadiusPx(
            20,
            z,
            heatRadiusMetersForResolution(res),
          );
          expect(px, inInclusiveRange(heatMinRadiusPx, heatMaxRadiusPx));
        }
      }
    });

    test('layer is stronger zoomed out and lighter zoomed in', () {
      expect(heatLayerOpacity(3), heatLayerOpacityOut);
      expect(heatLayerOpacity(14), heatLayerOpacityIn);
      expect(heatLayerOpacity(9), inExclusiveRange(heatLayerOpacityIn, heatLayerOpacityOut));
    });

    test('meters per pixel halves with each zoom level', () {
      expect(
        heatMetersPerPixel(0, 5) / heatMetersPerPixel(0, 6),
        closeTo(2, 1e-9),
      );
    });
  });

  group('computeHeatWeights', () {
    test('empty input gives empty output', () {
      final w = computeHeatWeights(lats: [], lngs: [], counts: [], resolution: 6);
      expect(w, isEmpty);
    });

    test('weights stay within [floor, 1] and rank by count', () {
      final w = computeHeatWeights(
        lats: [28.6, 19.0, 13.0],
        lngs: [77.2, 72.9, 80.2],
        counts: [100, 25, 1],
        resolution: 6,
      );
      for (final v in w) {
        expect(v, inInclusiveRange(0.06, 1.0));
      }
      expect(w[0], greaterThan(w[1]));
      expect(w[1], greaterThan(w[2]));
      // An isolated top cell's own core (1) + halo (0.2) sets the global peak.
      expect(w[0], closeTo(1 / (1 + heatHaloAlpha), 1e-9));
    });

    test('the densest overlap of blobs builds up to exactly full strength', () {
      // A tight cluster of equal cells: every one overlaps all the others, so
      // each is scaled down until the summed overlap at the densest centre is 1.
      final lats = <double>[];
      final lngs = <double>[];
      for (var i = 0; i < 7; i++) {
        lats.add(28.6 + 0.02 * math.sin(i));
        lngs.add(77.2 + 0.02 * math.cos(i));
      }
      final w = computeHeatWeights(
        lats: lats,
        lngs: lngs,
        counts: List.filled(7, 5),
        resolution: 6,
      );
      expect(w.every((v) => v < 1.0), isTrue);
      expect(w.every((v) => (v - w.first).abs() < 1e-9), isTrue);

      final radius = heatRadiusMetersForResolution(6);
      final kx = 111320 * math.cos(28.6 * math.pi / 180);
      var best = 0.0;
      for (var i = 0; i < 7; i++) {
        var sum = 0.0;
        for (var j = 0; j < 7; j++) {
          final dx = (lngs[i] - lngs[j]) * kx;
          final dy = (lats[i] - lats[j]) * 110574;
          final t2 = (dx * dx + dy * dy) / (radius * radius);
          var k = t2 < 1 ? math.exp(-4.5 * t2) * (1 - t2 * t2 * t2) : 0.0;
          final h2 = (dx * dx + dy * dy) /
              (radius * heatHaloScale * radius * heatHaloScale);
          k += heatHaloAlpha * math.exp(-4.5 * h2) * (1 - h2 * h2 * h2);
          sum += w[j] * k;
        }
        best = math.max(best, sum);
      }
      expect(best, closeTo(1.0, 1e-6));
    });

    test('one global scale: a dense cluster sets it, equal cells weigh the same',
        () {
      // Like the web POC, every cell is scaled by the single densest spot, so a
      // lone cell elsewhere is no brighter than a cluster member with the same
      // count (and dimmer than it would be on its own).
      final w = computeHeatWeights(
        lats: [28.6, 28.61, 28.62, 12.9],
        lngs: [77.2, 77.21, 77.19, 77.6],
        counts: [10, 10, 10, 10],
        resolution: 6,
      );
      expect(w[3], closeTo(w[0], 1e-9));
      expect(w[3], lessThan(1 / (1 + heatHaloAlpha)));
    });

    test('scales to thousands of cells quickly (spatial hash, not O(n^2))', () {
      final rng = math.Random(7);
      const n = 5000;
      final stopwatch = Stopwatch()..start();
      computeHeatWeights(
        lats: [for (var i = 0; i < n; i++) 8 + rng.nextDouble() * 24],
        lngs: [for (var i = 0; i < n; i++) 68 + rng.nextDouble() * 29],
        counts: [for (var i = 0; i < n; i++) 1 + rng.nextInt(50)],
        resolution: 7,
      );
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });

  group('palette', () {
    test('starts fully transparent and ends hot, premultiplied', () {
      final p = buildHeatPalette();
      expect(p.length, 1024);
      expect(p[3], 0);
      expect(p[1023], closeTo(0.92 * 255, 1));
      for (var i = 0; i < 256; i++) {
        final a = p[i * 4 + 3];
        expect(p[i * 4], lessThanOrEqualTo(a));
        expect(p[i * 4 + 1], lessThanOrEqualTo(a));
        expect(p[i * 4 + 2], lessThanOrEqualTo(a));
      }
    });
  });

  group('renderHeatPixels', () {
    test('no blobs renders fully transparent', () {
      final out = renderHeatPixels(
        HeatRenderRequest(width: 20, height: 10, blobs: Float32List(0)),
      );
      expect(out.length, 20 * 10 * 4);
      expect(out.every((b) => b == 0), isTrue);
    });

    test('a blob lights up its centre and leaves the far corner clear', () {
      final out = renderHeatPixels(
        HeatRenderRequest(
          width: 100,
          height: 100,
          blobs: Float32List.fromList([50, 50, 12, 1.0]),
        ),
      );
      int alphaAt(int x, int y) => out[(y * 100 + x) * 4 + 3];
      expect(alphaAt(50, 50), greaterThan(150));
      expect(alphaAt(50, 50), greaterThan(alphaAt(50, 62)));
      expect(alphaAt(0, 0), 0);
    });

    test('overlapping blobs are hotter than a lone one', () {
      final lone = renderHeatPixels(
        HeatRenderRequest(
          width: 80,
          height: 80,
          blobs: Float32List.fromList([40, 40, 10, 0.4]),
        ),
      );
      final stacked = renderHeatPixels(
        HeatRenderRequest(
          width: 80,
          height: 80,
          blobs: Float32List.fromList([40, 40, 10, 0.4, 42, 40, 10, 0.4]),
        ),
      );
      final centre = (40 * 80 + 40) * 4 + 3;
      expect(stacked[centre], greaterThan(lone[centre]));
    });

    test('blobs outside the field are ignored without error', () {
      final out = renderHeatPixels(
        HeatRenderRequest(
          width: 30,
          height: 30,
          blobs: Float32List.fromList([500, 500, 10, 1.0, -300, -20, 10, 1.0]),
        ),
      );
      expect(out.every((b) => b == 0), isTrue);
    });

    test('a blob straddling the edge is clipped, not wrapped', () {
      final out = renderHeatPixels(
        HeatRenderRequest(
          width: 40,
          height: 40,
          blobs: Float32List.fromList([0, 20, 10, 1.0]),
        ),
      );
      expect(out[(20 * 40 + 0) * 4 + 3], greaterThan(0));
      expect(out[(20 * 40 + 39) * 4 + 3], 0); // far edge untouched
    });
  });
}
