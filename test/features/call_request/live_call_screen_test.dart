import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:convoynew/features/call_request/media/call_media_engine.dart';
import 'package:convoynew/features/call_request/media/call_permissions.dart';
import 'package:convoynew/features/call_request/presentation/call/call_prompts.dart';
import 'package:convoynew/features/call_request/presentation/call/call_session_controller.dart';
import 'package:convoynew/features/call_request/presentation/state/call_providers.dart';
import 'package:convoynew/features/call_request/presentation/call/live_call_screen.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support.dart';

class Rig {
  final FakeRepository repo;
  final FakeMediaEngine engine;
  final FakePermissions permissions;
  final FakeClock clock;

  Rig(this.repo, this.engine, this.permissions, this.clock);

  /// Moves the fake timers and the clock the screen reads together.
  Future<void> elapse(WidgetTester tester, Duration d) async {
    clock.advance(d);
    await tester.pump(d);
    await tester.pump();
  }
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump();
  }
}

Future<Rig> pumpLive(
  WidgetTester tester, {
  required FakeRepository repo,
  FakeMediaEngine? engine,
  FakePermissions? permissions,
  CallEntry entry = CallEntry.start,
  bool isProvider = true,
  FakeCallService? service,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final rig = Rig(
    repo,
    engine ?? FakeMediaEngine(),
    permissions ?? FakePermissions(),
    FakeClock(),
  );
  final router = GoRouter(
    initialLocation: '/call',
    routes: [
      GoRoute(
        path: '/call',
        builder: (_, _) => LiveCallScreen(
          requestId: 'r1',
          entry: entry,
          isProvider: isProvider,
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: callOverrides(
        repo: repo,
        engine: rig.engine,
        permissions: rig.permissions,
        clock: rig.clock,
        service: service,
      ),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await settle(tester);
  return rig;
}

/// Takes the screen down so the controller's timers are cancelled.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

FakeRepository driverRepo({List<Object>? heartbeats}) {
  final ringEnds = FakeClock().now.add(const Duration(seconds: 45));
  return FakeRepository([request('ringing')])
    ..startResult = CallJoinResult(
      request: request('ringing', role: 'provider', ringEndsAt: ringEnds),
      credentials: credentials(ringEndsAt: ringEnds),
    )
    ..endResult = request(
      'awaiting_feedback',
      role: 'provider',
      connectedSeconds: 125,
    )
    ..heartbeats = heartbeats ?? [beat('ringing')];
}

FakeRepository requesterRepo({List<Object>? heartbeats}) =>
    FakeRepository([request('live')])
      ..joinResult = CallJoinResult(
        request: request('live'),
        credentials: credentials(audioOnly: true),
      )
      ..endResult = request('awaiting_feedback', connectedSeconds: 125)
      ..heartbeats = heartbeats ?? [beat('live', connected: 5, remaining: 880)];

void main() {
  group('the driver', () {
    testWidgets('sees "Calling Asha" with only a Cancel button while it rings', (
      tester,
    ) async {
      final rig = await pumpLive(tester, repo: driverRepo());
      expect(find.text('Calling Asha…'), findsOneWidget);
      expect(find.text('Their phone is ringing'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Mute'), findsNothing);
      expect(rig.repo.startCalls, 1);
      await unmount(tester);
    });

    testWidgets('sees their own camera once the media has joined', (tester) async {
      final rig = await pumpLive(tester, repo: driverRepo());
      expect(find.byKey(const Key('local-video')), findsNothing);
      rig.engine.emit(const MediaJoined());
      await tester.pump();
      expect(find.byKey(const Key('local-video')), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('when the requester answers: name, time left and "counts after"', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(
          heartbeats: [beat('ringing'), beat('live', connected: 4, remaining: 890)],
        ),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await rig.elapse(tester, callRingPollInterval);

      expect(find.text('Asha'), findsOneWidget);
      expect(find.text('14:50 left'), findsOneWidget);
      expect(find.text('Counts as a call after 30s together'), findsOneWidget);
      expect(find.text('Mute'), findsOneWidget);
      expect(find.text('Camera off'), findsOneWidget);
      expect(find.text('Flip'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('End'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('the time left counts down between heartbeats', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 4, remaining: 600)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      expect(find.text('10:00 left'), findsOneWidget);
      await rig.elapse(tester, const Duration(seconds: 3));
      expect(find.text('09:57 left'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('shows "Counts as a call" once 30 s have really connected', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 41, remaining: 800)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      expect(find.text('Counts as a call'), findsOneWidget);
      expect(find.textContaining('Counts as a call after'), findsNothing);
      await unmount(tester);
    });

    testWidgets('says so when the requester drops out, and when they were never there', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 12, remaining: 800)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      expect(find.text('Waiting for Asha to join…'), findsOneWidget);

      rig.engine.emit(const MediaPeerJoined(222));
      await tester.pump();
      expect(find.text('Waiting for Asha to join…'), findsNothing);

      rig.engine.emit(const MediaPeerLeft(222));
      await tester.pump();
      expect(
        find.text('Asha lost connection. Waiting for them to come back…'),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('mute and camera buttons work and relabel', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 4, remaining: 800)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));

      await tester.tap(find.text('Mute'));
      await tester.pump();
      expect(find.text('Unmute'), findsOneWidget);
      expect(rig.engine.log, contains('mic:true'));

      await tester.tap(find.text('Camera off'));
      await tester.pump();
      expect(find.text('Camera on'), findsOneWidget);
      expect(rig.engine.log, contains('camera_off:true'));

      await tester.tap(find.text('Flip'));
      await tester.pump();
      expect(rig.engine.log, contains('switch'));
      await unmount(tester);
    });

    testWidgets('Cancel while it rings needs no question and says nobody answered', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo()..endResult = request('accepted', role: 'provider'),
      );
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      expect(find.text('Call ended'), findsOneWidget);
      expect(
        find.text('Asha didn\'t pick up. You can try again until the request expires.'),
        findsOneWidget,
      );
      expect(rig.repo.endCalls, 1);
      await unmount(tester);
    });

    testWidgets('End asks first; Keep going leaves the call alone', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 4, remaining: 800)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));

      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('End the call?'), findsOneWidget);
      expect(
        find.text('This call hasn\'t counted yet. If you end it now, nothing is charged.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Keep going'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(rig.repo.endCalls, 0);
      expect(find.text('Mute'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('ending a counted call explains the money, then shows what the driver earns', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 90, remaining: 700)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));

      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(
        find.text('This call has counted. Asha will be asked how it went.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await settle(tester);

      expect(find.text('Call ended'), findsOneWidget);
      expect(
        find.textContaining('You were on the call for 2 min 5 s.'),
        findsOneWidget,
      );
      expect(find.textContaining('₹37.50 for sure'), findsOneWidget);
      expect(find.textContaining('₹150.00 if they are'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Were you satisfied with the call?'), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a call too short to count says nothing was charged', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(
          heartbeats: [
            beat('live', connected: 4, remaining: 800),
            beat('failed', connected: 8, remaining: 0),
          ],
        )..script.insert(0, request('failed', role: 'provider')),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await rig.elapse(tester, callHeartbeatInterval);

      expect(
        find.text('The call was too short to count (under 30 seconds). Nothing was charged.'),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('the requester declining is said plainly', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('ringing'), beat('cancelled')])
          ..script.insert(0, request('cancelled', role: 'provider')),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await rig.elapse(tester, callRingPollInterval);

      expect(find.text('Asha declined the call. The request is closed.'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a blocked microphone explains and offers the settings', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(),
        permissions: FakePermissions()
          ..result = const CallPermissionResult(
            microphone: PermissionOutcome.permanentlyDenied,
            camera: PermissionOutcome.granted,
          ),
      );
      expect(find.text('Allow the microphone to take part in the call.'), findsOneWidget);
      expect(rig.repo.startCalls, 0);

      await tester.tap(find.text('Open settings'));
      await tester.pump();
      expect(rig.permissions.settingsOpened, 1);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a denied camera (not blocked) has no settings button', (tester) async {
      await pumpLive(
        tester,
        repo: driverRepo(),
        permissions: FakePermissions()
          ..result = const CallPermissionResult(
            microphone: PermissionOutcome.granted,
            camera: PermissionOutcome.denied,
          ),
      );
      expect(find.text('Allow the camera so the other person can see you.'), findsOneWidget);
      expect(find.text('Open settings'), findsNothing);
      await unmount(tester);
    });

    testWidgets('the server\'s reason is shown when the call can\'t start', (tester) async {
      await pumpLive(
        tester,
        repo: driverRepo()
          ..startResult = const CallRequestException(
            code: 'REQUEST_EXPIRED',
            message: 'This request has expired',
            statusCode: 410,
          ),
      );
      expect(find.text('This request has expired'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('being offline when starting says so', (tester) async {
      await pumpLive(tester, repo: driverRepo()..startResult = const ApiException());
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('losing the connection shows it, with a way to reconnect', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 4, remaining: 800)]),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      rig.engine.emit(const MediaConnectionLost());
      await tester.pump();
      expect(find.text('Your connection dropped. Reconnecting…'), findsOneWidget);
      expect(find.text('Reconnect'), findsOneWidget);
      rig.engine.emit(const MediaConnectionRestored());
      await tester.pump();
      expect(find.text('Reconnect'), findsNothing);
      await unmount(tester);
    });

    testWidgets('an unreachable server is flagged without ending the call', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: driverRepo(
          heartbeats: [const ApiException(), const ApiException(), const ApiException()],
        ),
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await rig.elapse(tester, callRingPollInterval);
      expect(
        find.text('Can\'t reach the server. The call goes on, but its time may not be counted.'),
        findsOneWidget,
      );
      expect(find.text('Calling Asha…'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('the requester', () {
    testWidgets('sees the driver\'s camera, hears them, sends only a microphone', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(),
        entry: CallEntry.answer,
        isProvider: false,
      );
      rig.engine.emit(const MediaJoined());
      rig.engine.emit(const MediaPeerJoined(111));
      rig.engine.emit(const MediaPeerVideo(111, showing: true));
      await tester.pump();

      expect(find.byKey(const Key('remote-video-111')), findsOneWidget);
      expect(find.byKey(const Key('local-video')), findsNothing);
      expect(rig.engine.joinedWith?.audioOnly, isTrue);
      expect(rig.permissions.asked, [false]);
      expect(find.text('Only your microphone is on. Vikram can\'t see you.'), findsOneWidget);
      expect(find.text('Camera off'), findsNothing);
      expect(find.text('Flip'), findsNothing);
      expect(find.text('Speaker'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('without the driver\'s video it shows who they are, not a blank screen', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(),
        entry: CallEntry.answer,
        isProvider: false,
      );
      rig.engine.emit(const MediaJoined());
      rig.engine.emit(const MediaPeerJoined(111));
      await tester.pump();
      expect(find.byKey(const Key('remote-video-111')), findsNothing);
      expect(find.text('Vikram'), findsOneWidget);
      expect(find.text('V'), findsOneWidget); // avatar initial
      await unmount(tester);
    });

    testWidgets('after a counted call they are asked if they were satisfied; yes pays in full', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo()
          ..feedbackResult = request('completed', settledAmount: '150.00'),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await settle(tester);

      expect(find.text('Thanks for your call with Vikram.'), findsOneWidget);
      expect(find.text('Were you satisfied with the call?'), findsOneWidget);
      expect(find.text('Yes, pay ₹150.00'), findsOneWidget);
      expect(find.text('No, pay only ₹37.50'), findsOneWidget);
      expect(find.text('Decide later'), findsOneWidget);

      await tester.tap(find.text('Yes, pay ₹150.00'));
      await settle(tester);
      expect(rig.repo.feedbackAnswers, [true]);
      expect(find.text('Thanks! You paid ₹150.00.'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('"No" pays only the call amount', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo()
          ..feedbackResult = request('completed', settledAmount: '37.50'),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await settle(tester);

      await tester.tap(find.text('No, pay only ₹37.50'));
      await settle(tester);
      expect(rig.repo.feedbackAnswers, [false]);
      expect(find.text('Thanks! You paid ₹37.50.'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('"Decide later" leaves the call screen without answering', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await settle(tester);

      await tester.tap(find.text('Decide later'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('HOME'), findsOneWidget);
      expect(rig.repo.feedbackAnswers, isEmpty);
      // ... and the question is marked as dealt with, so the app does not put
      // the same one straight back on screen.
      expect(
        ProviderScope.containerOf(tester.element(find.text('HOME')))
            .read(handledCallPromptsProvider),
        contains(CallPromptKeys.feedback('r1')),
      );
      await unmount(tester);
    });

    testWidgets('a failing answer shows why and keeps the question', (tester) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo()..feedbackResult = const ApiException(),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await settle(tester);

      await tester.tap(find.text('Yes, pay ₹150.00'));
      await settle(tester);
      expect(find.text('Were you satisfied with the call?'), findsOneWidget);
      expect(find.text('Yes, pay ₹150.00'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('answering too late shows the server\'s reason', (tester) async {
      await pumpLive(
        tester,
        repo: requesterRepo()
          ..joinResult = const CallRequestException(
            code: 'RING_OVER',
            message: 'This call wasn\'t answered in time',
            statusCode: 409,
          ),
        entry: CallEntry.answer,
        isProvider: false,
      );
      expect(find.text('This call wasn\'t answered in time'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a call too short to count has no satisfaction question', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(heartbeats: [beat('live', connected: 3), beat('failed', connected: 6, remaining: 0)])
          ..script.insert(0, request('failed')),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await rig.elapse(tester, callHeartbeatInterval);
      expect(find.text('Were you satisfied with the call?'), findsNothing);
      expect(
        find.text('The call was too short to count (under 30 seconds). Nothing was charged.'),
        findsOneWidget,
      );
      await unmount(tester);
    });
  });

  group('the "call in progress" service (keeps the microphone alive on Android)', () {
    testWidgets('starts when the call starts ringing, with the driver\'s camera', (
      tester,
    ) async {
      final service = FakeCallService();
      await pumpLive(tester, repo: driverRepo(), service: service);
      expect(service.log, ['start:Call in progress|Tap to return to your call with Asha']);
      expect(service.lastWithCamera, isTrue);
      await unmount(tester);
    });

    testWidgets('the requester\'s needs no camera', (tester) async {
      final service = FakeCallService();
      await pumpLive(
        tester,
        repo: requesterRepo(),
        entry: CallEntry.answer,
        isProvider: false,
        service: service,
      );
      expect(service.log.single, startsWith('start:'));
      expect(service.lastWithCamera, isFalse);
      await unmount(tester);
    });

    testWidgets('is started once, not on every update', (tester) async {
      final service = FakeCallService();
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 4, remaining: 800)]),
        service: service,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await rig.elapse(tester, callHeartbeatInterval);
      expect(service.log.where((l) => l.startsWith('start:')), hasLength(1));
      await unmount(tester);
    });

    testWidgets('stops when the call ends', (tester) async {
      final service = FakeCallService();
      final rig = await pumpLive(
        tester,
        repo: driverRepo(heartbeats: [beat('live', connected: 4, remaining: 800)]),
        service: service,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await tester.tap(find.text('End'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(find.widgetWithText(TextButton, 'End'));
      await settle(tester);
      expect(service.log.last, 'stop');
      await unmount(tester);
    });

    testWidgets('is never started for a call that could not start', (tester) async {
      final service = FakeCallService();
      await pumpLive(
        tester,
        repo: driverRepo()
          ..startResult = const CallRequestException(
            code: 'REQUEST_EXPIRED',
            message: 'This request has expired',
            statusCode: 410,
          ),
        service: service,
      );
      expect(service.log.where((l) => l.startsWith('start:')), isEmpty);
      await unmount(tester);
    });

    testWidgets('is stopped if the screen is simply taken away', (tester) async {
      final service = FakeCallService();
      await pumpLive(tester, repo: driverRepo(), service: service);
      await unmount(tester);
      expect(service.log.last, 'stop');
    });
  });

  group('safety and chat', () {
    testWidgets('the system back button asks before ending a live call', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('End the call?'), findsOneWidget);
      expect(rig.repo.endCalls, 0);
      await tester.tap(find.text('Keep going'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await unmount(tester);
    });

    testWidgets('chat: an unread badge, then the message, and sending one', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(),
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      rig.engine.emit(const MediaChatReceived('Are you on the highway?'));
      await tester.pump();
      expect(find.text('1'), findsOneWidget); // unread badge on Chat

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('Are you on the highway?'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Parked at Manesar');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await settle(tester);
      expect(rig.engine.chatSent, ['Parked at Manesar']);
      expect(find.text('Parked at Manesar'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('chat: a message that cannot be sent says so and stays in the box', (
      tester,
    ) async {
      final rig = await pumpLive(
        tester,
        repo: requesterRepo(),
        engine: FakeMediaEngine()..chatWorks = false,
        entry: CallEntry.answer,
        isProvider: false,
      );
      await rig.elapse(tester, const Duration(seconds: 1));
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('Messages only last for this call.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await settle(tester);
      expect(find.text('Couldn\'t send. Check your connection.'), findsOneWidget);
      expect(find.text('hello'), findsOneWidget); // still in the box
      await unmount(tester);
    });
  });
}
