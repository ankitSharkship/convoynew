import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:convoynew/features/call_request/presentation/state/call_request_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  ProviderContainer containerFor(FakeRepository repo) {
    final container = ProviderContainer(overrides: repoOverrides(repo));
    addTearDown(container.dispose);
    return container;
  }

  testWidgets('loads the driver queue in the order the server gives it', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..incoming = [
        request('pending', role: 'provider', id: 'old'),
        request('pending', role: 'provider', id: 'new'),
      ];
    final container = containerFor(repo);
    final sub = container.listen(
      incomingCallRequestsNotifierProvider,
      (_, _) {},
    );
    await tester.pump(Duration.zero);

    expect(sub.read().valueOrNull!.map((r) => r.id), ['old', 'new']);
    sub.close();
    await tester.pump(Duration.zero);
  });

  testWidgets(
    'keeps asking while watched, and picks up a request that arrives later',
    (tester) async {
      final repo = FakeRepository([request('pending')])
        ..incoming = const <CallRequestEntity>[];
      final container = containerFor(repo);
      final sub = container.listen(
        incomingCallRequestsNotifierProvider,
        (_, _) {},
      );
      await tester.pump(Duration.zero);
      expect(sub.read().valueOrNull, isEmpty);

      repo.incoming = [request('pending', role: 'provider', id: 'late')];
      await tester.pump(incomingPollInterval);
      await tester.pump(Duration.zero);
      expect(sub.read().valueOrNull!.single.id, 'late');
      expect(repo.incomingCalls, 2);

      sub.close();
      await tester.pump(Duration.zero);
    },
  );

  testWidgets('a failed refresh keeps the last queue and tries again', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..incoming = [request('pending', role: 'provider', id: 'a')];
    final container = containerFor(repo);
    final sub = container.listen(
      incomingCallRequestsNotifierProvider,
      (_, _) {},
    );
    await tester.pump(Duration.zero);

    repo.incoming = const ApiException('blip');
    await tester.pump(incomingPollInterval);
    await tester.pump(Duration.zero);
    expect(sub.read().valueOrNull!.single.id, 'a'); // not blanked
    expect(sub.read().hasError, isFalse);

    repo.incoming = [request('pending', role: 'provider', id: 'b')];
    await tester.pump(incomingPollInterval);
    await tester.pump(Duration.zero);
    expect(sub.read().valueOrNull!.single.id, 'b');

    sub.close();
    await tester.pump(Duration.zero);
  });

  testWidgets('a failed first load is an error, and it recovers on its own', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..incoming = const ApiException('down');
    final container = containerFor(repo);
    final sub = container.listen(
      incomingCallRequestsNotifierProvider,
      (_, _) {},
    );
    await tester.pump(Duration.zero);
    expect(sub.read().hasError, isTrue);

    repo.incoming = [request('pending', role: 'provider')];
    await tester.pump(incomingPollInterval);
    await tester.pump(Duration.zero);
    expect(sub.read().valueOrNull, hasLength(1));

    sub.close();
    await tester.pump(Duration.zero);
  });

  testWidgets(
    'stops asking once nothing is watching (Home is hidden or closed)',
    (tester) async {
      final repo = FakeRepository([request('pending')])
        ..incoming = [request('pending', role: 'provider')];
      final container = containerFor(repo);
      final sub = container.listen(
        incomingCallRequestsNotifierProvider,
        (_, _) {},
      );
      await tester.pump(Duration.zero);
      expect(repo.incomingCalls, 1);

      sub.close();
      await tester.pump(incomingPollInterval * 3);
      expect(repo.incomingCalls, 1);
    },
  );

  group('answering a request', () {
    testWidgets('accept shows the accepted request and reloads the queue', (
      tester,
    ) async {
      final repo = FakeRepository([request('pending', role: 'provider')])
        ..incoming = [request('pending', role: 'provider')]
        ..acceptResult = request('accepted', role: 'provider');
      final container = containerFor(repo);
      final one = container.listen(
        callRequestNotifierProvider('r1'),
        (_, _) {},
      );
      final queue = container.listen(
        incomingCallRequestsNotifierProvider,
        (_, _) {},
      );
      await tester.pump(Duration.zero);
      expect(repo.incomingCalls, 1);

      await container.read(callRequestNotifierProvider('r1').notifier).accept();
      await tester.pump(Duration.zero);

      expect(one.read().valueOrNull!.status, 'accepted');
      expect(repo.acceptCalls, 1);
      expect(repo.incomingCalls, 2); // the queue was refreshed
      one.close();
      queue.close();
      await tester.pump(Duration.zero);
    });

    testWidgets('reject shows the rejected request and reloads the queue', (
      tester,
    ) async {
      final repo = FakeRepository([request('pending', role: 'provider')])
        ..incoming = [request('pending', role: 'provider')]
        ..rejectResult = request('rejected', role: 'provider');
      final container = containerFor(repo);
      final one = container.listen(
        callRequestNotifierProvider('r1'),
        (_, _) {},
      );
      final queue = container.listen(
        incomingCallRequestsNotifierProvider,
        (_, _) {},
      );
      await tester.pump(Duration.zero);

      await container.read(callRequestNotifierProvider('r1').notifier).reject();
      await tester.pump(Duration.zero);

      expect(one.read().valueOrNull!.status, 'rejected');
      expect(repo.rejectCalls, 1);
      expect(repo.incomingCalls, 2);
      one.close();
      queue.close();
      await tester.pump(Duration.zero);
    });

    testWidgets(
      'a refused accept throws so the sheet can say why, and changes nothing',
      (tester) async {
        final repo = FakeRepository([request('pending', role: 'provider')])
          ..acceptResult = const CallRequestException(
            code: 'REQUEST_EXPIRED',
            message: 'This request has expired',
            statusCode: 410,
          );
        final container = containerFor(repo);
        final one = container.listen(
          callRequestNotifierProvider('r1'),
          (_, _) {},
        );
        await tester.pump(Duration.zero);

        await expectLater(
          container.read(callRequestNotifierProvider('r1').notifier).accept(),
          throwsA(
            isA<CallRequestException>().having(
              (e) => e.code,
              'code',
              'REQUEST_EXPIRED',
            ),
          ),
        );
        expect(one.read().valueOrNull!.status, 'pending');
        one.close();
        await tester.pump(incomingPollInterval);
        await tester.pump(Duration.zero);
      },
    );
  });
}
