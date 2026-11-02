import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../domain/entities/call_session_entities.dart';
import '../../domain/failures/call_request_exception.dart';
import '../../domain/repositories/call_request_repository.dart';
import '../../media/call_media_engine.dart';
import '../../media/call_permissions.dart';
import '../../incoming_call/incoming_call_controller.dart';
import '../../incoming_call/incoming_call_ui.dart';
import '../state/call_providers.dart';
import '../state/call_request_notifier.dart';
import '../state/outgoing_requests_notifier.dart';
import 'call_event_reporter.dart';
import 'call_prompts.dart';
import 'call_session_state.dart';

/// How often each app tells the server it is on the call (and what it can see).
const callHeartbeatInterval = Duration(seconds: 5);

/// While the driver's call is ringing the heartbeat doubles as a status check,
/// so the screen reacts quickly when the requester answers or declines.
const callRingPollInterval = Duration(seconds: 3);

/// How long past the server's ring deadline the driver waits before giving up
/// on a ring locally (clocks differ a little; the server has the last word).
const callRingGrace = Duration(seconds: 3);

/// How often the behaviour events are sent while the call is on.
const callEventFlushInterval = Duration(seconds: 20);

/// How long joining the media channel may take before the call is given up as
/// "could not be started" (rather than hanging on "waiting for the other person").
const callEngineJoinTimeout = Duration(seconds: 20);

/// How long after the join was requested the channel may take to confirm it
/// before the person is offered "Reconnect" (instead of waiting for ever).
const callEngineConfirmTimeout = Duration(seconds: 20);

/// At most this many media notes are kept per call for the server's diagnostics.
const _maxMediaNotes = 25;

/// Heartbeats that failed in a row before the screen says the connection to
/// the server is shaky.
const _unreachableAfterFailures = 2;

/// Breadcrumbs for a call, in the debug console (`[call 3f2a...] ...`), so a
/// test on two phones shows exactly where something stalled. Silent in tests
/// and in release builds.
void _callLog(String requestId, String message) {
  if (!kDebugMode || kIsWeb) return;
  if (Platform.environment['FLUTTER_TEST'] == 'true') return;
  final short = requestId.length > 8 ? requestId.substring(0, 8) : requestId;
  debugPrint('[call $short] $message');
}

final callSessionProvider = NotifierProvider.autoDispose
    .family<CallSessionNotifier, CallSessionState, String>(
      CallSessionNotifier.new,
    );

/// Runs one call from the phone's side: gets the permissions, rings / answers
/// through the server, joins the media channel, keeps the server told that
/// this phone is in the call (heartbeats), reacts to the other person leaving
/// or the connection dropping, hangs up, and reports what the person did.
///
/// It orchestrates the repository and the media engine directly (it is this
/// feature's use-case layer for the call itself), and it is the only place that
/// decides what the call screen shows.
class CallSessionNotifier
    extends AutoDisposeFamilyNotifier<CallSessionState, String> {
  late CallRequestRepository _repo;
  late CallPermissions _permissions;
  late CallMediaEngine Function() _engineFactory;
  late DateTime Function() _now;
  late CallEventReporter _reporter;
  late IncomingCallUi _callUi;

  CallMediaEngine? _engine;

  /// The media of the call being shown, for the video views (null before the
  /// call starts and after it ends).
  CallMediaEngine? get engine => _engine;
  bool _live = false; // from entering a call until it is over (for teardown)
  StreamSubscription<CallMediaEvent>? _mediaSub;
  Timer? _beat;
  Timer? _flush;
  Timer? _joinGuard;
  Timer? _joinConfirm;
  Timer? _notesFlush;
  int _mediaNotes = 0;
  Completer<void>? _joinDone;
  bool _closed = false;
  bool _claimed = false;
  bool _busy = false; // a (re)connect is in progress
  bool _chatOpen = false;
  int _beatFailures = 0;
  int? _peerUid;
  String? _lastBeatStatus; // only changes are worth a breadcrumb

  @override
  CallSessionState build(String requestId) {
    _repo = ref.read(callRepositoryProvider);
    _permissions = ref.read(callPermissionsProvider);
    _engineFactory = ref.read(callMediaEngineFactoryProvider);
    _now = ref.read(callClockProvider);
    _callUi = ref.read(incomingCallUiProvider);
    _reporter = CallEventReporter(
      (events) => _repo.sendEvents(requestId, events),
      _now,
    );
    _closed = false;
    ref.onDispose(_teardown);
    return const CallSessionState();
  }

  // ---- starting ----------------------------------------------------------

  /// The driver starts the call: permissions first (so nobody is rung by a
  /// phone that cannot show video), then the server rings the requester, then
  /// the driver joins the channel and the camera starts while it rings.
  Future<void> startAsDriver() async {
    if (!_claim()) {
      _callLog(arg, 'start ignored: this call is already being run');
      return;
    }
    _callLog(arg, 'driver: starting (asking for camera + microphone)');
    _reporter.record(CallEventType.callScreenOpened);
    if (!await _hasPermissions(needCamera: true)) return;

    final CallJoinResult result;
    try {
      result = await _repo.start(arg);
      _callLog(arg, 'driver: server is ringing the requester');
    } catch (e) {
      _callLog(arg, 'driver: server refused to start: $e');
      _failFrom(e);
      return;
    }
    if (_closed) {
      // The screen was left while the server was ringing the requester.
      await _endQuietly();
      return;
    }
    _enter(result);
    final joined = await _joinEngine(result.credentials);
    if (!joined) {
      // Never leave the requester's phone ringing for a call that cannot happen.
      try {
        await _repo.end(arg);
      } catch (_) {}
    }
  }

  /// The requester picks up the ring. Only the microphone is needed.
  Future<void> answerAsRequester() async {
    if (!_claim()) {
      _callLog(arg, 'answer ignored: this call is already being run');
      return;
    }
    _callLog(arg, 'requester: answering (asking for the microphone)');
    _reporter.record(CallEventType.callScreenOpened);
    if (!await _hasPermissions(needCamera: false)) return;

    final CallJoinResult result;
    try {
      result = await _repo.join(arg);
      _callLog(arg, 'requester: server put the call live');
    } catch (e) {
      _callLog(arg, 'requester: server refused to join: $e');
      _failFrom(e);
      return;
    }
    if (_closed) {
      await _endQuietly();
      return;
    }
    _reporter.record(CallEventType.ringAnswered);
    _enter(result);
    final joined = await _joinEngine(result.credentials);
    if (!joined && !_closed) {
      // The call is live on the server but this phone's audio would not start:
      // end it now (under 30 s, so nothing is charged) rather than leave the
      // driver waiting for someone who is not coming.
      await _endQuietly();
    }
  }

  /// Back into a call that is still on (the app was closed, or the connection
  /// failed for good). [isProvider] says whether the camera is needed.
  Future<void> rejoin({required bool isProvider}) async {
    if (!_claim()) {
      _callLog(arg, 'rejoin ignored: this call is already being run');
      return;
    }
    _callLog(arg, 'rejoining (provider: $isProvider)');
    _reporter.record(CallEventType.callScreenOpened);
    _reporter.record(CallEventType.reconnectAccepted);
    if (!await _hasPermissions(needCamera: isProvider)) return;
    await _reconnect();
  }

  /// A rejoin that follows a failed join / a dropped channel, from the call
  /// screen's "Reconnect" button.
  Future<void> reconnect() async {
    if (_busy || state.isOver) return;
    await _reconnect();
  }

  /// The requester says no to the ring: the request is cancelled and the money
  /// released. (Nothing was joined, so there is nothing to leave.) Returns
  /// false, changing nothing, when the server could not be told, so the ring
  /// screen can say so and let them try again.
  Future<bool> decline() async {
    if (_busy || state.isOver) return false;
    _busy = true;
    _reporter.record(CallEventType.ringDeclined);
    try {
      final request = await _repo.end(arg);
      if (_closed) return true;
      await _finish(request.status, request: request);
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy = false;
    }
  }

  /// "End call" on the "you are still in a call" prompt: nothing was joined, so
  /// this only tells the server to end it (settled from the time connected so
  /// far). Never throws; if the server can't be reached it ends by itself once
  /// it stops hearing from this phone.
  Future<void> endWithoutRejoining() async {
    _reporter.record(CallEventType.reconnectDeclined);
    try {
      await _repo.end(arg);
    } catch (_) {}
    unawaited(_reporter.flush());
    if (!_closed) {
      ref.invalidate(incomingCallRequestsNotifierProvider);
      ref.invalidate(outgoingActiveRequestsProvider);
    }
  }

  /// The "you are still in a call" prompt was shown.
  void rejoinOffered() => _reporter.record(CallEventType.reconnectOffered);

  /// Tells the server the call is over without caring how it goes (used when
  /// the screen was closed before the call could start).
  Future<void> _endQuietly() async {
    try {
      await _repo.end(arg);
    } catch (_) {}
  }

  bool _claim() {
    if (_claimed) return false;
    _claimed = true;
    return true;
  }

  Future<bool> _hasPermissions({required bool needCamera}) async {
    final result = await _permissions.request(needCamera: needCamera);
    _callLog(
      arg,
      'permissions: microphone=${result.microphone.name} camera=${result.camera.name}',
    );
    if (_closed) return false;
    if (!result.microphoneOk) {
      _fail(
        CallFailure(
          result.microphone == PermissionOutcome.permanentlyDenied
              ? CallFailureKind.microphoneBlocked
              : CallFailureKind.microphoneDenied,
          'Microphone permission is needed for the call.',
        ),
      );
      return false;
    }
    if (needCamera && !result.cameraOk) {
      _fail(
        CallFailure(
          result.camera == PermissionOutcome.permanentlyDenied
              ? CallFailureKind.cameraBlocked
              : CallFailureKind.cameraDenied,
          'Camera permission is needed for the call.',
        ),
      );
      return false;
    }
    return true;
  }

  /// The state the server put the call in when we asked to start / join.
  void _enter(CallJoinResult result) {
    _live = true;
    final ringing = result.request.status == CallStatus.ringing;
    state = state.copyWith(
      phase: ringing ? CallPhase.ringing : CallPhase.live,
      request: result.request,
      ringEndsAt: result.credentials.ringEndsAt,
      remainingSeconds: result.credentials.durationSeconds,
      remainingAsOf: _now(),
    );
    // Report in from the moment the server has the call on, not only once the
    // media connects: a media channel that is slow (or never comes up) must not
    // make this phone look absent, and its state must be visible to the server.
    _scheduleBeat(after: const Duration(seconds: 1));
    _flush ??= Timer.periodic(callEventFlushInterval, (_) => _reporter.flush());
  }

  Future<bool> _joinEngine(CallCredentialsEntity credentials) async {
    final engine = _engineFactory();
    _engine = engine;
    _mediaSub = engine.events.listen(_onMedia);
    _callLog(arg, 'media: joining channel ${credentials.channelName} as ${credentials.uid}');
    try {
      await _joinWithin(engine, credentials);
    } catch (e) {
      _callLog(arg, 'media: join failed: $e');
      if (_closed) return false;
      // Not awaited: an engine that is stuck must not keep the person from being told.
      unawaited(_dropEngine());
      _fail(
        CallFailure(
          CallFailureKind.media,
          e is TimeoutException
              ? 'The call could not connect (the audio/video did not start in time).'
              : 'The call could not be started: $e',
        ),
      );
      unawaited(_reporter.flush());
      return false;
    }
    _callLog(arg, 'media: join requested OK (waiting for the channel to confirm)');
    if (_closed) return false;
    _scheduleBeat(after: const Duration(seconds: 1));
    _joinConfirm?.cancel();
    _joinConfirm = Timer(callEngineConfirmTimeout, _joinNotConfirmed);
    return true;
  }

  /// Joins the media channel, giving up after [callEngineJoinTimeout]. The
  /// timer is ours (not `Future.timeout`'s) so closing the screen cancels it.
  Future<void> _joinWithin(CallMediaEngine engine, CallCredentialsEntity credentials) {
    final done = Completer<void>();
    _joinGuard?.cancel();
    _joinGuard = Timer(callEngineJoinTimeout, () {
      if (!done.isCompleted) done.completeError(TimeoutException('media join'));
    });
    _joinDone = done;
    engine.join(credentials).then(
      (_) {
        if (!done.isCompleted) done.complete();
      },
      onError: (Object e, StackTrace st) {
        if (!done.isCompleted) done.completeError(e, st);
      },
    );
    return done.future.whenComplete(() {
      _joinGuard?.cancel();
      _joinGuard = null;
    });
  }

  /// The SDK took the join but never said "you are in": offer Reconnect, and keep
  /// a note for the server's diagnostics.
  void _joinNotConfirmed() {
    _joinConfirm = null;
    if (_closed || !state.isActive || state.mediaReady) return;
    _callLog(arg, 'media: the channel never confirmed the join');
    _noteMedia('the channel never confirmed the join');
    state = state.copyWith(connectionLost: true);
    unawaited(_reporter.flush());
  }

  /// Keeps a media note in the call's event log (sent soon, in one batch).
  void _noteMedia(String message) {
    if (_mediaNotes >= _maxMediaNotes) return;
    _mediaNotes++;
    _reporter.record(CallEventType.mediaDiagnostic, details: {'m': message});
    _notesFlush ??= Timer(const Duration(seconds: 2), () {
      _notesFlush = null;
      unawaited(_reporter.flush());
    });
  }

  Future<void> _reconnect() async {
    _busy = true;
    try {
      await _dropEngine();
      final result = await _repo.join(arg);
      if (_closed) return;
      state = state.copyWith(connectionLost: false);
      _enter(result);
      await _joinEngine(result.credentials);
    } catch (e) {
      if (_closed) return;
      if (state.phase == CallPhase.starting) {
        _failFrom(e);
      } else {
        // We were already on the call screen: stay there, offer another try.
        state = state.copyWith(connectionLost: true);
      }
    } finally {
      _busy = false;
    }
  }

  // ---- media events ------------------------------------------------------

  void _onMedia(CallMediaEvent event) {
    if (_closed) return;
    switch (event) {
      case MediaDiag(:final message):
        _callLog(arg, 'agora: $message');
        _noteMedia(message);
      case MediaJoined():
        _joinConfirm?.cancel();
        _joinConfirm = null;
        _callLog(arg, 'media: this phone is in the channel');
        _reporter.record(CallEventType.callJoined);
        state = state.copyWith(mediaReady: true);
        unawaited(_callUi.setConnected(arg)); // lets the system show it as ongoing
      case MediaPeerJoined(:final uid):
        _callLog(arg, 'media: the other person joined (uid $uid)');
        _peerUid = uid;
        state = state.copyWith(
          peerPresent: true,
          peerEverJoined: true,
          peerUid: uid,
        );
      case MediaPeerLeft(:final uid):
        _callLog(arg, 'media: the other person left (uid $uid)');
        if (_peerUid != uid) return;
        _peerUid = null;
        state = state.copyWith(
          peerPresent: false,
          peerVideo: false,
          clearPeerUid: true,
        );
      case MediaPeerVideo(:final uid, :final showing):
        if (uid == _peerUid || _peerUid == null) {
          state = state.copyWith(peerVideo: showing);
        }
      case MediaConnectionLost():
        if (!state.connectionLost) {
          _reporter.record(CallEventType.networkLost);
        }
        state = state.copyWith(connectionLost: true);
      case MediaConnectionRestored():
        _reporter.record(CallEventType.networkRestored);
        state = state.copyWith(connectionLost: false);
      case MediaChatReceived(:final text):
        state = state.copyWith(
          chat: _withMessage(text, mine: false),
          unreadChat: _chatOpen ? 0 : state.unreadChat + 1,
        );
      case MediaFailed(:final reason):
        _callLog(arg, 'media: FAILED: $reason');
        state = state.copyWith(connectionLost: true);
    }
  }

  List<CallChatMessage> _withMessage(String text, {required bool mine}) {
    final all = [
      ...state.chat,
      CallChatMessage(text: text, mine: mine, at: _now()),
    ];
    return all.length > 200 ? all.sublist(all.length - 200) : all;
  }

  // ---- heartbeat ---------------------------------------------------------

  void _scheduleBeat({Duration? after}) {
    _beat?.cancel();
    if (_closed || !state.isActive) return;
    _beat = Timer(
      after ??
          (state.phase == CallPhase.ringing
              ? callRingPollInterval
              : callHeartbeatInterval),
      _beatOnce,
    );
  }

  Future<void> _beatOnce() async {
    if (_closed || !state.isActive) return;
    try {
      final beat = await _repo.heartbeat(arg, _peerUid != null);
      if (_closed || !state.isActive) return;
      _beatFailures = 0;
      if (state.serverUnreachable) {
        state = state.copyWith(serverUnreachable: false);
      }
      await _apply(beat);
    } catch (_) {
      if (_closed) return;
      _beatFailures++;
      if (_beatFailures >= _unreachableAfterFailures &&
          !state.serverUnreachable) {
        state = state.copyWith(serverUnreachable: true);
      }
    }
    if (!_closed && state.isActive) _scheduleBeat();
  }

  Future<void> _apply(CallHeartbeatEntity beat) async {
    if (beat.status != _lastBeatStatus) {
      _lastBeatStatus = beat.status;
      _callLog(arg, 'heartbeat: server says ${beat.status}');
    }
    switch (beat.status) {
      case CallStatus.live:
        state = state.copyWith(
          phase: CallPhase.live,
          connectedSeconds: beat.connectedSeconds,
          remainingSeconds: beat.remainingSeconds,
          remainingAsOf: _now(),
          thresholdSeconds: beat.thresholdSeconds,
        );
      case CallStatus.ringing:
        final ringEnds = state.ringEndsAt;
        if (state.phase == CallPhase.ringing &&
            ringEnds != null &&
            _now().isAfter(ringEnds.add(callRingGrace))) {
          await _ringUnanswered();
        }
      default:
        // accepted (the ring ended), cancelled (declined), awaiting_feedback,
        // failed, completed, expired ...: the call is over.
        await _finish(beat.status);
    }
  }

  /// The ring ran out with no answer: take the call back to "accepted" (the
  /// driver can try again) and say so.
  Future<void> _ringUnanswered() async {
    _beat?.cancel();
    await _engine?.leave();
    try {
      final request = await _repo.end(arg);
      await _finish(request.status, request: request);
    } catch (_) {
      await _finish(CallStatus.accepted);
    }
  }

  // ---- ending ------------------------------------------------------------

  /// The person taps End (or Cancel while it rings).
  Future<void> hangUp() async {
    if (!state.isActive || _closed) return;
    final wasRinging = state.phase == CallPhase.ringing;
    _beat?.cancel();
    _reporter.record(CallEventType.callCut);
    await _engine?.leave(); // stop talking right away, whatever the server does
    try {
      final request = await _repo.end(arg);
      if (_closed) return;
      await _finish(request.status, request: request);
    } catch (_) {
      if (_closed) return;
      await _finish(
        wasRinging ? CallStatus.accepted : CallStatus.live,
        unconfirmed: true,
      );
    }
  }

  Future<void> _finish(
    String status, {
    CallRequestEntity? request,
    bool unconfirmed = false,
  }) async {
    if (state.isOver || _closed) return;
    _callLog(arg, 'call over: $status${unconfirmed ? ' (server not told)' : ''}');
    _live = false;
    // The lists of open requests are only refreshed every few seconds, so one may
    // still say "live" for a moment after this call ended: never offer to rejoin
    // a call that was just ended on this very phone.
    ref.read(handledCallPromptsProvider).add(CallPromptKeys.rejoin(arg));
    _beat?.cancel();
    _flush?.cancel();
    _flush = null;
    state = state.copyWith(
      phase: CallPhase.ended,
      endStatus: status,
      endedRequest: request,
      endUnconfirmed: unconfirmed,
    );
    await _dropEngine();
    // The system's call screen (if it was used to answer) must not outlive the call.
    unawaited(_callUi.end(arg));
    _reporter.record(CallEventType.callLeft);
    unawaited(_reporter.flush());

    if (request == null && !unconfirmed) {
      try {
        final latest = await _repo.get(arg);
        if (_closed) return;
        state = state.copyWith(endedRequest: latest, endStatus: latest.status);
      } catch (_) {}
    }
    // Whatever just happened to the money, the lists and the wallet are stale.
    ref.invalidate(incomingCallRequestsNotifierProvider);
    ref.invalidate(outgoingActiveRequestsProvider);
  }

  Future<void> _dropEngine() async {
    final engine = _engine;
    _engine = null;
    _peerUid = null;
    _joinConfirm?.cancel();
    _joinConfirm = null;
    unawaited(_mediaSub?.cancel());
    _mediaSub = null;
    if (!_closed) {
      state = state.copyWith(
        mediaReady: false,
        peerPresent: false,
        peerVideo: false,
        clearPeerUid: true,
      );
    }
    if (engine != null) {
      await engine.leave();
      await engine.dispose();
    }
  }

  // ---- failing -----------------------------------------------------------

  void _fail(CallFailure failure) {
    if (_closed) return;
    state = state.copyWith(phase: CallPhase.failed, failure: failure);
    // A call answered on the phone's own call screen that then cannot start (it
    // was cancelled meanwhile, no microphone ...) must not stay "in progress".
    unawaited(_callUi.end(arg));
  }

  void _failFrom(Object error) {
    _callLog(arg, 'failed: $error');
    if (error is CallRequestException) {
      _fail(CallFailure(CallFailureKind.server, error.message, code: error.code));
    } else {
      _fail(CallFailure(CallFailureKind.network, ApiException.messageFor(error)));
    }
  }

  // ---- controls ----------------------------------------------------------

  Future<void> toggleMic() async {
    final muted = !state.micMuted;
    state = state.copyWith(micMuted: muted);
    _reporter.record(muted ? CallEventType.micOff : CallEventType.micOn);
    await _engine?.setMicMuted(muted);
  }

  Future<void> toggleCamera() async {
    final off = !state.cameraOff;
    state = state.copyWith(cameraOff: off);
    _reporter.record(off ? CallEventType.cameraOff : CallEventType.cameraOn);
    await _engine?.setCameraOff(off);
  }

  Future<void> switchCamera() async {
    _reporter.record(CallEventType.cameraSwitched);
    await _engine?.switchCamera();
  }

  Future<void> toggleSpeaker() async {
    final on = !state.speakerOn;
    state = state.copyWith(speakerOn: on);
    _reporter.record(on ? CallEventType.speakerOn : CallEventType.speakerOff);
    await _engine?.setSpeakerOn(on);
  }

  /// Sends a chat line. Returns false if it could not be sent (the screen then
  /// keeps the text in the box). The text itself is never reported, only that a
  /// message of that length was sent.
  Future<bool> sendChat(String text) async {
    final engine = _engine;
    final trimmed = text.trim();
    if (engine == null || trimmed.isEmpty) return false;
    final sent = await engine.sendChat(trimmed);
    if (_closed || !sent) return false;
    _reporter.record(
      CallEventType.chatMessageSent,
      details: {'length': trimmed.length},
    );
    state = state.copyWith(chat: _withMessage(trimmed, mine: true));
    return true;
  }

  void chatVisible(bool open) {
    if (_chatOpen == open) return;
    _chatOpen = open;
    _reporter.record(open ? CallEventType.chatOpened : CallEventType.chatClosed);
    if (open) state = state.copyWith(unreadChat: 0);
  }

  /// Fed from the screen's app-lifecycle observer.
  void lifecycleChanged(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) {
      _reporter.record(CallEventType.appBackgrounded);
    } else if (lifecycle == AppLifecycleState.resumed) {
      _reporter.record(CallEventType.appForegrounded);
      // Timers may have been held back while the app was in the background:
      // tell the server we are here straight away.
      if (state.isActive && !_busy) _scheduleBeat(after: Duration.zero);
    }
  }

  void _teardown() {
    _closed = true;
    _joinGuard?.cancel();
    final joining = _joinDone;
    if (joining != null && !joining.isCompleted) {
      joining.completeError(StateError('call screen closed'));
    }
    _beat?.cancel();
    _flush?.cancel();
    _joinConfirm?.cancel();
    _notesFlush?.cancel();
    _mediaSub?.cancel();
    final engine = _engine;
    _engine = null;
    if (_live) _reporter.record(CallEventType.callLeft);
    unawaited(_callUi.end(arg));
    unawaited(_reporter.flush());
    if (engine != null) {
      unawaited(() async {
        await engine.leave();
        await engine.dispose();
      }());
    }
  }
}
