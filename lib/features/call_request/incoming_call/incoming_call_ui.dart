import '../../../core/services/voip_token_source.dart';

/// What the person did with the system's incoming-call screen.
enum IncomingCallEventType {
  /// The system call screen came up (so the app's own ring screen is not needed).
  shown,

  /// They tapped Answer.
  accepted,

  /// They tapped Decline before answering.
  declined,

  /// The call was ended from the system's call screen after it was answered.
  ended,

  /// Nobody answered in time.
  timedOut,
}

class IncomingCallEvent {
  final IncomingCallEventType type;
  final String requestId;

  const IncomingCallEvent(this.type, this.requestId);

  @override
  String toString() => 'IncomingCallEvent($type, $requestId)';
}

/// What a "call_incoming" push says about the call (docs/ONE_TO_ONE_CALL_API.md).
class IncomingCallInfo {
  final String requestId;
  final String callerName;
  final String topic;
  final DateTime ringEndsAt;

  const IncomingCallInfo({
    required this.requestId,
    required this.callerName,
    required this.topic,
    required this.ringEndsAt,
  });

  /// How long is left to answer, never negative.
  Duration remaining(DateTime now) {
    final left = ringEndsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Reads a push's data map; null when it is not a usable "call_incoming".
  static IncomingCallInfo? fromPushData(Map<String, dynamic> data) {
    if (data['type'] != 'call_incoming') return null;
    final id = data['requestId'];
    final ends = data['ringEndsAt'];
    if (id is! String || id.isEmpty || ends is! String) return null;
    final parsed = DateTime.tryParse(ends);
    if (parsed == null) return null;
    final name = data['callerName'];
    final topic = data['topic'];
    return IncomingCallInfo(
      requestId: id,
      callerName: name is String && name.trim().isNotEmpty
          ? name.trim()
          : 'Incoming call',
      topic: topic is String ? topic : '',
      ringEndsAt: parsed.toUtc(),
    );
  }
}

/// The phone's own incoming-call screen: CallKit on iPhone, a full-screen call
/// notification on Android. One call per request, identified by the request id
/// (which is a UUID, as CallKit needs).
abstract class IncomingCallUi implements VoipTokenSource {
  Stream<IncomingCallEvent> get events;

  /// iOS shows its call screen even while the app is open (it has to: every
  /// VoIP push must put up a call). Android only does when the app is closed.
  bool get showsWhileAppIsOpen;

  /// Starts listening to the platform (cheap, safe to repeat).
  Future<void> prepare();

  /// Asks the person for what the screen needs (notifications, full-screen
  /// alerts). May open system dialogs or settings: ask once, not at every launch.
  Future<void> requestPermissions();

  Future<void> show(IncomingCallInfo info);

  /// Takes the call off the system (call finished, driver hung up, answered
  /// elsewhere). Safe for a call that is not showing.
  Future<void> end(String requestId);

  /// The call is connected: lets the system show it as an ongoing call.
  Future<void> setConnected(String requestId);

  /// Requests answered from the system screen while the app was not running
  /// (the answer event may have been missed).
  Future<List<String>> acceptedWhileAway();
}

/// Where there is no system call screen (web, tests): the app's own ring
/// screen does the job.
class NoIncomingCallUi implements IncomingCallUi {
  const NoIncomingCallUi();

  @override
  Stream<IncomingCallEvent> get events => const Stream.empty();

  @override
  bool get showsWhileAppIsOpen => false;

  @override
  Future<void> prepare() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> show(IncomingCallInfo info) async {}

  @override
  Future<void> end(String requestId) async {}

  @override
  Future<void> setConnected(String requestId) async {}

  @override
  Future<List<String>> acceptedWhileAway() async => const [];

  @override
  Future<String?> currentVoipToken() async => null;

  @override
  Stream<String> get voipTokenChanges => const Stream.empty();

  @override
  Future<bool> isVoipSandbox() async => false;
}
