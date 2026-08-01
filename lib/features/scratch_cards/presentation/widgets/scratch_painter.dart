import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Paints [overlayImage] into the widget's bounds, then punches
/// transparent holes along [scratchPath] using [BlendMode.clear] inside a
/// single `saveLayer` — the standard alpha-mask erase technique, so
/// whatever sits beneath this painter in the `Stack` shows through
/// wherever the user has scratched, with anti-aliased, round-capped edges
/// rather than a jagged pixel mask.
///
/// Repainting is driven entirely by the [repaint] `Listenable` the caller
/// passes in (notified on every pointer move) — [shouldRepaint] always
/// returns false so nothing else (e.g. a `setState` for unrelated state)
/// ever forces a redundant repaint of this layer.
class ScratchPainter extends CustomPainter {
  final ui.Image overlayImage;
  final Path scratchPath;
  final double brushRadius;

  ScratchPainter({
    required this.overlayImage,
    required this.scratchPath,
    required this.brushRadius,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    paintImage(canvas: canvas, rect: bounds, image: overlayImage, fit: BoxFit.fill);
    canvas.drawPath(
      scratchPath,
      Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = brushRadius * 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScratchPainter oldDelegate) => false;
}
