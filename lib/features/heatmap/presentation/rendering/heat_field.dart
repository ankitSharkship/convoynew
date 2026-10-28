// Heat field maths — a port of the BONUT web heatmap (bonut-map-poc,
// frontend/js/heatmap.js + state.js). Pure Dart with no Flutter imports, so it
// can run in an isolate and be unit-tested.
//
// How a heatmap is built:
//  1. The server returns H3 cells (centre + count) at a resolution chosen from
//     the map zoom ([heatResolutionForZoom]).
//  2. Every cell centre adds a soft, gaussian-like blob to a float "heat"
//     field. Overlapping blobs ADD UP, so neighbouring cells merge into one
//     continuous hotspot instead of separate circles.
//  3. Each blob is also given a much wider, very faint halo, so hotspots sit in
//     a continuous haze.
//  4. The strength of each blob is normalised ([computeHeatWeights]) so the
//     densest spot always builds up to the top (red) of the gradient,
//     whatever the zoom/resolution, and everything else is relative to it.
//  5. The accumulated value of each pixel picks its colour from a gradient
//     (transparent blue -> cyan -> green -> yellow -> orange -> red).
import 'dart:math' as math;
import 'dart:typed_data';

/// `[from zoom, H3 resolution]` — coarse cells zoomed out (a broad regional
/// glow), fine cells zoomed in (neighbourhood detail). Same steps as the web
/// POC; flutter_map zoom levels use the same 256px-tile scale as Google Maps.
const List<(double, int)> heatResolutionSteps = [
  (0, 4),
  (6, 5),
  (8, 6),
  (10, 7),
  (12, 8),
  (14, 9),
];

/// Kernel radius in metres per H3 resolution: ~1.6x the distance between
/// neighbouring cell centres, so neighbours always overlap and merge.
const Map<int, double> heatRadiusMetersByResolution = {
  3: 160000,
  4: 80000,
  5: 28000,
  6: 9000,
  7: 3400,
  8: 1300,
  9: 500,
};
const double _fallbackRadiusMeters = 9000;

/// On-screen radius is kept between these so hotspots stay readable zoomed far
/// out and don't balloon zoomed far in.
const double heatMinRadiusPx = 58;
const double heatMaxRadiusPx = 240;

/// Every hotspot also casts a wider, fainter halo.
const double heatHaloScale = 2.3;
const double heatHaloAlpha = 0.20;

/// Overall layer opacity: a little stronger zoomed out, lighter zoomed in.
const double heatLayerOpacityOut = 0.78;
const double heatLayerOpacityIn = 0.58;

/// The field is computed at this fraction of the screen resolution — the image
/// is soft anyway, and it is smoothed again when scaled up.
const double heatCanvasScale = 0.4;

/// Extra field drawn around the viewport (fraction of its size) so a pan never
/// exposes an unpainted edge before the next render.
const double heatCanvasMargin = 0.5;

const double _heatPeak = 1.0;
const double _heatFieldFullscale = 1.08;
const double _heatPointFloor = 0.06;
const double _heatScoreGamma = 0.75;

/// `[position 0..1, r, g, b, alpha]`. Low values are transparent blue; the hot
/// end is saturated and mostly opaque so hotspots read on a light basemap.
const List<List<double>> heatGradient = [
  [0.00, 20, 30, 160, 0.00],
  [0.07, 24, 50, 190, 0.18],
  [0.20, 20, 110, 245, 0.46],
  [0.33, 0, 195, 245, 0.64],
  [0.46, 60, 225, 120, 0.74],
  [0.58, 245, 235, 50, 0.82],
  [0.70, 255, 150, 30, 0.88],
  [0.82, 232, 40, 38, 0.90],
  [1.00, 215, 25, 30, 0.92],
];

/// H3 resolution to request for a map zoom level.
int heatResolutionForZoom(double zoom) {
  var resolution = heatResolutionSteps.first.$2;
  for (final step in heatResolutionSteps) {
    if (zoom >= step.$1) resolution = step.$2;
  }
  return resolution;
}

double heatRadiusMetersForResolution(int resolution) =>
    heatRadiusMetersByResolution[resolution] ?? _fallbackRadiusMeters;

double heatMetersPerPixel(double lat, double zoom) =>
    156543.03392 * math.cos(lat * math.pi / 180) / math.pow(2, zoom);

/// On-screen radius (logical pixels) of one hotspot at [lat]/[zoom].
double heatRadiusPx(double lat, double zoom, double radiusMeters) {
  final px = radiusMeters / heatMetersPerPixel(lat, zoom);
  return px.clamp(heatMinRadiusPx, heatMaxRadiusPx);
}

/// Zoomed out many cells overlap in every pixel; zoomed in they stand alone.
double heatIntensity(double zoom) {
  final rise = ((zoom - 5) / 5).clamp(0.0, 1.0);
  return 0.9 + 0.1 * rise;
}

double heatLayerOpacity(double zoom) {
  final t = ((zoom - 6) / 6).clamp(0.0, 1.0);
  return heatLayerOpacityOut + (heatLayerOpacityIn - heatLayerOpacityOut) * t;
}

/// Weight of a point at distance `t = d / radius` from a blob centre:
/// `exp(-4.5 t^2) * (1 - t^6)`, exactly 0 at the rim.
double _kernelWeight(double t2) {
  if (t2 >= 1) return 0;
  return math.exp(-4.5 * t2) * (1 - t2 * t2 * t2);
}

/// Normalised strength (0..1) of each point, in the same order as the input.
///
/// `lats`/`lngs` are cell centres and `counts` how much activity each holds.
/// Each point starts at `(count / maxCount) ^ gamma`; then everything is scaled
/// so the strongest overlap of blobs anywhere (the densest spot) sums to
/// exactly the top of the gradient. Computed in metres, so it doesn't depend on
/// the screen, and with a spatial hash so cost grows with local density rather
/// than with the square of the cell count.
Float64List computeHeatWeights({
  required List<double> lats,
  required List<double> lngs,
  required List<int> counts,
  required int resolution,
}) {
  final n = lats.length;
  final weights = Float64List(n);
  if (n == 0) return weights;

  final radius = heatRadiusMetersForResolution(resolution);
  final haloRadius = radius * heatHaloScale;
  final r2 = radius * radius;
  final rh2 = haloRadius * haloRadius;

  var maxCount = 1;
  for (final c in counts) {
    if (c > maxCount) maxCount = c;
  }
  final norms = Float64List(n);
  for (var i = 0; i < n; i++) {
    norms[i] = math.pow(counts[i] / maxCount, _heatScoreGamma).toDouble();
  }

  var meanLat = 0.0;
  for (final lat in lats) {
    meanLat += lat;
  }
  meanLat /= n;
  final kx = 111320 * math.cos(meanLat * math.pi / 180);
  const ky = 110574.0;

  final xs = Float64List(n);
  final ys = Float64List(n);
  final buckets = <int, List<int>>{};
  int bucketKey(int bx, int by) => (bx + 100000) * 200003 + (by + 100000);
  for (var i = 0; i < n; i++) {
    xs[i] = lngs[i] * kx;
    ys[i] = lats[i] * ky;
    final key = bucketKey(
      (xs[i] / haloRadius).floor(),
      (ys[i] / haloRadius).floor(),
    );
    (buckets[key] ??= <int>[]).add(i);
  }

  var peak = 1.0;
  for (var i = 0; i < n; i++) {
    final bx = (xs[i] / haloRadius).floor();
    final by = (ys[i] / haloRadius).floor();
    var sum = 0.0;
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        final neighbours = buckets[bucketKey(bx + dx, by + dy)];
        if (neighbours == null) continue;
        for (final j in neighbours) {
          final ddx = xs[i] - xs[j];
          final ddy = ys[i] - ys[j];
          final d2 = ddx * ddx + ddy * ddy;
          if (d2 >= rh2) continue;
          // core + halo, exactly what gets drawn
          var w = d2 < r2 ? _kernelWeight(d2 / r2) : 0.0;
          w += heatHaloAlpha * _kernelWeight(d2 / rh2);
          sum += norms[j] * w;
        }
      }
    }
    if (sum > peak) peak = sum;
  }

  for (var i = 0; i < n; i++) {
    weights[i] = (_heatPeak * norms[i] / peak).clamp(_heatPointFloor, 1.0);
  }
  return weights;
}

/// 256 premultiplied RGBA entries (1024 bytes) interpolated from [heatGradient].
Uint8List buildHeatPalette() {
  final palette = Uint8List(256 * 4);
  for (var i = 0; i < 256; i++) {
    final pos = i / 255;
    var hi = 1;
    while (hi < heatGradient.length - 1 && heatGradient[hi][0] < pos) {
      hi++;
    }
    final a = heatGradient[hi - 1];
    final b = heatGradient[hi];
    final span = b[0] - a[0];
    final t = span == 0 ? 0.0 : ((pos - a[0]) / span).clamp(0.0, 1.0);
    double mix(int k) => a[k] + (b[k] - a[k]) * t;
    final alpha = mix(4);
    // Premultiplied, which is what the engine expects for raw pixel data.
    palette[i * 4] = (mix(1) * alpha).round();
    palette[i * 4 + 1] = (mix(2) * alpha).round();
    palette[i * 4 + 2] = (mix(3) * alpha).round();
    palette[i * 4 + 3] = (alpha * 255).round();
  }
  return palette;
}

/// Input to [renderHeatPixels]. Plain typed data so it crosses an isolate
/// boundary cheaply.
class HeatRenderRequest {
  final int width;
  final int height;

  /// Four floats per hotspot: `x, y` (field pixels), `radius` (field pixels),
  /// `alpha` (0..1 strength).
  final Float32List blobs;

  const HeatRenderRequest({
    required this.width,
    required this.height,
    required this.blobs,
  });
}

/// Renders the heat field to premultiplied RGBA pixels (`width * height * 4`).
Uint8List renderHeatPixels(HeatRenderRequest request) {
  final w = request.width;
  final h = request.height;
  final field = Float32List(w * h);
  final kernels = <int, Float32List>{};

  Float32List kernelFor(int r) => kernels[r] ??= _buildKernel(r);

  void splat(double cx, double cy, double radius, double alpha) {
    final r = math.max(1, radius.round());
    final kernel = kernelFor(r);
    final size = 2 * r + 1;
    final px = cx.round();
    final py = cy.round();
    final x0 = math.max(0, px - r);
    final x1 = math.min(w - 1, px + r);
    final y0 = math.max(0, py - r);
    final y1 = math.min(h - 1, py + r);
    if (x0 > x1 || y0 > y1) return;
    for (var y = y0; y <= y1; y++) {
      var k = (y - py + r) * size + (x0 - px + r);
      var f = y * w + x0;
      for (var x = x0; x <= x1; x++, k++, f++) {
        field[f] += alpha * kernel[k];
      }
    }
  }

  final blobs = request.blobs;
  for (var i = 0; i + 3 < blobs.length; i += 4) {
    final x = blobs[i];
    final y = blobs[i + 1];
    final radius = blobs[i + 2];
    final alpha = blobs[i + 3];
    splat(x, y, radius, alpha);
    splat(x, y, radius * heatHaloScale, alpha * heatHaloAlpha);
  }

  final palette = buildHeatPalette();
  final pixels = Uint8List(w * h * 4);
  const inv = 255 / _heatFieldFullscale;
  for (var i = 0, o = 0; i < field.length; i++, o += 4) {
    final v = field[i];
    if (v < 0.002) continue;
    final index = math.min(255, (v * inv).toInt()) * 4;
    pixels[o] = palette[index];
    pixels[o + 1] = palette[index + 1];
    pixels[o + 2] = palette[index + 2];
    pixels[o + 3] = palette[index + 3];
  }
  return pixels;
}

Float32List _buildKernel(int r) {
  final size = 2 * r + 1;
  final kernel = Float32List(size * size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x - r;
      final dy = y - r;
      kernel[y * size + x] = _kernelWeight((dx * dx + dy * dy) / (r * r));
    }
  }
  return kernel;
}
