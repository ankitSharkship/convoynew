import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/incoming_call/incoming_call_controller.dart';
import 'package:convoynew/features/call_request/presentation/call/call_coordinator.dart';
import 'package:convoynew/features/call_request/presentation/call/call_prompts.dart';
import 'package:convoynew/features/call_request/presentation/call/call_screen_registry.dart';
import 'package:convoynew/features/call_request/presentation/state/call_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convoynew/core/storage/shared_preferences_provider.dart';
import 'package:go_router/go_router.dart';

import 'support.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump();
  }
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

class Rig {
  final GoRouter router;
  final FakeRepository repo;
  final FakeClock clock;
  final ProviderContainer container;

  Rig(this.router, this.repo, this.clock, this.container);
}

/// The app's routes reduced to stand-ins that say which screen came up. The
/// app starts on the splash screen, as the real one does.
Future<Rig> pumpApp(
  WidgetTester tester, {
  required FakeRepository repo,
  String start = '/splash',
  Set<String> alreadyHandled = const {},
  FakeIncomingCallUi? callUi,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final clock = FakeClock();
  final router = GoRouter(
    initialLocation: start,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const Scaffold(body: Text('SPLASH')),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: '/video-call/:id',
        builder: (_, state) =>
            Scaffold(
              body: Text(
                'CALL ${state.pathParameters['id']} ${state.uri.queryParameters['mode']} driver=${state.uri.queryParameters['driver']}',
              ),
            ),
        routes: [
          GoRoute(
            path: 'incoming',
            builder: (_, state) => Scaffold(
              body: Text('RING ${(state.extra as CallRequestEntity).id}'),
            ),
          ),
          GoRoute(
            path: 'rejoin',
            builder: (_, state) => Scaffold(
              body: Text('REJOIN ${(state.extra as CallRequestEntity).id}'),
            ),
          ),
          GoRoute(
            path: 'feedback',
            builder: (_, state) => Scaffold(
              body: Text('FEEDBACK ${(state.extra as CallRequestEntity).id}'),
            ),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...callOverrides(
          repo: repo,
          engine: FakeMediaEngine(),
          clock: clock,
          callUi: callUi ?? FakeIncomingCallUi(),
          push: FakePushSource(),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
        handledCallPromptsProvider.overrideWithValue({...alreadyHandled}),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) =>
            CallCoordinator(router: router, child: child!),
      ),
    ),
  );
  await settle(tester);
  return Rig(
    router,
    repo,
    clock,
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))),
  );
}

CallRequestEntity ringing(FakeClock clock, {String id = 'r1'}) => request(
  'ringing',
  id: id,
  ringEndsAt: clock.now.add(const Duration(seconds: 40)),
);

void main() {
  testWidgets('does not ask the server anything before the person is past login', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')]);
    await pumpApp(tester, repo: repo);
    expect(repo.outgoingCalls, 0);
    expect(repo.incomingCalls, 0);
    expect(find.text('SPLASH'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('looks once when the person reaches Home, and a quiet account shows nothing', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')])
      ..outgoing = const <CallRequestEntity>[];
    final rig = await pumpApp(tester, repo: repo);
    rig.router.go('/home');
    await settle(tester);

    expect(repo.outgoingCalls, 1);
    expect(repo.incomingCalls, 1);
    expect(find.text('HOME'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a ring that is on when the app opens brings up the ring screen', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')]);
    final rig = await pumpApp(tester, repo: repo);
    repo.outgoing = [ringing(rig.clock)];
    rig.router.go('/home');
    await settle(tester);

    expect(find.text('RING r1'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the same ring is not brought up again after it was dealt with', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')]);
    final rig = await pumpApp(tester, repo: repo);
    repo.outgoing = [ringing(rig.clock)];
    rig.router.go('/home');
    await settle(tester);
    expect(find.text('RING r1'), findsOneWidget);

    rig.router.go('/home'); // the person went back, e.g. after a decline
    await settle(tester);
    expect(find.text('RING r1'), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a driver whose call is still on is offered to rejoin it', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')])
      ..outgoing = const <CallRequestEntity>[]
      ..incoming = [request('live', role: 'provider')];
    final rig = await pumpApp(tester, repo: repo);
    rig.router.go('/home');
    await settle(tester);

    expect(find.text('REJOIN r1'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the satisfaction question still owed is asked for', (tester) async {
    final repo = FakeRepository([request('live')])
      ..outgoing = [
        request(
          'awaiting_feedback',
          feedbackDeadline: DateTime.now().add(const Duration(hours: 5)),
        ),
      ];
    final rig = await pumpApp(tester, repo: repo);
    rig.clock.now = DateTime.now().toUtc();
    rig.router.go('/home');
    await settle(tester);

    expect(find.text('FEEDBACK r1'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a question the person put off ("Decide later") is not asked again at once', (
    tester,
  ) async {
    final deadline = DateTime.now().add(const Duration(hours: 5));
    final repo = FakeRepository([request('live')])
      ..outgoing = [request('awaiting_feedback', feedbackDeadline: deadline)];
    final rig = await pumpApp(
      tester,
      repo: repo,
      alreadyHandled: {CallPromptKeys.feedback('r1')},
    );
    rig.clock.now = DateTime.now().toUtc();
    rig.router.go('/home');
    await settle(tester);

    expect(find.text('FEEDBACK r1'), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('never opens one call screen over another', (tester) async {
    final repo = FakeRepository([request('live')])
      ..outgoing = const <CallRequestEntity>[];
    final rig = await pumpApp(tester, repo: repo);
    rig.router.go('/video-call/other'); // already in a call
    rig.container.read(callScreenRegistryProvider).enter('other', live: true);
    await settle(tester);
    repo.outgoing = [ringing(rig.clock, id: 'r2')];
    // Something new arrives (a push, say):
    rig.router.go('/video-call/other?mode=rejoin');
    await settle(tester);

    expect(find.text('RING r2'), findsNothing);
    await unmount(tester);
  });

  testWidgets('coming back to the app looks again', (tester) async {
    final repo = FakeRepository([request('live')])
      ..outgoing = const <CallRequestEntity>[];
    final rig = await pumpApp(tester, repo: repo);
    rig.router.go('/home');
    await settle(tester);
    expect(repo.outgoingCalls, 1);

    repo.outgoing = [ringing(rig.clock)];
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);

    expect(repo.outgoingCalls, 2);
    expect(find.text('RING r1'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a failing server is just "nothing to show"', (tester) async {
    final repo = FakeRepository([request('live')])
      ..outgoing = StateError('down')
      ..incoming = StateError('down');
    final rig = await pumpApp(tester, repo: repo);
    rig.router.go('/home');
    await settle(tester);
    expect(find.text('HOME'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('asks for the call-screen permissions once the person is past login, not before', (
    tester,
  ) async {
    final ui = FakeIncomingCallUi();
    final repo = FakeRepository([request('live')])
      ..outgoing = const <CallRequestEntity>[];
    final rig = await pumpApp(tester, repo: repo, callUi: ui);
    expect(ui.log, isNot(contains('permissions')), reason: 'still on the splash screen');

    rig.router.go('/home');
    await settle(tester);
    expect(ui.log.where((l) => l == 'permissions'), hasLength(1));
    await unmount(tester);
  });

  group('a call answered on the phone\'s own call screen', () {
    testWidgets('opens straight into the call as the requester answering', (
      tester,
    ) async {
      final repo = FakeRepository([request('live')])
        ..outgoing = const <CallRequestEntity>[];
      final rig = await pumpApp(tester, repo: repo);
      rig.router.go('/home');
      await settle(tester);

      rig.container.read(pendingAnsweredCallProvider.notifier).state = 'r1';
      await settle(tester);

      expect(find.text('CALL r1 answer driver=0'), findsOneWidget);
      expect(rig.container.read(pendingAnsweredCallProvider), isNull);
      await unmount(tester);
    });

    testWidgets('answered while the app was still starting: waits, then opens', (
      tester,
    ) async {
      final repo = FakeRepository([request('live')])
        ..outgoing = const <CallRequestEntity>[];
      final rig = await pumpApp(tester, repo: repo); // on the splash screen
      rig.container.read(pendingAnsweredCallProvider.notifier).state = 'r1';
      await settle(tester);
      expect(find.text('CALL r1 answer driver=0'), findsNothing);
      expect(rig.container.read(pendingAnsweredCallProvider), 'r1', reason: 'kept for later');

      rig.router.go('/home'); // login finished
      await settle(tester);
      expect(find.text('CALL r1 answer driver=0'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('is not opened a second time when that call is already on screen', (
      tester,
    ) async {
      final repo = FakeRepository([request('live')])
        ..outgoing = const <CallRequestEntity>[];
      final rig = await pumpApp(tester, repo: repo);
      rig.router.go('/home');
      await settle(tester);
      rig.router.go('/video-call/r1?mode=answer&driver=0');
      await settle(tester);
      // (the real call screen registers itself while it is open)
      rig.container.read(callScreenRegistryProvider).enter('r1', live: true);

      rig.container.read(pendingAnsweredCallProvider.notifier).state = 'r1';
      await settle(tester);
      expect(find.text('CALL r1 answer driver=0'), findsOneWidget); // still one screen
      expect(rig.container.read(pendingAnsweredCallProvider), isNull);
      await unmount(tester);
    });
  });

  group('the phone\'s own call screen and the app\'s ring screen', () {
    testWidgets('only one rings: the app\'s screen stays away while the system one is up', (
      tester,
    ) async {
      final repo = FakeRepository([request('live')]);
      final rig = await pumpApp(tester, repo: repo);
      repo.outgoing = [ringing(rig.clock)];
      rig.container.read(callKitShownProvider.notifier).state = {'r1'};
      rig.router.go('/home');
      await settle(tester);

      expect(find.text('RING r1'), findsNothing);
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a different request still rings in the app', (tester) async {
      final repo = FakeRepository([request('live')]);
      final rig = await pumpApp(tester, repo: repo);
      repo.outgoing = [ringing(rig.clock, id: 'r2')];
      rig.container.read(callKitShownProvider.notifier).state = {'r1'};
      rig.router.go('/home');
      await settle(tester);
      expect(find.text('RING r2'), findsOneWidget);
      await unmount(tester);
    });
  });
}
