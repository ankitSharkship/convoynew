import 'package:convoynew/core/network/api_exception.dart';
import 'support.dart';
import 'package:convoynew/features/call_request/domain/usecases/call_request_usecases.dart';
import 'package:convoynew/features/call_request/presentation/state/call_request_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer containerFor(FakeRepository repo) => ProviderContainer(
  overrides: [
    getCallRequestUseCaseProvider.overrideWithValue(
      GetCallRequestUseCase(repo),
    ),
    cancelCallRequestUseCaseProvider.overrideWithValue(
      CancelCallRequestUseCase(repo),
    ),
  ],
);

void main() {
  // Timers (the poll) run on the fake clock of testWidgets: pump(Duration) moves
  // time forward and lets the scripted futures finish.
  testWidgets(
    'loads the request, then follows it until it ends and stops asking',
    (tester) async {
      final repo = FakeRepository([
        request('pending'),
        request('accepted'),
        request('rejected'),
      ]);
      final container = containerFor(repo);
      addTearDown(container.dispose);
      final sub = container.listen(
        callRequestNotifierProvider('r1'),
        (_, _) {},
      );

      await tester.pump();
      expect(sub.read().valueOrNull?.status, 'pending');
      expect(repo.getCalls, 1);

      await tester.pump(callRequestPollInterval);
      await tester.pump();
      expect(sub.read().valueOrNull?.status, 'accepted');

      await tester.pump(callRequestPollInterval);
      await tester.pump();
      expect(sub.read().valueOrNull?.status, 'rejected');
      expect(repo.getCalls, 3);

      // Over: no more polling.
      await tester.pump(callRequestPollInterval * 4);
      expect(repo.getCalls, 3);
      sub.close();
      await tester.pump(
        Duration.zero,
      ); // fires Riverpod's zero-delay auto-dispose timer
    },
  );

  testWidgets('a failed first load is an error state', (tester) async {
    final repo = FakeRepository([const ApiException('No luck')]);
    final container = containerFor(repo);
    addTearDown(container.dispose);
    final sub = container.listen(callRequestNotifierProvider('r1'), (_, _) {});

    await tester.pump();
    expect(sub.read().hasError, isTrue);
    sub.close();
    await tester.pump(
      Duration.zero,
    ); // fires Riverpod's zero-delay auto-dispose timer
  });

  testWidgets('a failed refresh keeps the last known request and tries again', (
    tester,
  ) async {
    final repo = FakeRepository([
      request('pending'),
      const ApiException(),
      request('accepted'),
    ]);
    final container = containerFor(repo);
    addTearDown(container.dispose);
    final sub = container.listen(callRequestNotifierProvider('r1'), (_, _) {});

    await tester.pump();
    await tester.pump(callRequestPollInterval); // the blip
    await tester.pump();
    expect(sub.read().valueOrNull?.status, 'pending'); // not blanked
    expect(sub.read().hasError, isFalse);

    await tester.pump(callRequestPollInterval); // and it recovers
    await tester.pump();
    expect(sub.read().valueOrNull?.status, 'accepted');
    sub.close();
    await tester.pump(
      Duration.zero,
    ); // fires Riverpod's zero-delay auto-dispose timer
  });

  testWidgets('stops polling once nobody is watching', (tester) async {
    final repo = FakeRepository([request('pending')]);
    final container = containerFor(repo);
    addTearDown(container.dispose);
    final sub = container.listen(callRequestNotifierProvider('r1'), (_, _) {});
    await tester.pump();
    expect(repo.getCalls, 1);

    sub.close(); // the sheet was closed
    await tester.pump(callRequestPollInterval * 4);
    expect(repo.getCalls, 1);
  });

  testWidgets('cancel shows the cancelled request and stops polling', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..cancelResult = request('cancelled');
    final container = containerFor(repo);
    addTearDown(container.dispose);
    final sub = container.listen(callRequestNotifierProvider('r1'), (_, _) {});
    await tester.pump();

    await container.read(callRequestNotifierProvider('r1').notifier).cancel();
    expect(sub.read().valueOrNull?.status, 'cancelled');
    expect(repo.cancelCalls, 1);

    await tester.pump(callRequestPollInterval * 4);
    expect(repo.getCalls, 1);
    sub.close();
    await tester.pump(
      Duration.zero,
    ); // fires Riverpod's zero-delay auto-dispose timer
  });

  testWidgets(
    'a failed cancel throws so the sheet can show why, and keeps the request',
    (tester) async {
      final repo = FakeRepository([request('pending')])
        ..cancelResult = const ApiException('Too late');
      final container = containerFor(repo);
      addTearDown(container.dispose);
      final sub = container.listen(
        callRequestNotifierProvider('r1'),
        (_, _) {},
      );
      await tester.pump();

      await expectLater(
        container.read(callRequestNotifierProvider('r1').notifier).cancel(),
        throwsA(isA<ApiException>()),
      );
      expect(sub.read().valueOrNull?.status, 'pending');
      sub.close();
      await tester.pump(callRequestPollInterval);
      await tester.pump(Duration.zero);
    },
  );
}
