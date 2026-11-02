import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which call screens are open right now. The coordinator uses it to decide
/// whether it may bring a prompt up (never one call screen over another), and
/// the screens use it to avoid being opened twice for the same call.
///
/// It is kept here rather than read from the router: `routeInformationProvider`
/// reports only `go` navigations, so after a `push` it still says "/home" and a
/// check on it cannot see that a call screen is already on top.
class CallScreenRegistry extends ChangeNotifier {
  final Map<String, int> _live = {};
  final Map<String, int> _other = {};

  /// Any call screen at all (call, ring, rejoin prompt, satisfaction question).
  bool get anyOpen => _live.isNotEmpty || _other.isNotEmpty;

  /// The call itself is open for [requestId].
  bool liveOpen(String requestId) => (_live[requestId] ?? 0) > 0;

  /// [live] is the call screen proper; otherwise a ring / rejoin / feedback screen.
  void enter(String requestId, {required bool live}) {
    final map = live ? _live : _other;
    map[requestId] = (map[requestId] ?? 0) + 1;
  }

  void leave(String requestId, {required bool live}) {
    final map = live ? _live : _other;
    final count = (map[requestId] ?? 0) - 1;
    if (count <= 0) {
      map.remove(requestId);
    } else {
      map[requestId] = count;
    }
    // Something may be waiting for the screen to go: a ring that came in during
    // the call, a satisfaction question after it.
    notifyListeners();
  }
}

final callScreenRegistryProvider = Provider<CallScreenRegistry>((ref) {
  final registry = CallScreenRegistry();
  ref.onDispose(registry.dispose);
  return registry;
});
