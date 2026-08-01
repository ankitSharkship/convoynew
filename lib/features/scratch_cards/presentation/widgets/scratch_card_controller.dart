import 'package:flutter/foundation.dart';

/// Lets a caller imperatively reset or force-complete a [ScratchCardWidget]
/// without needing a `GlobalKey<State>` — the widget's own State calls
/// [attach]/[detach] on itself; consumers only ever call [reset]/[reveal].
class ScratchCardController {
  VoidCallback? _onReset;
  VoidCallback? _onReveal;
  bool Function()? _isRevealed;

  void attach({
    required VoidCallback onReset,
    required VoidCallback onReveal,
    required bool Function() isRevealed,
  }) {
    _onReset = onReset;
    _onReveal = onReveal;
    _isRevealed = isRevealed;
  }

  void detach() {
    _onReset = null;
    _onReveal = null;
    _isRevealed = null;
  }

  /// Restores the foil, clearing all scratch progress.
  void reset() => _onReset?.call();

  /// Immediately completes the reveal, as if the user had fully scratched
  /// through the foil.
  void reveal() => _onReveal?.call();

  bool get isRevealed => _isRevealed?.call() ?? false;
}
