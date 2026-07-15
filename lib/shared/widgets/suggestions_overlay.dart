import 'package:flutter/material.dart';

/// Wraps [field] so that whenever [visible] is true, [overlayBuilder] floats
/// directly below it — layered on top of the rest of the page instead of
/// pushing content down. Tapping anywhere outside the overlay calls
/// [onDismissTap].
class SuggestionsOverlay extends StatefulWidget {
  final Widget field;
  final bool visible;
  final WidgetBuilder overlayBuilder;
  final VoidCallback onDismissTap;

  const SuggestionsOverlay({
    super.key,
    required this.field,
    required this.visible,
    required this.overlayBuilder,
    required this.onDismissTap,
  });

  @override
  State<SuggestionsOverlay> createState() => _SuggestionsOverlayState();
}

class _SuggestionsOverlayState extends State<SuggestionsOverlay> {
  final _layerLink = LayerLink();
  final _fieldKey = GlobalKey();
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant SuggestionsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSync();
  }

  @override
  void dispose() {
    _removeEntry();
    super.dispose();
  }

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.visible) {
        _showOrUpdateEntry();
      } else {
        _removeEntry();
      }
    });
  }

  void _showOrUpdateEntry() {
    if (_entry == null) {
      _entry = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context).insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  Widget _buildOverlay(BuildContext context) {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 0;
    final height = renderBox?.size.height ?? 0;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismissTap,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, height + 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: width,
                child: widget.overlayBuilder(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyedSubtree(key: _fieldKey, child: widget.field),
    );
  }
}
