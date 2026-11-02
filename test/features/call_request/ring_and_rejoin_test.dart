import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/incoming_call/incoming_call_controller.dart';
import 'package:convoynew/features/call_request/presentation/call/call_request_loader.dart';
import 'package:convoynew/features/call_request/presentation/call/feedback_screen.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_controller.dart';
import 'package:convoynew/features/call_request/presentation/call/incoming_call_screen.dart';
import 'package:convoynew/features/call_request/presentation/call/rejoin_screen.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump();
  }
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

/// A router with [screen] as the first page, a stand-in for the call route
/// (showing how it was opened) and for Home.
Future<FakeClock> pump(
  WidgetTester tester, {
  required FakeRepository repo,
  required Widget screen,
  FakeClock? clock,
  FakeIncomingCallUi? callUi,
  bool callScreenKeepsSession = false,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = clock ?? FakeClock();
  final router = GoRouter(
    initialLocation: '/screen',
    routes: [
      GoRoute(path: '/screen', builder: (_, _) => screen),
      GoRoute(
        path: '/video-call/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final label =
              'CALL $id ${state.uri.queryParameters['mode']} '
              'driver=${state.uri.queryParameters['driver']}';
          // The real call screen watches the call's session, which keeps it alive
          // across the move from the ring screen. Behave like it when asked.
          return callScreenKeepsSession
              ? Consumer(
                  builder: (context, ref, _) {
                    ref.watch(callSessionProvider(id));
                    return Scaffold(body: Text(label));
                  },
                )
              : Scaffold(body: Text(label));
        },
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...callOverrides(
          repo: repo,
          engine: FakeMediaEngine(),
          clock: c,
          callUi: callUi,
        ),
        ...repoOverrides(repo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await settle(tester);
  return c;
}

CallRequestEntity ringing(FakeClock clock, {int seconds = 45}) => request(
  'ringing',
  ringEndsAt: clock.now.add(Duration(seconds: seconds)),
);

void main() {
  group('the ring screen', () {
    testWidgets('shows who is calling, about what, and Answer / Decline', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );

      expect(find.text('Vikram is calling you'), findsOneWidget);
      expect(find.text('Route status'), findsOneWidget);
      expect(find.text('₹150.00 offered · 15 min'), findsOneWidget);
      expect(find.text('Ringing · 45s'), findsOneWidget);
      expect(find.text('Answer'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(
        find.text('Declining cancels your request and releases your money.'),
        findsOneWidget,
      );
      expect(
        find.text(
          "You'll hear Vikram and see their camera. Only your microphone is on.",
        ),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('counts the ring down', (tester) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      clock.advance(const Duration(seconds: 10));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Ringing · 35s'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('Answer opens the call as the requester answering', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      await tester.tap(find.text('Answer'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('CALL r1 answer driver=0'), findsOneWidget);
      expect(repo.endCalls, 0);
      await unmount(tester);
    });

    testWidgets('Answering here stops a system call notification for the same ring', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final ui = FakeIncomingCallUi();
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        callUi: ui,
        callScreenKeepsSession: true,
        screen: IncomingCallScreen(request: r),
      );
      await tester.tap(find.text('Answer'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('CALL r1 answer driver=0'), findsOneWidget);
      expect(ui.log, contains('end:r1'));
      await unmount(tester);
    });

    testWidgets('Declining here does too', (tester) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final ui = FakeIncomingCallUi();
      final repo = FakeRepository([r])
        ..outgoing = [r]
        ..endResult = request('cancelled');
      await pump(
        tester,
        repo: repo,
        clock: clock,
        callUi: ui,
        screen: IncomingCallScreen(request: r),
      );
      await tester.tap(find.text('Decline'));
      await settle(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(ui.log, contains('end:r1'));
      await unmount(tester);
    });

    testWidgets('a decline that never reached the server leaves the system screen alone', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final ui = FakeIncomingCallUi();
      final repo = FakeRepository([r])
        ..outgoing = [r]
        ..endResult = const ApiException();
      await pump(
        tester,
        repo: repo,
        clock: clock,
        callUi: ui,
        screen: IncomingCallScreen(request: r),
      );
      await tester.tap(find.text('Decline'));
      await settle(tester);
      expect(ui.log.where((l) => l.startsWith('end:')), isEmpty);
      await unmount(tester);
    });

    testWidgets('Decline tells the server and leaves', (tester) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])
        ..outgoing = [r]
        ..endResult = request('cancelled');
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      await tester.tap(find.text('Decline'));
      await settle(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(repo.endCalls, 1);
      expect(repo.joinCalls, 0);
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('closes itself when the phone\'s own call screen takes over this ring', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      expect(find.text('Answer'), findsOneWidget);

      ProviderScope.containerOf(tester.element(find.byType(IncomingCallScreen)))
          .read(callKitShownProvider.notifier)
          .state = {'r1'};
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget);
      expect(repo.endCalls, 0, reason: 'nothing was declined');
      await unmount(tester);
    });

    testWidgets('stays when the system call screen is for another request', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      ProviderScope.containerOf(tester.element(find.byType(IncomingCallScreen)))
          .read(callKitShownProvider.notifier)
          .state = {'someone-else'};
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Answer'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a decline that cannot reach the server says so and can be tried again', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])
        ..outgoing = [r]
        ..endResult = const ApiException();
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );

      await tester.tap(find.text('Decline'));
      await settle(tester);
      expect(
        find.text("Couldn't reach the server. Check your connection and try again."),
        findsOneWidget,
      );
      expect(find.text('Answer'), findsOneWidget, reason: 'still ringing');
      expect(find.text('HOME'), findsNothing);

      repo.endResult = request('cancelled');
      await tester.tap(find.text('Decline'));
      await settle(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(repo.endCalls, 2);
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('once the ring is over it says the call was missed', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock, seconds: 5);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      clock.advance(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text(
          'You missed the call. Vikram can try again, or you can cancel your request.',
        ),
        findsOneWidget,
      );
      expect(find.text('Answer'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('answered on my other phone: says so instead of "missed"', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );

      // The other phone answered: the call is live there.
      repo.outgoing = [request('live', onAnotherDevice: true)];
      clock.advance(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      expect(find.text('You answered this call on your other device.'), findsOneWidget);
      expect(find.text('Answer'), findsNothing);
      expect(find.textContaining('You missed the call'), findsNothing);
      await unmount(tester);
    });

    testWidgets('if the driver hangs up first, the buttons go away', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      expect(find.text('Answer'), findsOneWidget);

      // The driver cancelled the ring: the request is back to "accepted".
      repo.outgoing = [request('accepted')];
      clock.advance(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('Answer'), findsNothing);
      expect(find.textContaining('You missed the call'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a request that is no longer open also ends the ring', (
      tester,
    ) async {
      final clock = FakeClock();
      final r = ringing(clock);
      final repo = FakeRepository([r])..outgoing = [r];
      await pump(
        tester,
        repo: repo,
        clock: clock,
        screen: IncomingCallScreen(request: r),
      );
      repo.outgoing = const <CallRequestEntity>[];
      await tester.pump(outgoingPollForTest);
      await tester.pump();
      expect(find.text('Answer'), findsNothing);
      await unmount(tester);
    });
  });

  group('"you are still in a call"', () {
    testWidgets('offers Rejoin and End call', (tester) async {
      final repo = FakeRepository([request('live')]);
      await pump(
        tester,
        repo: repo,
        screen: RejoinScreen(request: request('live')),
      );
      expect(find.text("You're still in a call"), findsOneWidget);
      expect(
        find.text('Your call with Vikram is still going. Rejoin to carry on.'),
        findsOneWidget,
      );
      expect(find.text('Rejoin'), findsOneWidget);
      expect(find.text('End call'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('Rejoin reopens the call (a requester without a camera)', (
      tester,
    ) async {
      await pump(
        tester,
        repo: FakeRepository([request('live')]),
        screen: RejoinScreen(request: request('live')),
      );
      await tester.tap(find.text('Rejoin'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('CALL r1 rejoin driver=0'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a driver rejoining is marked as the driver (the camera is needed)', (
      tester,
    ) async {
      final r = request('live', role: 'provider');
      await pump(
        tester,
        repo: FakeRepository([r]),
        screen: RejoinScreen(request: r),
      );
      await tester.tap(find.text('Rejoin'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('CALL r1 rejoin driver=1'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('End call tells the server and leaves, even offline', (
      tester,
    ) async {
      final repo = FakeRepository([request('live')])
        ..endResult = request('awaiting_feedback');
      await pump(
        tester,
        repo: repo,
        screen: RejoinScreen(request: request('live')),
      );
      await tester.tap(find.text('End call'));
      await settle(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(repo.endCalls, 1);
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('the satisfaction screen', () {
    testWidgets('asks the question for the request it is given', (tester) async {
      final r = request('awaiting_feedback');
      await pump(
        tester,
        repo: FakeRepository([r])..feedbackResult = request('completed', settledAmount: '150.00'),
        screen: FeedbackScreen(request: r),
      );
      expect(find.text('Were you satisfied with the call?'), findsOneWidget);
      expect(find.text('Your answer decides what Vikram is paid.'), findsOneWidget);
      expect(find.text('Yes, pay ₹150.00'), findsOneWidget);
      expect(find.text('No, pay only ₹37.50'), findsOneWidget);
      expect(
        find.text("If you don't answer within 24 hours, only ₹37.50 is paid."),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('the loader fetches the request when the route has none', (
      tester,
    ) async {
      final repo = FakeRepository([request('awaiting_feedback')]);
      await pump(
        tester,
        repo: repo,
        screen: CallRequestLoader(
          requestId: 'r1',
          initial: null,
          builder: (r) => FeedbackScreen(request: r),
        ),
      );
      expect(repo.getCalls, 1);
      expect(find.text('Were you satisfied with the call?'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('and says so when it cannot be loaded', (tester) async {
      final repo = FakeRepository([StateError('x')]);
      await pump(
        tester,
        repo: repo,
        screen: CallRequestLoader(
          requestId: 'r1',
          initial: null,
          builder: (r) => FeedbackScreen(request: r),
        ),
      );
      expect(find.text('Were you satisfied with the call?'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await unmount(tester);
    });
  });
}

/// Longer than any poll of the requester's open requests.
const outgoingPollForTest = Duration(seconds: 16);
