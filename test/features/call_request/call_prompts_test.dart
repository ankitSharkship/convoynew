import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/presentation/call/call_event_reporter.dart';
import 'package:convoynew/features/call_request/presentation/call/call_prompts.dart';
import 'package:convoynew/features/call_request/presentation/call/call_routes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

final now = DateTime.utc(2029, 1, 1, 12);
final soon = now.add(const Duration(seconds: 30));
final past = now.subtract(const Duration(seconds: 1));

CallPromptTarget? next({
  List<CallRequestEntity> outgoing = const [],
  List<CallRequestEntity> incoming = const [],
  Set<String> handled = const {},
  String? onCall,
  Set<String> system = const {},
}) => nextCallPrompt(
  outgoing: outgoing,
  incoming: incoming,
  now: now,
  handled: handled,
  onCallScreenFor: onCall,
  systemCallScreenFor: system,
);

void main() {
  group('the ring', () {
    test('a ringing request of mine brings up the ring screen', () {
      final t = next(outgoing: [request('ringing', ringEndsAt: soon)]);
      expect(t?.prompt, CallPrompt.incomingRing);
      expect(t?.request.id, 'r1');
    });

    test('a ring whose time is up is not shown', () {
      expect(next(outgoing: [request('ringing', ringEndsAt: past)]), isNull);
      expect(next(outgoing: [request('ringing')]), isNull, reason: 'no deadline');
    });

    test('each ring is shown once, but a new ring of the same request is shown', () {
      final first = next(outgoing: [request('ringing', ringEndsAt: soon)])!;
      expect(
        next(
          outgoing: [request('ringing', ringEndsAt: soon)],
          handled: {first.key},
        ),
        isNull,
      );
      final retry = next(
        outgoing: [
          request('ringing', ringEndsAt: soon.add(const Duration(minutes: 2))),
        ],
        handled: {first.key},
      );
      expect(retry?.prompt, CallPrompt.incomingRing);
      expect(retry!.key, isNot(first.key));
    });

    test('a ring the phone\'s own call screen is already showing is not doubled', () {
      final ring = request('ringing', ringEndsAt: soon);
      expect(next(outgoing: [ring], system: {'r1'}), isNull);
      expect(next(outgoing: [ring], system: {'other'})?.prompt, CallPrompt.incomingRing);
    });

    test('a ring I am already answering is not shown again', () {
      expect(
        next(outgoing: [request('ringing', ringEndsAt: soon)], onCall: 'r1'),
        isNull,
      );
    });

    test('the driver\'s own request ringing is not a ring for them', () {
      expect(
        next(
          outgoing: [request('ringing', role: 'provider', ringEndsAt: soon)],
        )?.prompt,
        isNot(CallPrompt.incomingRing),
      );
    });
  });

  group('a call that is still on', () {
    test('either side is offered to rejoin', () {
      expect(
        next(outgoing: [request('live')])?.prompt,
        CallPrompt.rejoin,
      );
      expect(
        next(incoming: [request('live', role: 'provider')])?.prompt,
        CallPrompt.rejoin,
      );
    });

    test('so is a driver whose call is still ringing', () {
      expect(
        next(incoming: [request('ringing', role: 'provider')])?.prompt,
        CallPrompt.rejoin,
      );
    });

    test('offered once per call', () {
      final t = next(outgoing: [request('live')])!;
      expect(
        next(outgoing: [request('live')], handled: {t.key}),
        isNull,
      );
    });

    test('not while that call\'s screen is open', () {
      expect(next(outgoing: [request('live')], onCall: 'r1'), isNull);
    });

    test('a ring beats a rejoin', () {
      final t = next(
        outgoing: [
          request('ringing', id: 'ring', ringEndsAt: soon),
          request('live', id: 'live'),
        ],
      );
      expect(t?.prompt, CallPrompt.incomingRing);
      expect(t?.request.id, 'ring');
    });
  });

  group('the satisfaction question', () {
    test('is asked for a call waiting for it', () {
      final t = next(
        outgoing: [request('awaiting_feedback', feedbackDeadline: soon)],
      );
      expect(t?.prompt, CallPrompt.feedback);
    });

    test('not once its 24 hours are up (it was settled as "no")', () {
      expect(
        next(
          outgoing: [request('awaiting_feedback', feedbackDeadline: past)],
        ),
        isNull,
      );
    });

    test('is asked once per app run ("Decide later" is respected)', () {
      final t = next(
        outgoing: [request('awaiting_feedback', feedbackDeadline: soon)],
      )!;
      expect(
        next(
          outgoing: [request('awaiting_feedback', feedbackDeadline: soon)],
          handled: {t.key},
        ),
        isNull,
      );
    });

    test('only the requester is asked', () {
      expect(
        next(
          incoming: [request('awaiting_feedback', role: 'provider')],
          outgoing: const [],
        ),
        isNull,
      );
    });

    test('a rejoin comes before the question', () {
      final t = next(
        outgoing: [
          request('awaiting_feedback', id: 'fb', feedbackDeadline: soon),
          request('live', id: 'live'),
        ],
      );
      expect(t?.prompt, CallPrompt.rejoin);
    });
  });

  test('requests that need nothing give nothing', () {
    expect(
      next(
        outgoing: [request('pending'), request('accepted', id: 'b')],
        incoming: [request('pending', role: 'provider', id: 'c')],
      ),
      isNull,
    );
  });

  group('routes', () {
    test('paths read back to the request they are about', () {
      for (final path in [
        CallRoutes.call('abc', mode: 'start', driver: true),
        CallRoutes.incoming('abc'),
        CallRoutes.rejoin('abc'),
        CallRoutes.feedback('abc'),
      ]) {
        final clean = Uri.parse(path).path;
        expect(CallRoutes.isCallPath(clean), isTrue, reason: path);
        expect(CallRoutes.requestIdOf(clean), 'abc', reason: path);
      }
      expect(CallRoutes.isCallPath('/home'), isFalse);
      expect(CallRoutes.requestIdOf('/call'), isNull);
      expect(CallRoutes.call('x', mode: 'answer', driver: false), contains('driver=0'));
    });
  });

  group('the event reporter', () {
    test('stops recording toggles near the server\'s limit but keeps the essentials', () {
      var sent = <CallBehaviourEvent>[];
      final reporter = CallEventReporter((events) async => sent = [...sent, ...events], () => now);

      for (var i = 0; i < 100; i++) {
        reporter.record(CallEventType.micOff);
      }
      reporter.record(CallEventType.callJoined);
      reporter.record(CallEventType.callLeft);
      expect(reporter.pendingCount, CallEventReporter.maxToggles + 2);

      for (var i = 0; i < 50; i++) {
        reporter.record(CallEventType.callCut);
      }
      expect(reporter.pendingCount, CallEventReporter.maxEvents);
    });

    test('a failed send keeps the events for the next try, in order', () async {
      var fail = true;
      final batches = <List<String>>[];
      final reporter = CallEventReporter((events) async {
        if (fail) throw StateError('offline');
        batches.add(events.map((e) => e.type).toList());
      }, () => now);

      reporter.record(CallEventType.callJoined);
      await reporter.flush();
      reporter.record(CallEventType.micOff);
      expect(reporter.pendingCount, 2);

      fail = false;
      await reporter.flush();
      expect(batches.single, [CallEventType.callJoined, CallEventType.micOff]);
      expect(reporter.pendingCount, 0);
    });
  });
}
