import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/presentation/state/call_request_notifier.dart';
import 'package:convoynew/features/call_request/presentation/widgets/incoming_request_banner.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _slide = Duration(milliseconds: 400);

CallRequestEntity asDriver(
  String status, {
  String id = 'r1',
  String name = 'Vikramjeet Singh',
  String amount = '150.00',
}) => request(
  status,
  role: 'provider',
  id: id,
  requesterName: name,
  amount: amount,
);

late ProviderContainer _container;

/// Home with the banner floating at the bottom, as in HomeScreen.
Future<ProviderContainer> pumpHome(
  WidgetTester tester,
  FakeRepository repo, {
  bool homeVisible = true,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = _container = ProviderContainer(
    overrides: repoOverrides(repo),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TickerMode(
            enabled: homeVisible,
            child: const Stack(
              children: [
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: IncomingRequestBanner(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(Duration.zero);
  await tester.pump(Duration.zero);
  return container;
}

/// Takes the screen down and disposes the container, which cancels the queue's
/// poll timer, so no timer outlives the test.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
  _container.dispose();
}

void main() {
  testWidgets('shows nothing when no request is waiting', (tester) async {
    await pumpHome(
      tester,
      FakeRepository([asDriver('pending')])
        ..incoming = const <CallRequestEntity>[],
    );
    expect(find.text('1:1 Video Request Pending'), findsNothing);
    expect(find.text('Review'), findsNothing);
    await unmount(tester);
  });

  testWidgets(
    'shows the oldest waiting request: who, how much, and a Review button',
    (tester) async {
      final repo = FakeRepository([asDriver('pending')])
        ..incoming = [
          asDriver(
            'pending',
            id: 'old',
            name: 'Vikramjeet Singh',
            amount: '150.00',
          ),
        ];
      await pumpHome(tester, repo);

      expect(find.text('1:1 Video Request Pending'), findsOneWidget);
      expect(
        find.textContaining('Vikramjeet Singh', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('₹150.00 offered', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Review'), findsOneWidget);
      expect(find.textContaining('more', findRichText: true), findsNothing);
      await unmount(tester);
    },
  );

  testWidgets(
    'with several waiting it shows the first, and the queue length on a badge',
    (tester) async {
      final repo = FakeRepository([asDriver('pending')])
        ..incoming = [
          asDriver('pending', id: 'a', name: 'First Person'),
          asDriver('pending', id: 'b', name: 'Second Person'),
          asDriver('pending', id: 'c', name: 'Third Person'),
        ];
      await pumpHome(tester, repo);

      expect(
        find.textContaining('First Person', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Second Person', findRichText: true),
        findsNothing,
      );
      expect(find.text('3'), findsOneWidget); // three are waiting
      await unmount(tester);
    },
  );

  testWidgets('a single waiting request has no number on it', (tester) async {
    final repo = FakeRepository([asDriver('pending')])
      ..incoming = [asDriver('pending')];
    await pumpHome(tester, repo);
    expect(find.text('1'), findsNothing);
    expect(find.text('1:1 Video Request Pending'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'on a phone-width screen the amount is never the part that is cut off',
    (tester) async {
      final repo = FakeRepository([asDriver('pending')])
        ..incoming = [
          asDriver(
            'pending',
            id: 'a',
            name: 'Vikramjeet Singh Rathore',
            amount: '10000.00',
          ),
          asDriver('pending', id: 'b'),
          asDriver('pending', id: 'c'),
        ];
      await pumpHome(tester, repo);

      // Whatever the name's length, the amount is on screen, inside the banner.
      final amount = find.text('₹10,000.00 offered');
      expect(amount, findsOneWidget);
      final amountRect = tester.getRect(amount);
      final bannerRect = tester.getRect(find.byType(IncomingRequestBanner));
      expect(bannerRect.left, lessThanOrEqualTo(amountRect.left));
      expect(amountRect.right, lessThanOrEqualTo(bannerRect.right));
      expect(
        amountRect.bottom,
        lessThanOrEqualTo(844),
      ); // on a 390 x 844 screen
      // and the whole title is there, scaled rather than cut
      expect(find.text('1:1 Video Request Pending'), findsOneWidget);
      expect(tester.takeException(), isNull); // no overflow stripes
      await unmount(tester);
    },
  );

  testWidgets(
    'accepted requests are not "pending": they show as ready to start, not as a request to review',
    (tester) async {
      final repo = FakeRepository([asDriver('pending')])
        ..incoming = [asDriver('accepted'), asDriver('accepted', id: 'r2')];
      await pumpHome(tester, repo);

      expect(find.text('1:1 Video Request Pending'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.text('1:1 call ready to start'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // two are ready
      await unmount(tester);
    },
  );

  testWidgets('a request waiting for an answer comes before ready ones', (
    tester,
  ) async {
    final repo = FakeRepository([asDriver('pending')])
      ..incoming = [
        asDriver('accepted', id: 'ready', name: 'Ready Person'),
        asDriver('pending', id: 'waiting', name: 'Waiting Person'),
      ];
    await pumpHome(tester, repo);

    expect(find.text('1:1 Video Request Pending'), findsOneWidget);
    expect(find.text('1:1 call ready to start'), findsNothing);
    expect(
      find.textContaining('Waiting Person', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Review'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a ready request opens the same sheet, which offers Start call', (
    tester,
  ) async {
    final repo = FakeRepository([asDriver('accepted')])
      ..incoming = [asDriver('accepted')];
    await pumpHome(tester, repo);

    await tester.tap(find.text('Start'));
    await tester.pump(_slide);
    await tester.pump(_slide);
    expect(find.text('Start call'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tapping it opens the request for review', (tester) async {
    final repo = FakeRepository([asDriver('pending', name: 'Vikramjeet Singh')])
      ..incoming = [asDriver('pending', name: 'Vikramjeet Singh')];
    await pumpHome(tester, repo);

    await tester.tap(find.text('Review'));
    await tester.pump(_slide);
    await tester.pump(_slide);

    expect(find.text('1:1 video request'), findsOneWidget);
    expect(
      find.text('Vikramjeet Singh wants a live 1:1 call with you'),
      findsOneWidget,
    );
    expect(find.text('Accept'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a hidden Home tab shows nothing and does not ask the server', (
    tester,
  ) async {
    final repo = FakeRepository([asDriver('pending')])
      ..incoming = [asDriver('pending')];
    await pumpHome(tester, repo, homeVisible: false);

    expect(find.text('1:1 Video Request Pending'), findsNothing);
    expect(repo.incomingCalls, 0);
    await tester.pump(incomingPollInterval * 2);
    expect(repo.incomingCalls, 0);
    await unmount(tester);
  });

  testWidgets(
    'a tapped push opens that request once Home is showing, and clears the ask',
    (tester) async {
      final repo = FakeRepository([asDriver('pending', name: 'Pushed Person')])
        ..incoming = const <CallRequestEntity>[];
      final container = await pumpHome(tester, repo);
      expect(find.text('1:1 video request'), findsNothing);

      container.read(pendingReviewRequestProvider.notifier).open('r1');
      await tester.pump(Duration.zero);
      await tester.pump(_slide);
      await tester.pump(_slide);

      expect(
        find.text('Pushed Person wants a live 1:1 call with you'),
        findsOneWidget,
      );
      expect(container.read(pendingReviewRequestProvider), isNull);
      await unmount(tester);
    },
  );
}
