import 'dart:async';

import 'package:convoynew/core/storage/shared_preferences_provider.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/media/call_media_engine.dart';
import 'package:convoynew/features/call_request/presentation/call/call_coordinator.dart';
import 'package:convoynew/features/call_request/presentation/call/call_request_loader.dart';
import 'package:convoynew/features/call_request/presentation/call/call_routes.dart';
import 'package:convoynew/features/call_request/presentation/call/call_screen_registry.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_controller.dart';
import 'package:convoynew/features/call_request/presentation/call/feedback_screen.dart';
import 'package:convoynew/features/call_request/presentation/call/incoming_call_screen.dart';
import 'package:convoynew/features/call_request/presentation/call/live_call_screen.dart';
import 'package:convoynew/features/call_request/presentation/call/rejoin_screen.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

// The whole app's call machinery together, as in the app: the real coordinator,
// the real router entries and the real screens, with only the server, the media
// and the phone's own call screen faked. These cover what was reported from the
// first two-phone test: a "rejoin" prompt covering a call that was fine, a rejoin
// that did nothing, and "Done" having to be tapped twice.

GoRouter buildRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, _) => const Scaffold(body: Text('HOME'))),
    GoRoute(
      path: '${CallRoutes.prefix}/:id',
      builder: (c, s) => LiveCallScreen(
        requestId: s.pathParameters['id']!,
        entry: CallEntry.parse(s.uri.queryParameters['mode']),
        isProvider: s.uri.queryParameters['driver'] == '1',
      ),
      routes: [
        GoRoute(
          path: 'incoming',
          builder: (c, s) => CallRequestLoader(
            requestId: s.pathParameters['id']!,
            initial: s.extra as CallRequestEntity?,
            builder: (r) => IncomingCallScreen(request: r),
          ),
        ),
        GoRoute(
          path: 'rejoin',
          builder: (c, s) => CallRequestLoader(
            requestId: s.pathParameters['id']!,
            initial: s.extra as CallRequestEntity?,
            builder: (r) => RejoinScreen(request: r),
          ),
        ),
        GoRoute(
          path: 'feedback',
          builder: (c, s) => CallRequestLoader(
            requestId: s.pathParameters['id']!,
            initial: s.extra as CallRequestEntity?,
            builder: (r) => FeedbackScreen(request: r),
          ),
        ),
      ],
    ),
  ],
);

class App {
  final GoRouter router;
  final FakeRepository repo;
  final FakeMediaEngine engine;
  final FakeClock clock;
  final ProviderContainer container;

  App(this.router, this.repo, this.engine, this.clock, this.container);

  int count(Type type) => find.byType(type).evaluate().length;
  bool get rejoinShowing => count(RejoinScreen) > 0;

  Future<void> settle(WidgetTester tester, [int times = 10]) async {
    for (var i = 0; i < times; i++) {
      clock.advance(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// The phone coming back to the front (after a permission dialog, say).
  Future<void> resume(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester, 15);
  }
}

Future<App> launch(
  WidgetTester tester, {
  required FakeRepository repo,
  FakeMediaEngine? engine,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final clock = FakeClock();
  final media = engine ?? FakeMediaEngine();
  final router = buildRouter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...callOverrides(
          repo: repo,
          engine: media,
          clock: clock,
          callUi: FakeIncomingCallUi(),
          push: FakePushSource(),
          service: FakeCallService(),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => CallCoordinator(router: router, child: child!),
      ),
    ),
  );
  final app = App(
    router,
    repo,
    media,
    clock,
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))),
  );
  await app.settle(tester);
  return app;
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

CallJoinResult ringingFor(FakeClock clock) {
  final ends = clock.now.add(const Duration(seconds: 45));
  return CallJoinResult(
    request: request('ringing', role: 'provider', ringEndsAt: ends),
    credentials: credentials(ringEndsAt: ends),
  );
}

void main() {
  group('the driver', () {
    FakeRepository driverRepo() => FakeRepository([request('ringing', role: 'provider')])
      ..heartbeats = [beat('ringing')]
      ..incoming = const <CallRequestEntity>[]
      ..outgoing = const <CallRequestEntity>[]
      ..endResult = request('accepted', role: 'provider');

    testWidgets('starting a call, then the phone coming back from the permission dialogs, does NOT cover the call with "rejoin"', (tester) async {
      final repo = driverRepo();
      final app = await launch(tester, repo: repo);
      repo.startResult = ringingFor(app.clock);

      app.router.push(CallRoutes.call('r1', mode: 'start', driver: true));
      await app.settle(tester);
      expect(app.count(LiveCallScreen), 1);

      // the permission dialogs took the app to the background and back; the
      // server (rightly) says this driver has a call that is ringing
      repo.incoming = [request('ringing', role: 'provider', ringEndsAt: app.clock.now.add(const Duration(seconds: 40)))];
      await app.resume(tester);

      expect(app.rejoinShowing, isFalse, reason: 'a call that is fine must not be covered by a rejoin prompt');
      expect(app.count(LiveCallScreen), 1);
      expect(find.text('Calling Asha…'), findsOneWidget);
      expect(repo.startCalls, 1);
      await unmount(tester);
    });

    testWidgets('tapping Start twice quickly runs one call, one screen', (tester) async {
      final repo = driverRepo();
      final app = await launch(tester, repo: repo);
      repo.startResult = ringingFor(app.clock);

      app.router.push(CallRoutes.call('r1', mode: 'start', driver: true));
      app.router.push(CallRoutes.call('r1', mode: 'start', driver: true));
      await app.settle(tester, 15);

      expect(app.count(LiveCallScreen), 1, reason: 'one screen for one call');
      expect(repo.startCalls, 1);
      expect(find.text('Calling Asha…'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('hanging up before 30 seconds: ONE tap on Done takes you home', (tester) async {
      final repo = driverRepo()
        ..heartbeats = [beat('live', connected: 4, remaining: 800)]
        ..endResult = request('failed', role: 'provider');
      final app = await launch(tester, repo: repo);
      repo.startResult = ringingFor(app.clock);

      app.router.push(CallRoutes.call('r1', mode: 'start', driver: true));
      await app.settle(tester);
      await app.resume(tester); // the permission dialogs, again
      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await app.settle(tester);
      expect(find.text('Call ended'), findsOneWidget);
      expect(
        find.text('The call was too short to count (under 30 seconds). Nothing was charged.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget, reason: 'one tap, not two');
      expect(find.text('Call ended'), findsNothing);
      await unmount(tester);
    });
  });

  group('the requester', () {
    FakeRepository requesterRepo(FakeClock? c) => FakeRepository([request('live')])
      ..joinResult = CallJoinResult(request: request('live'), credentials: credentials(audioOnly: true))
      ..heartbeats = [beat('live', connected: 3, remaining: 880)]
      ..incoming = const <CallRequestEntity>[]
      ..outgoing = const <CallRequestEntity>[]
      ..endResult = request('failed');

    testWidgets('answering, then the phone coming back from the microphone dialog, does NOT cover the call with "rejoin"', (tester) async {
      final repo = requesterRepo(null);
      final app = await launch(tester, repo: repo);
      final ringing = request('ringing', ringEndsAt: app.clock.now.add(const Duration(seconds: 45)));
      repo.outgoing = [ringing]; // the driver rings
      await app.resume(tester);
      expect(find.text('Answer'), findsOneWidget);

      await tester.tap(find.text('Answer'));
      await app.settle(tester, 12);
      expect(app.count(LiveCallScreen), 1);
      expect(repo.joinCalls, 1);

      repo.outgoing = [request('live')]; // the server now says it is live
      await app.resume(tester);

      expect(app.rejoinShowing, isFalse);
      expect(app.count(LiveCallScreen), 1);
      expect(repo.heartbeatPeerPresent, isNotEmpty, reason: 'this phone keeps reporting in');
      await unmount(tester);
    });

    testWidgets('hanging up before 30 seconds: ONE tap on Done takes you home', (tester) async {
      final repo = requesterRepo(null);
      final app = await launch(tester, repo: repo);
      repo.outgoing = [request('ringing', ringEndsAt: app.clock.now.add(const Duration(seconds: 45)))];
      await app.resume(tester);
      await tester.tap(find.text('Answer'));
      await app.settle(tester, 12);
      repo.outgoing = [request('live')];
      await app.resume(tester);

      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await app.settle(tester);
      expect(find.text('Call ended'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('rejoining (the app really was closed during a call)', () {
    testWidgets('on launch the prompt appears, Rejoin gives ONE working call screen', (tester) async {
      final repo = FakeRepository([request('live')])
        ..outgoing = [request('live')]
        ..incoming = const <CallRequestEntity>[]
        ..joinResult = CallJoinResult(request: request('live'), credentials: credentials(audioOnly: true))
        ..heartbeats = [beat('live', connected: 12, remaining: 700)];
      final app = await launch(tester, repo: repo);
      // launched on Home with a live call on the server: the coordinator's first
      // look brings the prompt up
      expect(app.rejoinShowing, isTrue);

      await tester.tap(find.text('Rejoin'));
      await app.settle(tester, 15);

      expect(app.rejoinShowing, isFalse);
      expect(app.count(LiveCallScreen), 1);
      expect(repo.joinCalls, 1, reason: 'rejoining really rejoined');
      expect(app.engine.joinedWith, isNotNull);
      expect(find.text('Waiting for Vikram to join…'), findsOneWidget);

      app.engine.emit(const MediaPeerJoined(111));
      await tester.pump();
      expect(find.text('Waiting for Vikram to join…'), findsNothing, reason: 'it connects as soon as the other person is there');
      await unmount(tester);
    });

    testWidgets('a rejoin prompt that comes up over a call already on screen just goes back to it', (tester) async {
      final repo = FakeRepository([request('live')])
        ..outgoing = const <CallRequestEntity>[]
        ..incoming = const <CallRequestEntity>[]
        ..joinResult = CallJoinResult(request: request('live'), credentials: credentials(audioOnly: true))
        ..heartbeats = [beat('live', connected: 12, remaining: 700)];
      final app = await launch(tester, repo: repo);
      app.router.push(CallRoutes.call('r1', mode: 'rejoin', driver: false));
      await app.settle(tester, 12);
      expect(app.count(LiveCallScreen), 1);

      // a stray prompt (however it got there) for the same call
      app.router.push(CallRoutes.rejoin('r1'), extra: request('live'));
      await app.settle(tester);
      await tester.tap(find.text('Rejoin'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(app.rejoinShowing, isFalse);
      expect(app.count(LiveCallScreen), 1, reason: 'no second call screen stacked on the first');
      // Home + the call, nothing else: the prompt closed instead of opening a second call screen
      expect(app.router.routerDelegate.currentConfiguration.matches.length, 2);
      expect(repo.joinCalls, 1);
      await unmount(tester);
    });
  });

  group('while the media channel is slow', () {
    testWidgets('this phone still reports in to the server (it does not look absent)', (tester) async {
      final repo = FakeRepository([request('live')])
        ..joinResult = CallJoinResult(request: request('live'), credentials: credentials(audioOnly: true))
        ..heartbeats = [beat('live', connected: 0, remaining: 880)]
        ..incoming = const <CallRequestEntity>[]
        ..outgoing = const <CallRequestEntity>[];
      final engine = FakeMediaEngine()..joinGate = Completer<void>();
      final app = await launch(tester, repo: repo, engine: engine);
      app.router.push(CallRoutes.call('r1', mode: 'answer', driver: false));
      await app.settle(tester, 40); // ~8 s, media still not up

      expect(repo.heartbeatPeerPresent, isNotEmpty, reason: 'the heartbeat does not wait for the media');
      expect(repo.heartbeatPeerPresent.every((p) => p == false), isTrue);
      await unmount(tester);
    });

    testWidgets('and if it never comes up, it says so instead of waiting forever', (tester) async {
      final repo = FakeRepository([request('live')])
        ..joinResult = CallJoinResult(request: request('live'), credentials: credentials(audioOnly: true))
        ..heartbeats = [beat('live', connected: 0, remaining: 880)]
        ..incoming = const <CallRequestEntity>[]
        ..outgoing = const <CallRequestEntity>[];
      final engine = FakeMediaEngine()..joinGate = Completer<void>();
      final app = await launch(tester, repo: repo, engine: engine);
      app.router.push(CallRoutes.call('r1', mode: 'answer', driver: false));
      await app.settle(tester, 12);
      expect(find.textContaining('Waiting for'), findsOneWidget);

      app.clock.advance(callEngineJoinTimeout);
      await tester.pump(callEngineJoinTimeout + const Duration(seconds: 1));
      await app.settle(tester, 5);

      expect(find.text('The call could not connect (the audio/video did not start in time).'), findsOneWidget);
      expect(engine.disposed, isTrue);
      await unmount(tester);
    });
  });

  group('a prompt held back by an open call comes up when it closes', () {
    testWidgets('a ring that arrived during a call rings once the call screen is gone', (tester) async {
      final repo = FakeRepository([request('live')])
        ..outgoing = const <CallRequestEntity>[]
        ..incoming = const <CallRequestEntity>[];
      final app = await launch(tester, repo: repo);
      final registry = app.container.read(callScreenRegistryProvider);
      registry.enter('other', live: true); // a call screen is open

      repo.outgoing = [request('ringing', id: 'r2', ringEndsAt: app.clock.now.add(const Duration(seconds: 40)))];
      await app.resume(tester);
      expect(find.byType(IncomingCallScreen), findsNothing, reason: 'never over another call');

      registry.leave('other', live: true); // the call screen closed
      await app.settle(tester, 5);
      expect(find.byType(IncomingCallScreen), findsOneWidget);
      await unmount(tester);
    });
  });
}
