import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'scratch_card_controller.dart';
import 'scratch_painter.dart';

/// A self-contained, GPU-accelerated scratch-off card.
///
/// [overlay] is captured once into an offscreen image (so it can be
/// anything — a gradient, an image, an animation's current frame) and then
/// progressively erased via an alpha mask following the user's actual
/// finger path. [child] sits beneath it in a `Stack` and is never touched
/// by the erasing pipeline — it stays fully live for as long as it's in
/// the tree, before, during, and after the reveal.
///
/// Multiple simultaneous fingers each contribute their own stroke segments
/// to the same scratch mask. Progress is estimated with a coarse sampling
/// grid (cheap to update per pointer move) rather than exact pixel
/// counting, which would mean reading back the rendered mask every frame.
///
/// Repainting during a scratch is driven by a `Listenable` passed straight
/// to [ScratchPainter] — dragging a finger across the card does not call
/// `setState`, so it never rebuilds this widget's subtree, only repaints
/// the scratch layer itself.
class ScratchCardWidget extends StatefulWidget {
  final Widget child;
  final Widget overlay;
  final double brushRadius;
  final double revealThreshold;
  final VoidCallback? onReveal;
  final ValueChanged<double>? onProgress;
  final bool enabled;
  final ScratchCardController? controller;
  final BorderRadius borderRadius;

  const ScratchCardWidget({
    super.key,
    required this.child,
    required this.overlay,
    this.brushRadius = 24,
    this.revealThreshold = 0.6,
    this.onReveal,
    this.onProgress,
    this.enabled = true,
    this.controller,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  static const _gridResolution = 24;

  final GlobalKey _overlayCaptureKey = GlobalKey();
  final Path _scratchPath = Path();
  final _RepaintSignal _repaint = _RepaintSignal();
  final Map<int, Offset> _activePointers = {};
  late List<List<bool>> _scratchedGrid;

  ui.Image? _overlayImage;
  bool _revealed = false;
  double _overlayOpacity = 1;
  int _scratchedCellCount = 0;

  @override
  void initState() {
    super.initState();
    _resetGrid();
    widget.controller?.attach(
      onReset: _handleReset,
      onReveal: _handleForceReveal,
      isRevealed: () => _revealed,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureOverlay());
  }

  @override
  void didUpdateWidget(covariant ScratchCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(
        onReset: _handleReset,
        onReveal: _handleForceReveal,
        isRevealed: () => _revealed,
      );
    }
    if (!identical(oldWidget.overlay, widget.overlay)) {
      // A genuinely different overlay widget needs re-capturing; the
      // pending capture below runs once the new tree has painted.
      setState(() => _overlayImage = null);
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureOverlay());
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _overlayImage?.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _resetGrid() {
    _scratchedGrid = List.generate(
      _gridResolution,
      (_) => List.filled(_gridResolution, false),
    );
    _scratchedCellCount = 0;
  }

  // `toImage()` asserts the render object isn't mid-paint. One frame after
  // this widget first appears isn't always enough for that to be true —
  // e.g. this card is typically still inside an active Hero flight/fade-in
  // transition at that point, which keeps re-marking the tree dirty every
  // tick for its own duration. So this retries every frame (bounded, so a
  // truly pathological case just gives up instead of looping forever)
  // until the render object is actually settled.
  static const _maxCaptureAttempts = 40;

  Future<void> _captureOverlay({int attempt = 0}) async {
    if (!mounted) return;
    final renderObject = _overlayCaptureKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return;

    if (renderObject.debugNeedsPaint) {
      if (attempt >= _maxCaptureAttempts) return;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _captureOverlay(attempt: attempt + 1),
      );
      return;
    }

    try {
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final image = await renderObject.toImage(pixelRatio: dpr);
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _overlayImage?.dispose();
        _overlayImage = image;
      });
    } catch (_) {
      if (attempt >= _maxCaptureAttempts) return;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _captureOverlay(attempt: attempt + 1),
      );
    }
  }

  void _handleReset() {
    setState(() {
      _scratchPath.reset();
      _resetGrid();
      _activePointers.clear();
      _revealed = false;
      _overlayOpacity = 1;
    });
    _repaint.ping();
    widget.onProgress?.call(0);
  }

  void _handleForceReveal() {
    if (_revealed) return;
    setState(() {
      _revealed = true;
      _overlayOpacity = 0;
    });
    widget.onProgress?.call(1);
    widget.onReveal?.call();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || _revealed) return;
    _activePointers[event.pointer] = event.localPosition;
    // A tap without any drag should still scratch a visible dot.
    _scratchPath.addOval(
      Rect.fromCircle(center: event.localPosition, radius: widget.brushRadius),
    );
    _repaint.ping();
    _updateProgress(event.localPosition);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.enabled || _revealed) return;
    final last = _activePointers[event.pointer];
    if (last != null) {
      // Each segment explicitly (re-)establishes its own start point via
      // moveTo rather than relying on the Path's implicit current
      // position — with several fingers scratching at once, another
      // pointer's moveTo/lineTo in between would otherwise silently hijack
      // that shared cursor and draw a stray line from the wrong place.
      // Thick round caps/joins keep consecutive segments from a single
      // finger looking seamless despite each being its own subpath.
      _scratchPath
        ..moveTo(last.dx, last.dy)
        ..lineTo(event.localPosition.dx, event.localPosition.dy);
    }
    _activePointers[event.pointer] = event.localPosition;
    _repaint.ping();
    _updateProgress(event.localPosition);
  }

  void _onPointerUp(PointerEvent event) {
    _activePointers.remove(event.pointer);
  }

  void _updateProgress(Offset point) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    final cellW = size.width / _gridResolution;
    final cellH = size.height / _gridResolution;
    final radiusCellsX = (widget.brushRadius / cellW).ceil() + 1;
    final radiusCellsY = (widget.brushRadius / cellH).ceil() + 1;
    final cx = (point.dx / cellW).floor();
    final cy = (point.dy / cellH).floor();
    final minGy = (cy - radiusCellsY).clamp(0, _gridResolution - 1);
    final maxGy = (cy + radiusCellsY).clamp(0, _gridResolution - 1);
    final minGx = (cx - radiusCellsX).clamp(0, _gridResolution - 1);
    final maxGx = (cx + radiusCellsX).clamp(0, _gridResolution - 1);
    for (var gy = minGy; gy <= maxGy; gy++) {
      for (var gx = minGx; gx <= maxGx; gx++) {
        if (_scratchedGrid[gy][gx]) continue;
        final cellCenter = Offset((gx + 0.5) * cellW, (gy + 0.5) * cellH);
        if ((cellCenter - point).distance <= widget.brushRadius) {
          _scratchedGrid[gy][gx] = true;
          _scratchedCellCount++;
        }
      }
    }
    final progress = _scratchedCellCount / (_gridResolution * _gridResolution);
    widget.onProgress?.call(progress.clamp(0, 1));
    if (!_revealed && progress >= widget.revealThreshold) {
      setState(() {
        _revealed = true;
        _overlayOpacity = 0;
      });
      widget.onReveal?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayImage = _overlayImage;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          // Rendered normally (not display:none) until captured, since a
          // RepaintBoundary needs at least one real paint pass to produce
          // an image — Offstage flips to hiding it the instant the
          // captured image takes over, with no visible handoff.
          Offstage(
            offstage: overlayImage != null,
            child: RepaintBoundary(key: _overlayCaptureKey, child: widget.overlay),
          ),
          if (overlayImage != null)
            AnimatedOpacity(
              opacity: _overlayOpacity,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                child: CustomPaint(
                  painter: ScratchPainter(
                    overlayImage: overlayImage,
                    scratchPath: _scratchPath,
                    brushRadius: widget.brushRadius,
                    repaint: _repaint,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `notifyListeners()` is protected — a bare `ChangeNotifier` can't have it
/// called from outside itself, so this exists purely to expose a public
/// `ping()` the State can call on every pointer move to drive
/// [ScratchPainter]'s repaint without going through `setState`.
class _RepaintSignal extends ChangeNotifier {
  void ping() => notifyListeners();
}
