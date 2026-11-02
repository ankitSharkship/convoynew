import 'dart:async';

import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:convoynew/features/call_request/media/call_media_engine.dart';
import 'package:convoynew/features/call_request/media/call_permissions.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_controller.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const id = 'r1';

class Harness {
  final FakeRepository repo;
  final FakeMediaEngine engine;
  final FakePermissions permissions;
  final FakeClock clock;
  final ProviderContainer container;
  final ProviderSubscription<CallSessionState> sub;

  Harness(this.repo, this.engine, this.permissions, this.clock, this.container)
    : sub = container.listen(callSessionProvider(id), (_, _) {});

  CallSessionState get state => sub.read();
  CallSessionNotifier get ctl => container.read(callSessionProvider(id).notifier);

  /// Runs one controller action to completion. `testWidgets` has no real event
  /// loop, so a plain `await` on it would never finish: pump until it is done.
  Future<T> run<T>(WidgetTester tester, Future<T> Function() action) async {
    late T result;
    Object? error;
    StackTrace? stack;
    var done = false;
    action().then(
      (value) {
        result = value;
        done = true;
      },
      onError: (Object e, StackTrace st) {
        error = e;
        stack = st;
        done = true;
      },
    );
    for (var i = 0; i < 50 && !done; i++) {
      await tester.pump();
    }
    expect(done, isTrue, reason: 'the action never finished');
    if (error != null) Error.throwWithStackTrace(error!, stack!);
    return result;
  }

  /// Moves both the fake timers and the clock the controller reads.
  Future<void> elapse(WidgetTester tester, Duration d) async {
    clock.advance(d);
    await tester.pump(d);
    await tester.pump();
  }

  /// Takes the "screen" away: disposes the controller, which cancels its
  /// timers so none outlives the test.
  Future<void> close(WidgetTester tester) async {
    sub.close();
    container.dispose();
    await tester.pump(Duration.zero);
  }
}

Harness boot({
  FakeRepository? repo,
  FakePermissions? permissions,
  FakeMediaEngine? engine,
  FakeIncomingCallUi? callUi,
}) {
  final r = repo ?? FakeRepository([request('live')]);
  final e = engine ?? FakeMediaEngine();
  final p = permissions ?? FakePermissions();
  final clock = FakeClock();
  final container = ProviderContainer(
    overrides: callOverrides(
      repo: r,
      engine: e,
      permissions: p,
      clock: clock,
      callUi: callUi,
    ),
  );
  return Harness(r, e, p, clock, container);
}

/// A repository set up for the driver starting a call that rings for 45 s.
FakeRepository driverRepo(FakeClock? clock) {
  final ringEnds = (clock?.now ?? DateTime.utc(2029, 1, 1, 12)).add(
    const Duration(seconds: 45),
  );
  return FakeRepository([request('ringing')])
    ..startResult = CallJoinResult(
      request: request('ringing', role: 'provider', ringEndsAt: ringEnds),
      credentials: credentials(ringEndsAt: ringEnds),
    )
    ..endResult = request('awaiting_feedback', role: 'provider')
    ..heartbeats = [beat('ringing')];
}

FakeRepository requesterRepo() => FakeRepository([request('live')])
  ..joinResult = CallJoinResult(
    request: request('live'),
    credentials: credentials(audioOnly: true),
  )
  ..endResult = request('awaiting_feedback')
  ..heartbeats = [beat('live', connected: 5, remaining: 880)];

void main() {
  group('the driver starts the call', () {
    testWidgets('asks for mic and camera first, rings, joins with a camera', (
      tester,
    ) async {
      final h = boot(repo: driverRepo(null));
      await h.run(tester, () => h.ctl.startAsDriver());

      expect(h.permissions.asked, [true]); // camera needed
      expect(h.repo.startCalls, 1);
      expect(h.state.phase, CallPhase.ringing);
      expect(h.engine.joinedWith?.audioOnly, isFalse);
      expect(h.state.ringEndsAt, isNotNull);
      expect(h.ctl.engine, same(h.engine));
      await h.close(tester);
    });

    testWidgets('a denied camera stops it before anyone is rung', (
      tester,
    ) async {
      final h = boot(
        repo: driverRepo(null),
        permissions: FakePermissions()
          ..result = const CallPermissionResult(
            microphone: PermissionOutcome.granted,
            camera: PermissionOutcome.denied,
          ),
      );
      await h.run(tester, () => h.ctl.startAsDriver());

      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.cameraDenied);
      expect(h.repo.startCalls, 0, reason: 'must not ring the requester');
      expect(h.engine.log, isEmpty);
      await h.close(tester);
    });

    testWidgets('a blocked microphone says to open the settings', (
      tester,
    ) async {
      final h = boot(
        repo: driverRepo(null),
        permissions: FakePermissions()
          ..result = const CallPermissionResult(
            microphone: PermissionOutcome.permanentlyDenied,
            camera: PermissionOutcome.granted,
          ),
      );
      await h.run(tester, () => h.ctl.startAsDriver());
      expect(h.state.failure?.kind, CallFailureKind.microphoneBlocked);
      expect(h.state.failure?.needsSettings, isTrue);
      expect(h.repo.startCalls, 0);
      await h.close(tester);
    });

    testWidgets('the server refusing (request expired) is shown, not swallowed', (
      tester,
    ) async {
      final repo = driverRepo(null)
        ..startResult = const CallRequestException(
          code: 'REQUEST_EXPIRED',
          message: 'This request has expired',
          statusCode: 410,
        );
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.startAsDriver());
      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.server);
      expect(h.state.failure?.code, 'REQUEST_EXPIRED');
      expect(h.state.failure?.message, 'This request has expired');
      await h.close(tester);
    });

    testWidgets('no network is a network failure', (tester) async {
      final repo = driverRepo(null)..startResult = const ApiException();
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.startAsDriver());
      expect(h.state.failure?.kind, CallFailureKind.network);
      await h.close(tester);
    });

    testWidgets(
      'if the phone cannot start the media, the ring is cancelled again',
      (tester) async {
        final h = boot(
          repo: driverRepo(null),
          engine: FakeMediaEngine()..joinError = StateError('no camera'),
        );
        await h.run(tester, () => h.ctl.startAsDriver());

        expect(h.state.phase, CallPhase.failed);
        expect(h.state.failure?.kind, CallFailureKind.media);
        expect(h.repo.endCalls, 1, reason: 'the requester must stop ringing');
        expect(h.engine.disposed, isTrue);
        await h.close(tester);
      },
    );

    testWidgets('starting twice does nothing the second time', (tester) async {
      final h = boot(repo: driverRepo(null));
      await h.run(tester, () => h.ctl.startAsDriver());
      await h.run(tester, () => h.ctl.startAsDriver());
      expect(h.repo.startCalls, 1);
      await h.close(tester);
    });

    testWidgets('goes live when the requester answers', (tester) async {
      final repo = driverRepo(null)
        ..heartbeats = [
          beat('ringing'),
          beat('live', connected: 0, remaining: 899),
        ];
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.startAsDriver());
      expect(h.state.phase, CallPhase.ringing);

      await h.elapse(tester, const Duration(seconds: 1)); // first beat
      expect(h.state.phase, CallPhase.ringing);
      await h.elapse(tester, callRingPollInterval); // second beat: live
      expect(h.state.phase, CallPhase.live);
      expect(h.state.remainingSeconds, 899);
      await h.close(tester);
    });

    testWidgets('a ring nobody answers is handed back (can start again)', (
      tester,
    ) async {
      final clock = FakeClock();
      final repo = driverRepo(clock)..endResult = request('accepted', role: 'provider');
      final engine = FakeMediaEngine();
      final container = ProviderContainer(
        overrides: callOverrides(
          repo: repo,
          engine: engine,
          permissions: FakePermissions(),
          clock: clock,
        ),
      );
      final h = Harness(repo, engine, FakePermissions(), clock, container);
      await h.run(tester, () => h.ctl.startAsDriver());

      // Heartbeats keep saying "still ringing" until the 45 s (+ grace) pass.
      for (var i = 0; i < 20 && !h.state.isOver; i++) {
        await h.elapse(tester, callRingPollInterval);
      }

      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endStatus, CallStatus.accepted);
      expect(h.repo.endCalls, 1);
      expect(h.engine.left, isTrue);
      await h.close(tester);
    });

    testWidgets('cancelling while it rings ends it as "accepted" again', (
      tester,
    ) async {
      final repo = driverRepo(null)
        ..endResult = request('accepted', role: 'provider');
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.startAsDriver());
      await h.run(tester, () => h.ctl.hangUp());

      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endStatus, CallStatus.accepted);
      expect(h.engine.left && h.engine.disposed, isTrue);
      await h.close(tester);
    });
  });

  group('the requester answers', () {
    testWidgets('only needs the microphone, joins audio-only, is live', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());

      expect(h.permissions.asked, [false]);
      expect(h.repo.joinCalls, 1);
      expect(h.state.phase, CallPhase.live);
      expect(h.engine.joinedWith?.audioOnly, isTrue);
      expect(h.repo.eventTypes, isEmpty); // not sent yet: they are batched
      await h.close(tester);
    });

    testWidgets('if this phone\'s audio will not start, the call is ended so the driver is not left waiting', (
      tester,
    ) async {
      final h = boot(
        repo: requesterRepo(),
        engine: FakeMediaEngine()..joinError = StateError('audio device busy'),
      );
      await h.run(tester, () => h.ctl.answerAsRequester());
      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.media);
      expect(h.repo.endCalls, 1);
      await h.close(tester);
    });

    testWidgets('answering too late shows the server\'s reason', (tester) async {
      final repo = requesterRepo()
        ..joinResult = const CallRequestException(
          code: 'RING_OVER',
          message: 'This call wasn\'t answered in time',
          statusCode: 409,
        );
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.code, 'RING_OVER');
      expect(h.engine.log, isEmpty);
      await h.close(tester);
    });

    testWidgets('declining cancels the request and sends no media', (
      tester,
    ) async {
      final repo = requesterRepo()..endResult = request('cancelled');
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.decline());

      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endStatus, CallStatus.cancelled);
      expect(h.repo.joinCalls, 0);
      expect(h.engine.log, isEmpty);
      await tester.pump(Duration.zero);
      expect(h.repo.eventTypes, contains(CallEventType.ringDeclined));
      await h.close(tester);
    });
  });

  group('the phone\'s own call screen', () {
    testWidgets('is told the call is connected, and taken down when the call ends', (
      tester,
    ) async {
      final ui = FakeIncomingCallUi();
      final h = boot(repo: requesterRepo(), callUi: ui);
      await h.run(tester, () => h.ctl.answerAsRequester());
      h.engine.emit(const MediaJoined());
      expect(ui.log, contains('connected:r1'));
      expect(ui.log.where((l) => l.startsWith('end:')), isEmpty);

      await h.run(tester, () => h.ctl.hangUp());
      expect(ui.log, contains('end:r1'));
      await h.close(tester);
    });

    testWidgets('is taken down when the other side ends the call', (tester) async {
      final ui = FakeIncomingCallUi();
      final repo = requesterRepo()
        ..heartbeats = [beat('live', connected: 40), beat('awaiting_feedback', connected: 41, remaining: 0)];
      repo.script
        ..clear()
        ..add(request('awaiting_feedback'));
      final h = boot(repo: repo, callUi: ui);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, const Duration(seconds: 1));
      await h.elapse(tester, callHeartbeatInterval);
      expect(h.state.phase, CallPhase.ended);
      expect(ui.log, contains('end:r1'));
      await h.close(tester);
    });

    testWidgets('does not outlive the screen: closing mid-call takes it down too', (
      tester,
    ) async {
      final ui = FakeIncomingCallUi();
      final h = boot(repo: requesterRepo(), callUi: ui);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.close(tester);
      expect(ui.log, contains('end:r1'));
    });

    testWidgets('a call answered there that then cannot start is taken down at once, not left "in progress"', (
      tester,
    ) async {
      final ui = FakeIncomingCallUi();
      final repo = requesterRepo()
        ..joinResult = const CallRequestException(code: 'INVALID_STATE', message: 'This call can no longer be joined', statusCode: 409);
      final h = boot(repo: repo, callUi: ui);
      await h.run(tester, () => h.ctl.answerAsRequester());
      expect(h.state.phase, CallPhase.failed);
      expect(ui.log, contains('end:r1')); // while the failure message is still on screen
      expect(ui.log, isNot(contains('connected:r1')));
      await h.close(tester);
    });

    testWidgets('so is one that cannot start for want of a microphone', (tester) async {
      final ui = FakeIncomingCallUi();
      final h = boot(
        repo: requesterRepo(),
        callUi: ui,
        permissions: FakePermissions()
          ..result = const CallPermissionResult(
            microphone: PermissionOutcome.permanentlyDenied,
            camera: PermissionOutcome.granted,
          ),
      );
      await h.run(tester, () => h.ctl.answerAsRequester());
      expect(ui.log, contains('end:r1'));
      await h.close(tester);
    });
  });

  group('declining and closing early', () {
    testWidgets('a decline the server never heard changes nothing and can be retried', (
      tester,
    ) async {
      final repo = requesterRepo()..endResult = const ApiException();
      final h = boot(repo: repo);

      expect(await h.run(tester, () => h.ctl.decline()), isFalse);
      expect(h.state.phase, CallPhase.starting, reason: 'still ringing, nothing decided');
      expect(h.state.failure, isNull);

      repo.endResult = request('cancelled');
      expect(await h.run(tester, () => h.ctl.decline()), isTrue);
      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endStatus, CallStatus.cancelled);
      expect(repo.endCalls, 2);
      await h.close(tester);
    });

    testWidgets('leaving while the server is still ringing the requester ends that ring', (
      tester,
    ) async {
      final repo = driverRepo(null)..startGate = Completer<void>();
      final h = boot(repo: repo);

      unawaited(h.ctl.startAsDriver());
      await tester.pump();
      expect(repo.startCalls, 1);

      await h.close(tester); // the driver backed out of the screen
      repo.startGate!.complete();
      await tester.pump();
      await tester.pump();

      expect(repo.endCalls, 1, reason: 'the requester must stop ringing');
      expect(h.engine.log, isEmpty, reason: 'no media was ever started');
    });
  });

  group('while the call is on', () {
    testWidgets('each heartbeat says whether the other person is in the channel', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());

      await h.elapse(tester, const Duration(seconds: 1));
      expect(h.repo.heartbeatPeerPresent, [false]); // nobody else yet

      h.engine.emit(const MediaPeerJoined(111));
      expect(h.state.peerPresent, isTrue);
      await h.elapse(tester, callHeartbeatInterval);
      expect(h.repo.heartbeatPeerPresent.last, isTrue);

      h.engine.emit(const MediaPeerLeft(111));
      expect(h.state.peerPresent, isFalse);
      await h.elapse(tester, callHeartbeatInterval);
      expect(h.repo.heartbeatPeerPresent.last, isFalse);
      await h.close(tester);
    });

    testWidgets('the server\'s time and "counted" status are shown', (tester) async {
      final repo = requesterRepo()
        ..heartbeats = [beat('live', connected: 41, remaining: 700)];
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, const Duration(seconds: 1));

      expect(h.state.connectedSeconds, 41);
      expect(h.state.remainingSeconds, 700);
      expect(h.state.counted, isTrue);
      await h.close(tester);
    });

    testWidgets('the other side hanging up ends it here too, and leaves the channel', (
      tester,
    ) async {
      final repo = requesterRepo()
        ..heartbeats = [
          beat('live', connected: 40),
          beat('awaiting_feedback', connected: 41, remaining: 0),
        ]
        ..outgoing = const <CallRequestEntity>[];
      repo.script
        ..clear()
        ..add(request('awaiting_feedback', settledAmount: null));
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, const Duration(seconds: 1));
      await h.elapse(tester, callHeartbeatInterval);

      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endStatus, CallStatus.awaitingFeedback);
      expect(h.engine.left && h.engine.disposed, isTrue);
      await h.close(tester);
    });

    testWidgets('a call too short to count ends as failed', (tester) async {
      final repo = requesterRepo()
        ..heartbeats = [beat('live', connected: 3), beat('failed', connected: 8, remaining: 0)];
      repo.script
        ..clear()
        ..add(request('failed'));
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, const Duration(seconds: 1));
      await h.elapse(tester, callHeartbeatInterval);
      expect(h.state.endStatus, CallStatus.failed);
      await h.close(tester);
    });

    testWidgets('failing heartbeats flag an unreachable server, a good one clears it', (
      tester,
    ) async {
      final repo = requesterRepo()
        ..heartbeats = [
          const ApiException(),
          const ApiException(),
          beat('live', connected: 10),
        ];
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());

      await h.elapse(tester, const Duration(seconds: 1));
      expect(h.state.serverUnreachable, isFalse); // one failure is not yet news
      await h.elapse(tester, callHeartbeatInterval);
      expect(h.state.serverUnreachable, isTrue);
      expect(h.state.phase, CallPhase.live, reason: 'the call itself carries on');
      await h.elapse(tester, callHeartbeatInterval);
      expect(h.state.serverUnreachable, isFalse);
      await h.close(tester);
    });

    testWidgets('another phone taking the call over makes this one leave quietly', (
      tester,
    ) async {
      final repo = requesterRepo()
        ..heartbeats = [
          const CallRequestException(
            code: 'CALL_ON_ANOTHER_DEVICE',
            message: 'This call is on another one of your devices',
            statusCode: 409,
          ),
        ];
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, const Duration(seconds: 1));
      await h.elapse(tester, callHeartbeatInterval);

      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.onAnotherDevice);
      expect(repo.endCalls, 0, reason: 'the call goes on, on the other phone');
      expect(h.engine.left || h.engine.disposed, isTrue);
      await h.close(tester);
    });

    testWidgets('answering a call another phone already answered says so', (
      tester,
    ) async {
      final repo = requesterRepo()
        ..joinResult = const CallRequestException(
          code: 'CALL_ON_ANOTHER_DEVICE',
          message: 'This call is on another one of your devices',
          statusCode: 409,
        );
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());

      expect(h.state.failure?.kind, CallFailureKind.onAnotherDevice);
      expect(h.engine.joinedWith, isNull, reason: 'never joined the channel');
      expect(repo.endCalls, 0, reason: 'must not hang up the other phone\'s call');
      await h.close(tester);
    });

    testWidgets('hanging up ends the call and shows the server\'s verdict', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.run(tester, () => h.ctl.hangUp());

      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endStatus, CallStatus.awaitingFeedback);
      expect(h.state.endUnconfirmed, isFalse);
      expect(h.repo.endCalls, 1);
      expect(h.engine.left, isTrue);
      await h.close(tester);
    });

    testWidgets('hanging up with no connection still ends it, and says so', (
      tester,
    ) async {
      final repo = requesterRepo()..endResult = const ApiException();
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.run(tester, () => h.ctl.hangUp());

      expect(h.state.phase, CallPhase.ended);
      expect(h.state.endUnconfirmed, isTrue);
      expect(h.engine.left, isTrue, reason: 'the microphone must stop');
      await h.close(tester);
    });

    testWidgets('no more heartbeats once it is over', (tester) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.run(tester, () => h.ctl.hangUp());
      final beats = h.repo.heartbeatPeerPresent.length;
      await h.elapse(tester, callHeartbeatInterval * 4);
      expect(h.repo.heartbeatPeerPresent.length, beats);
      await h.close(tester);
    });

    testWidgets('losing the connection is shown, and so is getting it back', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());

      h.engine.emit(const MediaConnectionLost());
      expect(h.state.connectionLost, isTrue);
      h.engine.emit(const MediaConnectionRestored());
      expect(h.state.connectionLost, isFalse);
      await h.run(tester, () => h.ctl.hangUp());
      expect(
        h.repo.eventTypes,
        containsAllInOrder([
          CallEventType.networkLost,
          CallEventType.networkRestored,
        ]),
      );
      await h.close(tester);
    });

    testWidgets('the other person\'s camera showing is tracked', (tester) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      h.engine.emit(const MediaPeerJoined(111));
      h.engine.emit(const MediaPeerVideo(111, showing: true));
      expect(h.state.peerVideo, isTrue);
      h.engine.emit(const MediaPeerVideo(111, showing: false));
      expect(h.state.peerVideo, isFalse);
      await h.close(tester);
    });

    testWidgets('closing the screen mid-call leaves the channel', (tester) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.close(tester);
      expect(h.engine.left && h.engine.disposed, isTrue);
    });
  });

  group('rejoining', () {
    testWidgets('a driver rejoining needs the camera, a requester does not', (
      tester,
    ) async {
      final repo = requesterRepo();
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.rejoin(isProvider: false));
      expect(h.permissions.asked, [false]);
      expect(h.state.phase, CallPhase.live);
      expect(h.repo.joinCalls, 1);
      await h.close(tester);

      final repo2 = driverRepo(null)
        ..joinResult = CallJoinResult(
          request: request('live', role: 'provider'),
          credentials: credentials(),
        );
      final h2 = boot(repo: repo2);
      await h2.run(tester, () => h2.ctl.rejoin(isProvider: true));
      expect(h2.permissions.asked, [true]);
      await h2.close(tester);
    });

    testWidgets('the reconnect offer and the answer are both recorded', (
      tester,
    ) async {
      final repo = requesterRepo()..endResult = request('awaiting_feedback');
      final h = boot(repo: repo);
      h.ctl.rejoinOffered();
      await h.run(tester, () => h.ctl.endWithoutRejoining());
      await tester.pump(Duration.zero);
      expect(repo.endCalls, 1);
      expect(
        h.repo.eventTypes,
        containsAllInOrder([
          CallEventType.reconnectOffered,
          CallEventType.reconnectDeclined,
        ]),
      );
      await h.close(tester);
    });

    testWidgets('ending from the prompt never throws, even offline', (
      tester,
    ) async {
      final repo = requesterRepo()..endResult = const ApiException();
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.endWithoutRejoining());
      expect(repo.endCalls, 1);
      await h.close(tester);
    });
  });

  group('controls and chat', () {
    testWidgets('mic, speaker and camera toggles reach the engine and the log', (
      tester,
    ) async {
      final h = boot(repo: driverRepo(null));
      await h.run(tester, () => h.ctl.startAsDriver());

      await h.run(tester, () => h.ctl.toggleMic());
      await h.run(tester, () => h.ctl.toggleCamera());
      await h.run(tester, () => h.ctl.switchCamera());
      await h.run(tester, () => h.ctl.toggleSpeaker());
      expect(h.state.micMuted, isTrue);
      expect(h.state.cameraOff, isTrue);
      expect(h.state.speakerOn, isFalse);
      expect(
        h.engine.log,
        containsAll(['mic:true', 'camera_off:true', 'switch', 'speaker:false']),
      );

      await h.run(tester, () => h.ctl.toggleMic());
      expect(h.state.micMuted, isFalse);
      await h.run(tester, () => h.ctl.hangUp());
      expect(
        h.repo.eventTypes,
        containsAllInOrder([
          CallEventType.micOff,
          CallEventType.cameraOff,
          CallEventType.cameraSwitched,
          CallEventType.speakerOff,
          CallEventType.micOn,
        ]),
      );
      await h.close(tester);
    });

    testWidgets('chat text is sent to the other person but never reported', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());

      expect(await h.run(tester, () => h.ctl.sendChat('  My secret route  ')), isTrue);
      expect(h.engine.chatSent, ['My secret route']);
      expect(h.state.chat.single.mine, isTrue);

      await h.run(tester, () => h.ctl.hangUp());
      final sent = h.repo.eventBatches
          .expand((b) => b)
          .firstWhere((e) => e.type == CallEventType.chatMessageSent);
      expect(sent.details, {'length': 15});
      expect(
        h.repo.eventBatches.expand((b) => b).toString(),
        isNot(contains('secret')),
      );
      await h.close(tester);
    });

    testWidgets('a message that cannot be sent is not added to the chat', (
      tester,
    ) async {
      final h = boot(
        repo: requesterRepo(),
        engine: FakeMediaEngine()..chatWorks = false,
      );
      await h.run(tester, () => h.ctl.answerAsRequester());
      expect(await h.run(tester, () => h.ctl.sendChat('hello')), isFalse);
      expect(h.state.chat, isEmpty);
      expect(await h.run(tester, () => h.ctl.sendChat('   ')), isFalse);
      await h.close(tester);
    });

    testWidgets('unread messages count up until the chat is opened', (tester) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());

      h.engine.emit(const MediaChatReceived('Hello'));
      h.engine.emit(const MediaChatReceived('Are you there?'));
      expect(h.state.unreadChat, 2);
      expect(h.state.chat.map((m) => m.text), ['Hello', 'Are you there?']);

      h.ctl.chatVisible(true);
      expect(h.state.unreadChat, 0);
      h.engine.emit(const MediaChatReceived('Third'));
      expect(h.state.unreadChat, 0, reason: 'it is being read');
      await h.close(tester);
    });
  });

  group('behaviour events', () {
    testWidgets('are batched and sent while the call is on', (tester) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      h.engine.emit(const MediaJoined());
      await h.run(tester, () => h.ctl.toggleMic());
      expect(h.repo.eventBatches, isEmpty);

      await h.elapse(tester, callEventFlushInterval);
      expect(h.repo.eventTypes, [
        CallEventType.callScreenOpened,
        CallEventType.ringAnswered,
        CallEventType.callJoined,
        CallEventType.micOff,
      ]);
      await h.close(tester);
    });

    testWidgets('the last ones go out when the call ends', (tester) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.run(tester, () => h.ctl.hangUp());
      await tester.pump(Duration.zero);
      expect(
        h.repo.eventTypes,
        containsAllInOrder([CallEventType.callCut, CallEventType.callLeft]),
      );
      await h.close(tester);
    });

    testWidgets('a failing event upload never disturbs the call', (tester) async {
      final repo = requesterRepo()..eventsError = const ApiException();
      final h = boot(repo: repo);
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, callEventFlushInterval);
      expect(h.state.phase, CallPhase.live);
      expect(h.state.failure, isNull);
      await h.close(tester);
    });

    testWidgets('going to the background and coming back is recorded, and a beat is sent at once', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      await h.elapse(tester, const Duration(seconds: 1));
      final before = h.repo.heartbeatPeerPresent.length;

      h.ctl.lifecycleChanged(AppLifecycleState.paused);
      h.ctl.lifecycleChanged(AppLifecycleState.resumed);
      await h.elapse(tester, Duration.zero);
      expect(h.repo.heartbeatPeerPresent.length, before + 1);

      await h.run(tester, () => h.ctl.hangUp());
      expect(
        h.repo.eventTypes,
        containsAllInOrder([
          CallEventType.appBackgrounded,
          CallEventType.appForegrounded,
        ]),
      );
      await h.close(tester);
    });
  });

  group('the audio/video setup is watched', () {
    testWidgets('what the media layer reports is kept for diagnostics', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      h.engine.emit(const MediaDiag('startPreview TIMED OUT after 8 s'));
      await h.elapse(tester, const Duration(seconds: 3)); // notes go out soon

      final note = h.repo.eventBatches
          .expand((b) => b)
          .firstWhere((e) => e.type == CallEventType.mediaDiagnostic);
      expect(note.details, {'m': 'startPreview TIMED OUT after 8 s'});
      await h.close(tester);
    });

    testWidgets('a join the SDK never confirms offers Reconnect', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      expect(h.state.mediaReady, isFalse);
      expect(h.state.connectionLost, isFalse);

      await h.elapse(tester, callEngineConfirmTimeout);
      expect(h.state.connectionLost, isTrue);
      expect(h.state.phase, isNot(CallPhase.failed), reason: 'still on the call');
      expect(
        h.repo.eventBatches
            .expand((b) => b)
            .any((e) => e.type == CallEventType.mediaDiagnostic),
        isTrue,
      );
      await h.close(tester);
    });

    testWidgets('a join that is confirmed in time is left alone', (
      tester,
    ) async {
      final h = boot(repo: requesterRepo());
      await h.run(tester, () => h.ctl.answerAsRequester());
      h.engine.emit(const MediaJoined());
      await h.elapse(tester, callEngineConfirmTimeout * 2);
      expect(h.state.mediaReady, isTrue);
      expect(h.state.connectionLost, isFalse);
      await h.close(tester);
    });

    testWidgets('a stuck engine cannot keep the failure from showing', (
      tester,
    ) async {
      final engine = FakeMediaEngine()
        ..joinError = StateError('camera would not open')
        ..leaveGate = Completer<void>(); // leaving never returns
      final h = boot(repo: driverRepo(null), engine: engine);
      await h.run(tester, () => h.ctl.startAsDriver());

      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.media);
      expect(h.repo.endCalls, 1);
      engine.leaveGate!.complete(); // let the fake finish so no future dangles
      await tester.pump();
      await h.close(tester);
    });
  });
}
