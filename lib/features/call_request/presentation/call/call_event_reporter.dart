import '../../domain/entities/call_session_entities.dart';

/// Collects the behaviour events of one call and sends them in batches. Never
/// throws: reporting must never be the reason a call screen breaks. The server
/// takes at most 50 events per call, so the many small toggles stop being
/// recorded a little before that, keeping room for the ones that tell the story
/// of the call ([CallEventType.essential]).
class CallEventReporter {
  static const maxEvents = 45;
  static const maxToggles = 35;

  final Future<void> Function(List<CallBehaviourEvent> events) _send;
  final DateTime Function() _now;

  final List<CallBehaviourEvent> _pending = [];
  int _recorded = 0;
  bool _flushing = false;

  CallEventReporter(this._send, this._now);

  int get pendingCount => _pending.length;

  void record(String type, {Map<String, Object?>? details}) {
    final essential = CallEventType.essential.contains(type);
    if (_recorded >= maxEvents) return;
    if (!essential && _recorded >= maxToggles) return;
    _recorded++;
    _pending.add(
      CallBehaviourEvent(type: type, occurredAt: _now(), details: details),
    );
  }

  Future<void> flush() async {
    if (_flushing || _pending.isEmpty) return;
    _flushing = true;
    final batch = List<CallBehaviourEvent>.of(_pending);
    _pending.clear();
    try {
      await _send(batch);
    } catch (_) {
      // Keep them for the next flush (the log is best-effort, not critical).
      _pending.insertAll(0, batch);
    } finally {
      _flushing = false;
    }
  }
}
