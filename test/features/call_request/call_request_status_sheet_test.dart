import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/presentation/widgets/call_request_status_sheet.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _slide = Duration(milliseconds: 400);

Future<void> openStatus(WidgetTester tester, FakeRepository repo) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: repoOverrides(repo),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => CallRequestStatusSheet.show(context, 'r1'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump(_slide);
  await tester.pump(_slide);
}

Future<void> tearDownTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets(
    'a pending request shows the offer, what is frozen, a countdown and Cancel',
    (tester) async {
      await openStatus(tester, FakeRepository([request('pending')]));

      expect(find.text('Your 1:1 request'), findsOneWidget);
      expect(find.text('Waiting for Vikram to respond'), findsOneWidget);
      expect(find.text('Route status'), findsOneWidget);
      expect(find.text('Offer ₹150.00 · 15 min'), findsOneWidget);
      expect(
        find.text('₹37.50 is frozen until the request ends'),
        findsOneWidget,
      );
      expect(find.textContaining('Expires in'), findsOneWidget);
      expect(find.text('Cancel request'), findsOneWidget);
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'an accepted request says the driver will call, and can still be cancelled',
    (tester) async {
      await openStatus(tester, FakeRepository([request('accepted')]));
      expect(
        find.text('Vikram accepted. They will call you shortly'),
        findsOneWidget,
      );
      expect(find.text('Cancel request'), findsOneWidget);
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'a rejected request says the money is back and offers Done, not Cancel',
    (tester) async {
      await openStatus(tester, FakeRepository([request('rejected')]));
      expect(
        find.text(
          "Vikram can't take your call right now. Your money has been released",
        ),
        findsOneWidget,
      );
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel request'), findsNothing);
      expect(find.textContaining('frozen'), findsNothing);
      expect(find.textContaining('Expires in'), findsNothing);
      await tearDownTree(tester);
    },
  );

  testWidgets('every ending has its own plain sentence', (tester) async {
    const endings = {
      'expired': 'No response in time. Your money has been released',
      'cancelled': 'Request cancelled. Your money has been released',
      'failed': "The call didn't connect. Nothing was charged",
      'awaiting_feedback':
          'Call finished. Tell us how it went to complete payment',
    };
    for (final entry in endings.entries) {
      await openStatus(tester, FakeRepository([request(entry.key)]));
      expect(find.text(entry.value), findsOneWidget, reason: entry.key);
      await tearDownTree(tester);
    }
  });

  testWidgets('a completed call shows what was actually paid, not the offer', (
    tester,
  ) async {
    // offered ₹150, but the requester wasn't satisfied: only the ₹37.50 call amount
    await openStatus(
      tester,
      FakeRepository([request('completed', settledAmount: '37.50')]),
    );
    expect(find.text('Call completed. You paid ₹37.50'), findsOneWidget);
    await tearDownTree(tester);
  });

  testWidgets('Cancel withdraws the request and shows it as cancelled', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..cancelResult = request('cancelled');
    await openStatus(tester, repo);

    await tester.tap(find.text('Cancel request'));
    await tester.pump();
    await tester.pump(_slide);

    expect(repo.cancelCalls, 1);
    expect(
      find.text('Request cancelled. Your money has been released'),
      findsOneWidget,
    );
    expect(find.text('Cancel request'), findsNothing);
    await tearDownTree(tester);
  });

  testWidgets('a refused cancel shows why and keeps the request', (
    tester,
  ) async {
    final repo = FakeRepository([request('pending')])
      ..cancelResult = const ApiException('Too late to cancel');
    await openStatus(tester, repo);

    await tester.tap(find.text('Cancel request'));
    await tester.pump();
    await tester.pump(_slide);

    expect(find.text('Too late to cancel'), findsOneWidget);
    expect(find.text('Waiting for Vikram to respond'), findsOneWidget);
    await tearDownTree(tester);
  });

  testWidgets(
    'a request that cannot be loaded offers Try again, which recovers',
    (tester) async {
      await openStatus(
        tester,
        FakeRepository([
          const ApiException('Server is down'),
          request('pending'),
        ]),
      );

      expect(find.text("Couldn't load your request"), findsOneWidget);
      expect(find.text('Server is down'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      await tester.pump(_slide);
      expect(find.text('Waiting for Vikram to respond'), findsOneWidget);
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'the sheet keeps itself up to date: the driver accepting shows up without a tap',
    (tester) async {
      await openStatus(
        tester,
        FakeRepository([request('pending'), request('accepted')]),
      );
      expect(find.text('Waiting for Vikram to respond'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(
        find.text('Vikram accepted. They will call you shortly'),
        findsOneWidget,
      );
      await tearDownTree(tester);
    },
  );
}
