import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/core/services/push_events_service.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/incoming_call/incoming_call_controller.dart';
import 'package:convoynew/features/call_request/incoming_call/incoming_call_ui.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_controller.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convoynew/core/storage/shared_preferences_provider.dart';

import 'support.dart';

class Rig {
  final FakeRepository repo;
  final FakeIncomingCallUi ui;
  final FakePushSource push;
  final FakeMediaEngine engine;
  final FakeClock clock;
  final ProviderContainer container;

  Rig(this.repo, this.ui, this.push, this.engine, this.clock, this.container);

  Set<String> get shown => container.read(callKitShownProvider);
  String? get pendingAnswer => container.read(pendingAnsweredCallProvider);
  void consumeAnswer() =>
      container.read(pendingAnsweredCallProvider.notifier).state = null;

  Future<void> run(WidgetTester tester, Future<void> Function() action) async {
    var done = false;
    action().whenComplete(() => done = true);
    for (var i = 0; i < 50 && !done; i++) {
      await tester.pump();
    }
    expect(done, isTrue);
  }

  Future<void> close(WidgetTester tester) async {
    container.dispose();
    await tester.pump(Duration.zero);
  }
}

Future<Rig> start(
  WidgetTester tester, {
  FakeIncomingCallUi? ui,
  FakeRepository? repo,
  Map<String, Object> savedPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(savedPrefs);
  final prefs = await SharedPreferences.getInstance();
  final r = repo ?? FakeRepository([request('live')]);
  final callUi = ui ?? FakeIncomingCallUi();
  final push = FakePushSource();
  final engine = FakeMediaEngine();
  final clock = FakeClock();
  final container = ProviderContainer(
    overrides: [
      ...callOverrides(
        repo: r,
        engine: engine,
        clock: clock,
        callUi: callUi,
        push: push,
      ),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  container.read(incomingCallControllerProvider);
  await tester.pump();
  await tester.pump();
  return Rig(r, callUi, push, engine, clock, container);
}

void main() {
  group('starting', () {
    testWidgets('starts listening but does not ask for permissions at launch (before login)', (
      tester,
    ) async {
      final rig = await start(tester);
      expect(rig.ui.log, contains('prepare'));
      expect(rig.ui.log, isNot(contains('permissions')));
      await rig.close(tester);
    });

    testWidgets('asks for the permissions the first time it is told the person is in', (
      tester,
    ) async {
      final rig = await start(tester);
      await rig.run(tester, () => rig.container.read(incomingCallControllerProvider.notifier).askPermissionsOnce());
      expect(rig.ui.log, contains('permissions'));
      await rig.close(tester);
    });

    testWidgets('but never again: they can open system settings, so once is enough', (
      tester,
    ) async {
      final rig = await start(tester, savedPrefs: {permissionsAskedKey: true});
      await rig.run(tester, () => rig.container.read(incomingCallControllerProvider.notifier).askPermissionsOnce());
      expect(rig.ui.log, isNot(contains('permissions')));
      await rig.close(tester);
    });

    testWidgets('asked twice in one go, it still asks once', (tester) async {
      final rig = await start(tester);
      final c = rig.container.read(incomingCallControllerProvider.notifier);
      await rig.run(tester, () => Future.wait([c.askPermissionsOnce(), c.askPermissionsOnce()]));
      expect(rig.ui.log.where((l) => l == 'permissions'), hasLength(1));
      await rig.close(tester);
    });

    testWidgets('a failure while asking never stops the call screen from working', (
      tester,
    ) async {
      final rig = await start(tester, ui: FakeIncomingCallUi()..answeredWhileAway = ['r9']);
      expect(rig.pendingAnswer, 'r9');
      await rig.close(tester);
    });

    testWidgets('a call answered while the app was closed is picked up', (
      tester,
    ) async {
      final rig = await start(
        tester,
        ui: FakeIncomingCallUi()..answeredWhileAway = ['r7'],
      );
      expect(rig.pendingAnswer, 'r7');
      await rig.close(tester);
    });
  });

  group('the system call screen', () {
    testWidgets('while it is up, the app knows (so it shows no second ring screen)', (
      tester,
    ) async {
      final rig = await start(tester);
      rig.ui.emit(IncomingCallEventType.shown, 'r1');
      expect(rig.shown, {'r1'});
      rig.ui.emit(IncomingCallEventType.shown, 'r2');
      expect(rig.shown, {'r1', 'r2'});
      await rig.close(tester);
    });

    testWidgets('it is forgotten when the call times out, is declined or ends', (
      tester,
    ) async {
      final rig = await start(tester);
      for (final type in [
        IncomingCallEventType.timedOut,
        IncomingCallEventType.ended,
        IncomingCallEventType.declined,
      ]) {
        rig.ui.emit(IncomingCallEventType.shown, 'r1');
        expect(rig.shown, {'r1'}, reason: '$type');
        rig.ui.emit(type, 'r1');
        await tester.pump();
        expect(rig.shown, isEmpty, reason: '$type');
      }
      await rig.close(tester);
    });

    testWidgets('Answer asks the app to open the call', (tester) async {
      final rig = await start(tester);
      rig.ui.emit(IncomingCallEventType.accepted, 'r1');
      expect(rig.pendingAnswer, 'r1');
      await rig.close(tester);
    });

    testWidgets('the same answer reported twice in a moment opens the call once', (
      tester,
    ) async {
      final rig = await start(tester);
      rig.ui.emit(IncomingCallEventType.accepted, 'r1');
      rig.consumeAnswer(); // the app opened it
      rig.ui.emit(IncomingCallEventType.accepted, 'r1'); // a second report of the same tap
      expect(rig.pendingAnswer, isNull);
      await rig.close(tester);
    });

    testWidgets('but a new ring of the same request, later, can be answered again', (
      tester,
    ) async {
      final rig = await start(tester);
      rig.ui.emit(IncomingCallEventType.accepted, 'r1');
      rig.consumeAnswer();
      rig.clock.advance(answerDedupeWindow + const Duration(seconds: 1));
      rig.ui.emit(IncomingCallEventType.accepted, 'r1');
      expect(rig.pendingAnswer, 'r1');
      await rig.close(tester);
    });

    testWidgets('a different request is never mistaken for a repeat', (tester) async {
      final rig = await start(tester);
      rig.ui.emit(IncomingCallEventType.accepted, 'r1');
      rig.consumeAnswer();
      rig.ui.emit(IncomingCallEventType.accepted, 'r2');
      expect(rig.pendingAnswer, 'r2');
      await rig.close(tester);
    });
  });

  group('Decline on the system screen', () {
    testWidgets('cancels the request, like Decline in the app', (tester) async {
      final repo = FakeRepository([request('live')])..endResult = request('cancelled');
      final rig = await start(tester, repo: repo);
      rig.ui.emit(IncomingCallEventType.declined, 'r1');
      await tester.pump();
      await tester.pump();
      expect(repo.endCalls, 1);
      expect(rig.pendingAnswer, isNull);
      await rig.close(tester);
    });

    testWidgets('offline, it quietly does nothing more (the ring runs out by itself)', (
      tester,
    ) async {
      final repo = FakeRepository([request('live')])..endResult = const ApiException();
      final rig = await start(tester, repo: repo);
      rig.ui.emit(IncomingCallEventType.declined, 'r1');
      await tester.pump();
      await tester.pump();
      expect(repo.endCalls, 1);
      expect(tester.takeException(), isNull);
      await rig.close(tester);
    });
  });

  group('ending from the system controls', () {
    FakeRepository liveRepo() => FakeRepository([request('live')])
      ..joinResult = CallJoinResult(
        request: request('live'),
        credentials: credentials(audioOnly: true),
      )
      ..endResult = request('awaiting_feedback')
      ..heartbeats = [beat('live', connected: 5, remaining: 800)];

    testWidgets('hangs up the call that is on screen', (tester) async {
      final rig = await start(tester, repo: liveRepo());
      final sub = rig.container.listen(callSessionProvider('r1'), (_, _) {});
      await rig.run(tester, () => rig.container.read(callSessionProvider('r1').notifier).answerAsRequester());
      expect(sub.read().phase, CallPhase.live);

      rig.ui.emit(IncomingCallEventType.ended, 'r1');
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }
      expect(sub.read().phase, CallPhase.ended);
      expect(rig.repo.endCalls, 1);
      sub.close();
      await rig.close(tester);
    });

    testWidgets('does nothing (and invents no call) when no call is on screen', (
      tester,
    ) async {
      final rig = await start(tester, repo: liveRepo());
      rig.ui.emit(IncomingCallEventType.ended, 'r1');
      await tester.pump();
      expect(rig.repo.endCalls, 0);
      expect(rig.container.exists(callSessionProvider('r1')), isFalse);
      await rig.close(tester);
    });
  });

  group('pushes', () {
    testWidgets('"the driver hung up" takes the system call screen down', (
      tester,
    ) async {
      final rig = await start(tester);
      rig.ui.emit(IncomingCallEventType.shown, 'r1');
      rig.push.whileOpenController.add(const PushEvent(type: 'call_cancelled', requestId: 'r1'));
      await tester.pump();
      expect(rig.ui.log, contains('end:r1'));
      expect(rig.shown, isEmpty);
      await rig.close(tester);
    });

    testWidgets('also when it was tapped in the background', (tester) async {
      final rig = await start(tester);
      rig.push.tappedController.add(const PushEvent(type: 'call_cancelled', requestId: 'r2'));
      await tester.pump();
      expect(rig.ui.log, contains('end:r2'));
      await rig.close(tester);
    });

    testWidgets('other pushes leave the call screen alone', (tester) async {
      final rig = await start(tester);
      for (final type in ['call_incoming', 'call_request', 'call_payment']) {
        rig.push.whileOpenController.add(PushEvent(type: type, requestId: 'r1'));
      }
      rig.push.whileOpenController.add(const PushEvent(type: 'call_cancelled'));
      await tester.pump();
      expect(rig.ui.log.where((l) => l.startsWith('end:')), isEmpty);
      await rig.close(tester);
    });
  });

  testWidgets('once stopped it no longer reacts', (tester) async {
    final rig = await start(tester);
    final ui = rig.ui;
    await rig.close(tester);
    ui.emit(IncomingCallEventType.accepted, 'r1'); // nobody is listening any more
    expect(ui.log.where((l) => l.startsWith('end:')), isEmpty);
  });
}
