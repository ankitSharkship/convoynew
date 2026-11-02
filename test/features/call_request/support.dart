import 'dart:async';

import 'package:convoynew/core/services/push_events_service.dart';
import 'package:convoynew/features/call_request/incoming_call/incoming_call_controller.dart';
import 'package:convoynew/features/call_request/incoming_call/incoming_call_ui.dart';
import 'package:convoynew/features/call_request/presentation/call/call_foreground_service.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/media/call_media_engine.dart';
import 'package:convoynew/features/call_request/media/call_permissions.dart';
import 'package:convoynew/features/call_request/presentation/state/call_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:convoynew/features/call_request/domain/repositories/call_request_repository.dart';
import 'package:convoynew/features/call_request/domain/usecases/call_request_usecases.dart';
import 'package:convoynew/features/call_request/presentation/state/call_request_notifier.dart';
import 'package:convoynew/features/search/domain/entities/truck_search_result_entity.dart';
import 'package:convoynew/features/wallet/domain/entities/wallet_entity.dart';
import 'package:convoynew/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

CallRequestEntity request(
  String status, {
  String role = 'requester',
  String? settledAmount,
  String id = 'r1',
  String requesterName = 'Asha',
  String amount = '150.00',
  String holdAmount = '37.50',
  DateTime? createdAt,
  DateTime? ringEndsAt,
  DateTime? feedbackDeadline,
  int? connectedSeconds,
  String providerName = 'Vikram',
}) => CallRequestEntity(
  id: id,
  role: role,
  status: status,
  topic: 'Route status',
  durationMinutes: 15,
  amount: amount,
  holdAmount: holdAmount,
  requester: CallPartyEntity(id: 'a', name: requesterName),
  provider: CallPartyEntity(id: 'p', name: providerName),
  expiresAt: DateTime.utc(2030),
  createdAt: createdAt ?? DateTime.utc(2029),
  settledAmount: settledAmount,
  ringEndsAt: ringEndsAt,
  feedbackDeadline: feedbackDeadline,
  connectedSeconds: connectedSeconds,
);

/// Answers `get` from a script, one entry per call (the last one repeats).
class FakeRepository implements CallRequestRepository {
  final List<Object> script;
  int getCalls = 0;
  int cancelCalls = 0;
  Object? cancelResult;
  Object? createResult;
  Object? acceptResult;
  Object? rejectResult;
  int acceptCalls = 0;
  int rejectCalls = 0;

  /// What `getIncoming` returns (or throws, if [incoming] is an exception).
  Object incoming = const <CallRequestEntity>[];
  int incomingCalls = 0;
  final List<Map<String, Object?>> createCalls = [];

  // --- the call itself ---
  Object? startResult;

  /// When set, `start` waits for it (to close the screen while it is pending).
  Completer<void>? startGate;
  Object? joinResult;
  Object? endResult;
  Object? feedbackResult;
  int startCalls = 0;
  int joinCalls = 0;
  int endCalls = 0;
  final List<bool> feedbackAnswers = [];

  /// Heartbeat answers, one per beat (the last one repeats). Each is a
  /// [CallHeartbeatEntity] or something to throw.
  List<Object> heartbeats = [];
  final List<bool> heartbeatPeerPresent = [];

  /// What `getOutgoingActive` returns (or throws).
  Object outgoing = const <CallRequestEntity>[];
  int outgoingCalls = 0;

  /// Every batch of behaviour events sent, in order; `eventsError` makes the
  /// next sends fail.
  final List<List<CallBehaviourEvent>> eventBatches = [];
  Object? eventsError;

  List<String> get eventTypes => [
    for (final batch in eventBatches) ...batch.map((e) => e.type),
  ];

  FakeRepository(this.script);

  @override
  Future<CallRequestEntity> get(String requestId) async {
    final item =
        script[getCalls < script.length ? getCalls : script.length - 1];
    getCalls++;
    if (item is CallRequestEntity) return item;
    throw item;
  }

  @override
  Future<CallRequestEntity> cancel(String requestId) async {
    cancelCalls++;
    final result = cancelResult;
    if (result is CallRequestEntity) return result;
    throw result ?? StateError('no cancel result scripted');
  }

  @override
  Future<List<CallRequestEntity>> getIncoming() async {
    incomingCalls++;
    final result = incoming;
    if (result is List<CallRequestEntity>) return result;
    throw result;
  }

  @override
  Future<CallRequestEntity> accept(String requestId) async {
    acceptCalls++;
    final result = acceptResult;
    if (result is CallRequestEntity) return result;
    throw result ?? StateError('no accept result scripted');
  }

  @override
  Future<CallRequestEntity> reject(String requestId) async {
    rejectCalls++;
    final result = rejectResult;
    if (result is CallRequestEntity) return result;
    throw result ?? StateError('no reject result scripted');
  }

  @override
  Future<CallRequestEntity> create({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  }) async {
    createCalls.add({
      'providerId': providerId,
      'truckRouteId': truckRouteId,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'amountRupees': amountRupees,
    });
    final result = createResult;
    if (result is CallRequestEntity) return result;
    throw result ?? StateError('no create result scripted');
  }

  @override
  Future<List<CallRequestEntity>> getOutgoingActive() async {
    outgoingCalls++;
    final result = outgoing;
    if (result is List<CallRequestEntity>) return result;
    throw result;
  }

  @override
  Future<CallJoinResult> start(String requestId) async {
    startCalls++;
    await startGate?.future;
    final result = startResult;
    if (result is CallJoinResult) return result;
    throw result ?? StateError('no start result scripted');
  }

  @override
  Future<CallJoinResult> join(String requestId) async {
    joinCalls++;
    final result = joinResult;
    if (result is CallJoinResult) return result;
    throw result ?? StateError('no join result scripted');
  }

  @override
  Future<CallHeartbeatEntity> heartbeat(
    String requestId,
    bool peerPresent,
  ) async {
    heartbeatPeerPresent.add(peerPresent);
    final index = heartbeatPeerPresent.length - 1;
    if (heartbeats.isEmpty) throw StateError('no heartbeat scripted');
    final item = heartbeats[index < heartbeats.length ? index : heartbeats.length - 1];
    if (item is CallHeartbeatEntity) return item;
    throw item;
  }

  @override
  Future<CallRequestEntity> end(String requestId) async {
    endCalls++;
    final result = endResult;
    if (result is CallRequestEntity) return result;
    throw result ?? StateError('no end result scripted');
  }

  @override
  Future<CallRequestEntity> submitFeedback(
    String requestId,
    bool satisfied,
  ) async {
    feedbackAnswers.add(satisfied);
    final result = feedbackResult;
    if (result is CallRequestEntity) return result;
    throw result ?? StateError('no feedback result scripted');
  }

  @override
  Future<void> sendEvents(
    String requestId,
    List<CallBehaviourEvent> events,
  ) async {
    if (eventsError != null) throw eventsError!;
    eventBatches.add(events);
  }
}



/// The truck post the form is opened from; its poster is the driver, 'u'.
TruckSearchResultEntity truck({String userName = 'Vikramjeet Singh'}) =>
    TruckSearchResultEntity(
      truckId: 't',
      truckRouteId: 'r',
      truckNumber: 'HR26DQ8821',
      truckType: 'Container',
      capacity: 32,
      origin: 'Manesar',
      originDistanceKm: 0,
      status: 'active',
      originLocation: const TruckSearchLocationEntity(
        lat: 1,
        lng: 1,
        name: 'Manesar',
        type: 'city',
      ),
      currentLocation: const TruckSearchLocationEntity(
        lat: 1,
        lng: 1,
        name: 'Manesar',
        type: 'city',
      ),
      destinations: const [],
      userId: 'u',
      userName: userName,
      userMobile: '9999999999',
      mutualsCount: 0,
      mutualNames: const [],
      createdAt: DateTime(2026),
      expiresAt: DateTime(2027),
    );

/// A wallet with [spendable] rupees free, or (null) one that can't be loaded.
class FakeWallet extends WalletNotifier {
  final String? spendable;

  FakeWallet(this.spendable);

  @override
  Future<WalletData> build() async {
    final s = spendable;
    if (s == null) throw StateError('wallet unavailable');
    return WalletData(
      wallet: WalletEntity(
        availableBalance: s,
        reservedBalance: '0.00',
        status: 'active',
      ),
      transactions: const [],
    );
  }
}

/// Records what the form submits and answers with [result] or throws [error].
class FakeComposer extends CallRequestComposer {
  Object? error;
  CallRequestEntity? result;
  final List<Map<String, Object?>> calls = [];

  @override
  Future<CallRequestEntity> submit({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  }) async {
    calls.add({
      'providerId': providerId,
      'truckRouteId': truckRouteId,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'amountRupees': amountRupees,
    });
    if (error != null) throw error!;
    return result!;
  }
}

/// The use-case overrides that make the status sheet talk to [repo].
List<Override> repoOverrides(FakeRepository repo) => [
  getCallRequestUseCaseProvider.overrideWithValue(GetCallRequestUseCase(repo)),
  cancelCallRequestUseCaseProvider.overrideWithValue(
    CancelCallRequestUseCase(repo),
  ),
  getIncomingCallRequestsUseCaseProvider.overrideWithValue(
    GetIncomingCallRequestsUseCase(repo),
  ),
  acceptCallRequestUseCaseProvider.overrideWithValue(
    AcceptCallRequestUseCase(repo),
  ),
  rejectCallRequestUseCaseProvider.overrideWithValue(
    RejectCallRequestUseCase(repo),
  ),
];

CallCredentialsEntity credentials({
  bool audioOnly = false,
  DateTime? ringEndsAt,
  int durationSeconds = 900,
}) => CallCredentialsEntity(
  requestId: 'r1',
  role: audioOnly ? 'requester' : 'provider',
  appId: 'app',
  channelName: 'call-r1',
  uid: audioOnly ? 222 : 111,
  rtcToken: 'token',
  tokenExpiresAt: DateTime.utc(2030),
  durationSeconds: durationSeconds,
  audioOnly: audioOnly,
  ringEndsAt: ringEndsAt,
);

CallHeartbeatEntity beat(
  String status, {
  int connected = 0,
  int remaining = 900,
}) => CallHeartbeatEntity(
  status: status,
  connectedSeconds: connected,
  remainingSeconds: remaining,
  thresholdSeconds: 30,
);

/// A media engine that records what it is asked and lets a test make things
/// happen in the "channel" ([emit]).
class FakeMediaEngine implements CallMediaEngine {
  final _controller = StreamController<CallMediaEvent>.broadcast(sync: true);
  final List<String> log = [];
  CallCredentialsEntity? joinedWith;
  Object? joinError;

  /// When set, `join` waits for it (a media channel that is slow to come up).
  Completer<void>? joinGate;

  /// When set, `leave` waits for it (an engine that is stuck).
  Completer<void>? leaveGate;
  bool chatWorks = true;
  final List<String> chatSent = [];

  @override
  Stream<CallMediaEvent> get events => _controller.stream;

  void emit(CallMediaEvent event) => _controller.add(event);

  bool get left => log.contains('leave');
  bool get disposed => log.contains('dispose');

  @override
  Future<void> join(CallCredentialsEntity credentials) async {
    log.add('join');
    await joinGate?.future;
    if (joinError != null) throw joinError!;
    joinedWith = credentials;
  }

  @override
  Future<void> leave() async {
    log.add('leave');
    await leaveGate?.future;
  }

  @override
  Future<void> setMicMuted(bool muted) async => log.add('mic:$muted');

  @override
  Future<void> setCameraOff(bool off) async => log.add('camera_off:$off');

  @override
  Future<void> switchCamera() async => log.add('switch');

  @override
  Future<void> setSpeakerOn(bool on) async => log.add('speaker:$on');

  @override
  Future<bool> sendChat(String text) async {
    if (!chatWorks) return false;
    chatSent.add(text);
    return true;
  }

  @override
  Widget localVideo() => const SizedBox(key: Key('local-video'));

  @override
  Widget remoteVideo(int uid) => SizedBox(key: Key('remote-video-$uid'));

  @override
  Future<void> dispose() async {
    log.add('dispose');
    unawaited(_controller.close());
  }
}

class FakePermissions implements CallPermissions {
  CallPermissionResult result = CallPermissionResult.allGranted;
  final List<bool> asked = []; // needCamera of each request
  int settingsOpened = 0;

  @override
  Future<CallPermissionResult> request({required bool needCamera}) async {
    asked.add(needCamera);
    return result;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}

/// A clock a test moves by hand (the fake timers of `pump` don't move
/// `DateTime.now()`).
class FakeClock {
  DateTime now = DateTime.utc(2029, 1, 1, 12);
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

class FakePushSource implements PushEventsSource {
  final whileOpenController = StreamController<PushEvent>.broadcast(sync: true);
  final tappedController = StreamController<PushEvent>.broadcast(sync: true);
  PushEvent? launched;

  @override
  Stream<PushEvent> get whileOpen => whileOpenController.stream;

  @override
  Stream<PushEvent> get tapped => tappedController.stream;

  @override
  Future<PushEvent?> launchedFrom() async => launched;
}

/// The phone's own call screen, driven by the test.
class FakeIncomingCallUi implements IncomingCallUi {
  final _events = StreamController<IncomingCallEvent>.broadcast(sync: true);
  final _tokens = StreamController<String>.broadcast(sync: true);
  final List<String> log = [];
  final List<IncomingCallInfo> shown = [];
  List<String> answeredWhileAway = [];
  String? token;
  bool sandbox = false;
  @override
  bool showsWhileAppIsOpen = true;

  void emit(IncomingCallEventType type, String id) =>
      _events.add(IncomingCallEvent(type, id));
  void emitToken(String value) => _tokens.add(value);

  @override
  Stream<IncomingCallEvent> get events => _events.stream;

  @override
  Future<void> prepare() async => log.add('prepare');

  @override
  Future<void> requestPermissions() async => log.add('permissions');

  @override
  Future<void> show(IncomingCallInfo info) async {
    shown.add(info);
    log.add('show:${info.requestId}');
  }

  @override
  Future<void> end(String requestId) async => log.add('end:$requestId');

  @override
  Future<void> setConnected(String requestId) async =>
      log.add('connected:$requestId');

  @override
  Future<List<String>> acceptedWhileAway() async => answeredWhileAway;

  @override
  Future<String?> currentVoipToken() async => token;

  @override
  Stream<String> get voipTokenChanges => _tokens.stream;

  @override
  Future<bool> isVoipSandbox() async => sandbox;
}

class FakeCallService implements CallForegroundService {
  final List<String> log = [];
  bool? lastWithCamera;

  @override
  Future<void> start({
    required String title,
    required String text,
    required bool withCamera,
  }) async {
    log.add('start:$title|$text');
    lastWithCamera = withCamera;
  }

  @override
  Future<void> stop() async => log.add('stop');
}

/// Everything the call controller depends on, swapped for fakes.
List<Override> callOverrides({
  required FakeRepository repo,
  required FakeMediaEngine engine,
  FakePermissions? permissions,
  FakeClock? clock,
  List<FakeMediaEngine>? engines,
  FakeIncomingCallUi? callUi,
  FakeCallService? service,
  FakePushSource? push,
}) => [
  if (callUi != null) incomingCallUiProvider.overrideWithValue(callUi),
  if (service != null) callForegroundServiceProvider.overrideWithValue(service),
  if (push != null) pushEventsSourceProvider.overrideWithValue(push),
  callRepositoryProvider.overrideWithValue(repo),
  callMediaEngineFactoryProvider.overrideWithValue(() {
    engines?.add(engine);
    return engine;
  }),
  callPermissionsProvider.overrideWithValue(permissions ?? FakePermissions()),
  if (clock != null) callClockProvider.overrideWithValue(clock.call),
];
