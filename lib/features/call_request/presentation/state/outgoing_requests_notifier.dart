import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/call_request_entity.dart';
import 'call_providers.dart';

/// How often the requester's open requests are re-read, depending on how close
/// a ring might be. A push (`call_incoming`) refreshes immediately; these are
/// the safety net when a push doesn't arrive, so they are short only while a
/// ring is likely (the driver accepted, or is already calling).
const outgoingPollWhenCallLikely = Duration(seconds: 3);
const outgoingPollWhenWaiting = Duration(seconds: 8);
const outgoingPollAfterError = Duration(seconds: 15);

/// The signed-in user's own requests that are still open or waiting for their
/// "were you satisfied?" answer. Kept alive for the app's lifetime, but it only
/// polls while something in the list could still change (nothing open: no
/// requests are made until a push, the app coming back, or a new request).
final outgoingActiveRequestsProvider =
    AsyncNotifierProvider<
      OutgoingActiveRequestsNotifier,
      List<CallRequestEntity>
    >(OutgoingActiveRequestsNotifier.new);

class OutgoingActiveRequestsNotifier
    extends AsyncNotifier<List<CallRequestEntity>> {
  Timer? _timer;
  bool _disposed = false;

  @override
  Future<List<CallRequestEntity>> build() async {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    try {
      final list = await ref.read(callRepositoryProvider).getOutgoingActive();
      _scheduleNextPoll(list);
      return list;
    } catch (_) {
      _scheduleNextPoll(null);
      // A failed first read is "nothing to show"; the retry fixes it.
      return const [];
    }
  }

  void _scheduleNextPoll(List<CallRequestEntity>? list) {
    _timer?.cancel();
    if (_disposed) return;
    final Duration? wait;
    if (list == null) {
      wait = outgoingPollAfterError;
    } else if (list.any(
      (r) => r.status == CallStatus.accepted || r.status == CallStatus.ringing,
    )) {
      wait = outgoingPollWhenCallLikely;
    } else if (list.any(
      (r) => r.status == CallStatus.pending || r.status == CallStatus.live,
    )) {
      wait = outgoingPollWhenWaiting;
    } else {
      wait = null; // only waiting-for-feedback ones (or none): nothing moves
    }
    if (wait != null) _timer = Timer(wait, _poll);
  }

  Future<void> _poll() async {
    try {
      final list = await ref.read(callRepositoryProvider).getOutgoingActive();
      if (_disposed) return;
      state = AsyncData(list);
      _scheduleNextPoll(list);
    } catch (_) {
      if (_disposed) return;
      _scheduleNextPoll(state.valueOrNull);
    }
  }

  /// Reads the list again now (a push arrived, the app came back, or a request
  /// was just sent or answered).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
