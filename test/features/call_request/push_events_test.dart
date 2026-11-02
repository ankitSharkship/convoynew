import 'package:convoynew/core/services/push_events_service.dart';
import 'package:convoynew/features/call_request/presentation/state/call_request_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  group('pushEventFromData', () {
    test('recognises every 1:1 call push the backend sends', () {
      for (final type in callPushTypes) {
        final event = pushEventFromData({'type': type, 'requestId': 'r1'});
        expect(event, isNotNull, reason: type);
        expect(event!.type, type);
        expect(event.requestId, 'r1');
      }
      // exactly the types in docs/ONE_TO_ONE_CALL_API.md
      expect(callPushTypes, {
        'call_request',
        'call_request_accepted',
        'call_request_rejected',
        'call_request_expired',
        'call_incoming',
        'call_cancelled',
        'call_missed',
        'call_feedback_needed',
        'call_payment',
      });
    });

    test('ignores pushes that are not about 1:1 calls', () {
      expect(pushEventFromData({'type': 'kyc_approved'}), isNull);
      expect(
        pushEventFromData({'type': 'campaign', 'campaignId': 'c'}),
        isNull,
      );
      expect(pushEventFromData({}), isNull);
      expect(pushEventFromData({'type': 42}), isNull);
    });

    test('a missing, empty or malformed requestId is simply null', () {
      expect(pushEventFromData({'type': 'call_request'})!.requestId, isNull);
      expect(
        pushEventFromData({'type': 'call_request', 'requestId': ''})!.requestId,
        isNull,
      );
      expect(
        pushEventFromData({'type': 'call_request', 'requestId': 7})!.requestId,
        isNull,
      );
    });

    test('only a call_request push is a new request for the driver', () {
      expect(
        pushEventFromData({'type': 'call_request'})!.isNewIncomingRequest,
        isTrue,
      );
      for (final type in callPushTypes.where((t) => t != 'call_request')) {
        expect(
          pushEventFromData({'type': type})!.isNewIncomingRequest,
          isFalse,
          reason: type,
        );
      }
    });
  });

  group('CallPushListener', () {
    late FakePushSource source;
    late FakeRepository repo;
    late ProviderContainer container;

    setUp(() {
      source = FakePushSource();
      repo = FakeRepository([request('pending')])
        ..incoming = [request('pending', role: 'provider')];
      container = ProviderContainer(
        overrides: [
          pushEventsSourceProvider.overrideWithValue(source),
          ...repoOverrides(repo),
        ],
      );
    });

    tearDown(() => container.dispose());

    Future<void> settle(WidgetTester tester) async {
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
    }

    testWidgets(
      'a push while the app is open reloads the driver queue straight away',
      (tester) async {
        container.read(callPushListenerProvider);
        final queue = container.listen(
          incomingCallRequestsNotifierProvider,
          (_, _) {},
        );
        await settle(tester);
        expect(repo.incomingCalls, 1);

        source.whileOpenController.add(
          const PushEvent(type: 'call_request', requestId: 'r1'),
        );
        await settle(tester);
        expect(repo.incomingCalls, 2);

        queue.close();
        await tester.pump(Duration.zero);
      },
    );

    testWidgets(
      'it also reloads the one request a push is about, if it is on screen',
      (tester) async {
        container.read(callPushListenerProvider);
        final one = container.listen(
          callRequestNotifierProvider('r1'),
          (_, _) {},
        );
        await settle(tester);
        expect(repo.getCalls, 1);

        source.whileOpenController.add(
          const PushEvent(type: 'call_request_accepted', requestId: 'r1'),
        );
        await settle(tester);
        expect(repo.getCalls, 2);

        one.close();
        await tester.pump(Duration.zero);
      },
    );

    testWidgets(
      'tapping a new-request push asks for that request to be opened',
      (tester) async {
        container.read(callPushListenerProvider);
        expect(container.read(pendingReviewRequestProvider), isNull);

        source.tappedController.add(
          const PushEvent(type: 'call_request', requestId: 'r7'),
        );
        await settle(tester);
        expect(container.read(pendingReviewRequestProvider), 'r7');
      },
    );

    testWidgets('tapping any other call push does not open a review', (
      tester,
    ) async {
      container.read(callPushListenerProvider);
      for (final type in [
        'call_payment',
        'call_request_accepted',
        'call_incoming',
      ]) {
        source.tappedController.add(PushEvent(type: type, requestId: 'r7'));
      }
      await settle(tester);
      expect(container.read(pendingReviewRequestProvider), isNull);
    });

    testWidgets('a new-request push without a request id opens nothing', (
      tester,
    ) async {
      container.read(callPushListenerProvider);
      source.tappedController.add(const PushEvent(type: 'call_request'));
      await settle(tester);
      expect(container.read(pendingReviewRequestProvider), isNull);
    });

    testWidgets(
      'the push that launched the app from closed opens its request',
      (tester) async {
        source.launched = const PushEvent(
          type: 'call_request',
          requestId: 'r9',
        );
        container.read(callPushListenerProvider);
        await settle(tester);
        expect(container.read(pendingReviewRequestProvider), 'r9');
      },
    );

    testWidgets('it stops listening when disposed', (tester) async {
      container.read(callPushListenerProvider);
      await settle(tester);
      expect(source.whileOpenController.hasListener, isTrue);
      expect(source.tappedController.hasListener, isTrue);

      container.dispose();
      expect(source.whileOpenController.hasListener, isFalse);
      expect(source.tappedController.hasListener, isFalse);
      container = ProviderContainer(); // for tearDown
    });

    test('PendingReviewRequest can be set and cleared', () {
      final notifier = container.read(pendingReviewRequestProvider.notifier);
      notifier.open('r1');
      expect(container.read(pendingReviewRequestProvider), 'r1');
      notifier.clear();
      expect(container.read(pendingReviewRequestProvider), isNull);
    });
  });
}
