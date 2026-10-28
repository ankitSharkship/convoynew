import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/heatmap_entity.dart';
import '../rendering/heat_field.dart';

/// How long the camera must sit still before the heat image is re-rendered.
/// Until then the last image is simply repositioned/scaled with the map.
const _renderDebounce = Duration(milliseconds: 120);

/// A smooth density heatmap drawn over a [FlutterMap] (place it after the tile
/// layer in `FlutterMap.children`).
///
/// The field is rendered off the UI thread into an image that covers the
/// viewport plus a margin, anchored to geographic bounds — so while the map is
/// panned or pinched the image tracks it, and it is re-rendered once the camera
/// settles.
class HeatLayer extends StatefulWidget {
  final List<HeatCellEntity> cells;

  /// H3 resolution [cells] were aggregated at.
  final int resolution;

  const HeatLayer({super.key, required this.cells, required this.resolution});

  @override
  State<HeatLayer> createState() => _HeatLayerState();
}

class _RenderedHeat {
  final ui.Image image;
  final LatLng northWest;
  final LatLng southEast;

  _RenderedHeat(this.image, this.northWest, this.southEast);
}

class _HeatLayerState extends State<HeatLayer> {
  _RenderedHeat? _rendered;
  Float64List _weights = Float64List(0);
  Timer? _debounce;
  int _generation = 0;
  bool _disposed = false;
  MapCamera? _lastCamera;

  @override
  void initState() {
    super.initState();
    _recomputeWeights();
  }

  @override
  void didUpdateWidget(HeatLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.cells, widget.cells) ||
        oldWidget.resolution != widget.resolution) {
      _recomputeWeights();
      _scheduleRender(immediate: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final camera = MapCamera.of(context);
    final previous = _lastCamera;
    _lastCamera = camera;
    if (previous == null ||
        previous.center != camera.center ||
        previous.zoom != camera.zoom ||
        previous.nonRotatedSize != camera.nonRotatedSize) {
      _scheduleRender(immediate: previous == null);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _rendered?.image.dispose();
    super.dispose();
  }

  void _recomputeWeights() {
    _weights = computeHeatWeights(
      lats: [for (final c in widget.cells) c.lat],
      lngs: [for (final c in widget.cells) c.lng],
      counts: [for (final c in widget.cells) c.count],
      resolution: widget.resolution,
    );
  }

  void _scheduleRender({bool immediate = false}) {
    _debounce?.cancel();
    if (immediate) {
      _render();
    } else {
      _debounce = Timer(_renderDebounce, _render);
    }
  }

  Future<void> _render() async {
    if (_disposed || !mounted) return;
    final camera = _lastCamera;
    if (camera == null || camera.nonRotatedSize == MapCamera.kImpossibleSize) {
      return;
    }
    final generation = ++_generation;

    if (widget.cells.isEmpty) {
      setState(() {
        _rendered?.image.dispose();
        _rendered = null;
      });
      return;
    }

    final size = camera.nonRotatedSize;
    final marginX = size.width * heatCanvasMargin;
    final marginY = size.height * heatCanvasMargin;
    final cssWidth = size.width + 2 * marginX;
    final cssHeight = size.height + 2 * marginY;
    final fieldWidth = (cssWidth * heatCanvasScale).ceil().clamp(1, 4096);
    final fieldHeight = (cssHeight * heatCanvasScale).ceil().clamp(1, 4096);

    final radiusMeters = heatRadiusMetersForResolution(widget.resolution);
    final intensity = heatIntensity(camera.zoom);
    final cells = widget.cells;
    final weights = _weights;

    final blobs = Float32List(cells.length * 4);
    for (var i = 0; i < cells.length; i++) {
      final p = camera.latLngToScreenOffset(LatLng(cells[i].lat, cells[i].lng));
      blobs[i * 4] = (p.dx + marginX) * heatCanvasScale;
      blobs[i * 4 + 1] = (p.dy + marginY) * heatCanvasScale;
      blobs[i * 4 + 2] =
          heatRadiusPx(cells[i].lat, camera.zoom, radiusMeters) *
          heatCanvasScale;
      blobs[i * 4 + 3] = weights[i] * intensity;
    }

    final northWest = camera.screenOffsetToLatLng(Offset(-marginX, -marginY));
    final southEast = camera.screenOffsetToLatLng(
      Offset(size.width + marginX, size.height + marginY),
    );

    final pixels = await compute(
      renderHeatPixels,
      HeatRenderRequest(width: fieldWidth, height: fieldHeight, blobs: blobs),
    );
    if (_disposed || !mounted || generation != _generation) return;

    final image = await _decode(pixels, fieldWidth, fieldHeight);
    if (_disposed || !mounted || generation != _generation) {
      image.dispose();
      return;
    }
    setState(() {
      _rendered?.image.dispose();
      _rendered = _RenderedHeat(image, northWest, southEast);
    });
  }

  Future<ui.Image> _decode(Uint8List pixels, int width, int height) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final rendered = _rendered;
    if (rendered == null) return const SizedBox.shrink();
    final camera = MapCamera.of(context);
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _HeatImagePainter(
            image: rendered.image,
            topLeft: camera.latLngToScreenOffset(rendered.northWest),
            bottomRight: camera.latLngToScreenOffset(rendered.southEast),
            opacity: heatLayerOpacity(camera.zoom),
          ),
        ),
      ),
    );
  }
}

class _HeatImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset topLeft;
  final Offset bottomRight;
  final double opacity;

  _HeatImagePainter({
    required this.image,
    required this.topLeft,
    required this.bottomRight,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromPoints(topLeft, bottomRight);
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..color = Color.fromRGBO(0, 0, 0, opacity);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(_HeatImagePainter old) =>
      old.image != image ||
      old.topLeft != topLeft ||
      old.bottomRight != bottomRight ||
      old.opacity != opacity;
}

/// The hotspot under a tap, if any: the nearest cell whose blob contains the
/// tap within half its on-screen radius (so a tap on empty map selects nothing).
HeatCellEntity? findHeatCellAt({
  required MapCamera camera,
  required List<HeatCellEntity> cells,
  required int resolution,
  required LatLng tap,
}) {
  final tapPoint = camera.latLngToScreenOffset(tap);
  final radiusMeters = heatRadiusMetersForResolution(resolution);
  HeatCellEntity? best;
  var bestDistance = double.infinity;
  for (final cell in cells) {
    final p = camera.latLngToScreenOffset(LatLng(cell.lat, cell.lng));
    final distance = (p - tapPoint).distance;
    final reach = heatRadiusPx(cell.lat, camera.zoom, radiusMeters) * 0.5;
    if (distance < reach && distance < bestDistance) {
      best = cell;
      bestDistance = distance;
    }
  }
  return best;
}
