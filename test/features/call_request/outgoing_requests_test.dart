import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/presentation/state/call_providers.dart';
import 'package:convoynew/features/call_request/presentation/state/outgoing_requests_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

ProviderContainer containerFor(FakeRepository repo) => ProviderContainer(
  overrides: [callRepositoryProvider.overrideWithValue(repo)],
);

void main() {
  // Timers run on testWidgets' fake clock: pump(Duration) moves time forward.
  testWidgets('with nothing open it asks once and then leaves the server alone', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')])..outgoing = const <CallRequestEntity>[];
    final container = containerFor(repo);
    final sub = container.listen(outgoingActiveRequestsProvider, (_, _) {});

    await tester.pump();
    expect(repo.outgoingCalls, 1);
    await tester.pump(const Duration(minutes: 5));
    expect(repo.outgoingCalls, 1);
    sub.close();
    container.dispose(); // the provider lives as long as the app: cancel its timer
    await tester.pump(Duration.zero);
  });

  testWidgets('a request still waiting is re-read every few seconds', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..outgoing = [request('pending')];
    final container = containerFor(repo);
    final sub = container.listen(outgoingActiveRequestsProvider, (_, _) {});

    await tester.pump();
    expect(repo.outgoingCalls, 1);
    await tester.pump(outgoingPollWhenWaiting);
    await tester.pump();
    expect(repo.outgoingCalls, 2);
    sub.close();
    container.dispose(); // the provider lives as long as the app: cancel its timer
    await tester.pump(Duration.zero);
  });

  testWidgets('an accepted request (a ring is likely) is re-read faster', (
    tester,
  ) async {
    final repo = FakeRepository([request('accepted')])
      ..outgoing = [request('accepted')];
    final container = containerFor(repo);
    final sub = container.listen(outgoingActiveRequestsProvider, (_, _) {});

    await tester.pump();
    await tester.pump(outgoingPollWhenCallLikely);
    await tester.pump();
    await tester.pump(outgoingPollWhenCallLikely);
    await tester.pump();
    expect(repo.outgoingCalls, 3);
    sub.close();
    container.dispose(); // the provider lives as long as the app: cancel its timer
    await tester.pump(Duration.zero);
  });

  testWidgets('it notices the ring and then stops fast polling', (tester) async {
    final repo = FakeRepository([request('accepted')])
      ..outgoing = [request('accepted')];
    final container = containerFor(repo);
    final seen = <String>[];
    final sub = container.listen(outgoingActiveRequestsProvider, (_, next) {
      final list = next.valueOrNull;
      if (list != null && list.isNotEmpty) seen.add(list.first.status);
    });

    await tester.pump();
    repo.outgoing = [request('ringing')];
    await tester.pump(outgoingPollWhenCallLikely);
    await tester.pump();
    expect(seen.last, 'ringing');

    repo.outgoing = const <CallRequestEntity>[]; // answered, call ended, settled
    await tester.pump(outgoingPollWhenCallLikely);
    await tester.pump();
    final calls = repo.outgoingCalls;
    await tester.pump(const Duration(minutes: 2));
    expect(repo.outgoingCalls, calls, reason: 'nothing open: no more polling');
    sub.close();
    container.dispose(); // the provider lives as long as the app: cancel its timer
    await tester.pump(Duration.zero);
  });

  testWidgets('a failing read is not an error screen, and is retried', (
    tester,
  ) async {
    final repo = FakeRepository([request('live')])..outgoing = const ApiException();
    final container = containerFor(repo);
    final sub = container.listen(outgoingActiveRequestsProvider, (_, _) {});

    await tester.pump();
    expect(sub.read().valueOrNull, isEmpty);
    repo.outgoing = [request('awaiting_feedback')];
    await tester.pump(outgoingPollAfterError);
    await tester.pump();
    expect(sub.read().valueOrNull?.single.status, 'awaiting_feedback');
    sub.close();
    container.dispose(); // the provider lives as long as the app: cancel its timer
    await tester.pump(Duration.zero);
  });

  testWidgets('refresh() reads again at once', (tester) async {
    final repo = FakeRepository([request('live')])..outgoing = const <CallRequestEntity>[];
    final container = containerFor(repo);
    final sub = container.listen(outgoingActiveRequestsProvider, (_, _) {});
    await tester.pump();

    repo.outgoing = [request('ringing')];
    container.read(outgoingActiveRequestsProvider.notifier).refresh();
    await tester.pump();
    await tester.pump();
    expect(sub.read().valueOrNull?.single.status, 'ringing');
    sub.close();
    container.dispose(); // the provider lives as long as the app: cancel its timer
    await tester.pump(Duration.zero);
  });
}
