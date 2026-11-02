import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:convoynew/features/call_request/presentation/widgets/incoming_request_sheet.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _slide = Duration(milliseconds: 400);

Future<void> openSheet(WidgetTester tester, FakeRepository repo) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
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
                onPressed: () => IncomingRequestSheet.show(context, 'r1'),
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

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(_slide);
}

FakeRepository pendingRepo() => FakeRepository([
  request('pending', role: 'provider', requesterName: 'Asha'),
]);

void main() {
  testWidgets(
    'a waiting request shows who, what about, what you earn, and Accept / Reject',
    (tester) async {
      await openSheet(tester, pendingRepo());

      expect(find.text('Asha wants a live 1:1 call with you'), findsOneWidget);
      expect(find.text('Route status'), findsOneWidget);
      expect(find.text('Offer ₹150.00 · 15 min'), findsOneWidget);
      expect(find.text('What you earn'), findsOneWidget);
      expect(
        find.text(
          'At least ₹37.50 once the call has been connected for 30 seconds. The full ₹150.00 if Asha is satisfied afterwards.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Expires in'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('Accept sends it and shows the request as accepted', (
    tester,
  ) async {
    final repo = pendingRepo()
      ..acceptResult = request(
        'accepted',
        role: 'provider',
        requesterName: 'Asha',
      );
    await openSheet(tester, repo);

    await tapAndSettle(tester, find.text('Accept'));

    expect(repo.acceptCalls, 1);
    expect(find.text("You accepted Asha's request"), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Reject'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'Reject asks first; confirming rejects and shows it as declined',
    (tester) async {
      final repo = pendingRepo()
        ..rejectResult = request(
          'rejected',
          role: 'provider',
          requesterName: 'Asha',
        );
      await openSheet(tester, repo);

      await tapAndSettle(tester, find.text('Reject'));
      expect(find.text('Reject this request?'), findsOneWidget);
      expect(
        find.text("Asha's money is released and the request is closed."),
        findsOneWidget,
      );
      expect(repo.rejectCalls, 0); // nothing yet

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Reject'),
        ),
      );
      await tester.pump();
      await tester.pump(_slide);
      await tester.pump(_slide);

      expect(repo.rejectCalls, 1);
      expect(find.text('You declined this request'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('"Keep it" in the confirmation leaves the request waiting', (
    tester,
  ) async {
    final repo = pendingRepo();
    await openSheet(tester, repo);

    await tapAndSettle(tester, find.text('Reject'));
    await tester.tap(find.text('Keep it'));
    await tester.pump();
    await tester.pump(_slide);

    expect(repo.rejectCalls, 0);
    expect(find.text('Accept'), findsOneWidget); // still waiting
    await unmount(tester);
  });

  testWidgets(
    'accepting a request that ran out says so and shows what it is now',
    (tester) async {
      final repo =
          FakeRepository([
              request('pending', role: 'provider', requesterName: 'Asha'),
              request(
                'expired',
                role: 'provider',
                requesterName: 'Asha',
              ), // what the reload finds
            ])
            ..acceptResult = const CallRequestException(
              code: 'REQUEST_EXPIRED',
              message: 'This request has expired',
              statusCode: 410,
            );
      await openSheet(tester, repo);

      await tapAndSettle(tester, find.text('Accept'));
      await tester.pump(_slide);

      expect(
        find.text('This request has expired'),
        findsOneWidget,
      ); // the server's sentence
      expect(
        find.text('This request expired'),
        findsOneWidget,
      ); // and the reloaded state
      expect(find.text('Accept'), findsNothing);
      await unmount(tester);
    },
  );

  testWidgets(
    'a requester who cancelled meanwhile: the accept is refused and the sheet follows',
    (tester) async {
      final repo =
          FakeRepository([
              request('pending', role: 'provider', requesterName: 'Asha'),
              request('cancelled', role: 'provider', requesterName: 'Asha'),
            ])
            ..acceptResult = const CallRequestException(
              code: 'INVALID_STATE',
              message: 'This request is cancelled and can\'t be accepted',
              statusCode: 409,
            );
      await openSheet(tester, repo);

      await tapAndSettle(tester, find.text('Accept'));
      await tester.pump(_slide);

      expect(find.text('Asha cancelled this request'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets(
    'every other state has its own plain sentence and just a Done button',
    (tester) async {
      final expected = {
        'rejected': 'You declined this request',
        'expired': 'This request expired',
        'cancelled': 'Asha cancelled this request',
        'failed': "The call didn't connect. Nothing was charged",
        'live': 'On a call with Asha',
        'ringing': 'On a call with Asha',
        'awaiting_feedback': "Call finished. Waiting for Asha's feedback",
      };
      for (final entry in expected.entries) {
        await openSheet(
          tester,
          FakeRepository([
            request(entry.key, role: 'provider', requesterName: 'Asha'),
          ]),
        );
        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
        expect(find.text('Accept'), findsNothing, reason: entry.key);
        expect(find.text('Done'), findsOneWidget, reason: entry.key);
        await unmount(tester);
      }
    },
  );

  testWidgets('a completed call shows what the driver earned', (tester) async {
    await openSheet(
      tester,
      FakeRepository([
        request(
          'completed',
          role: 'provider',
          requesterName: 'Asha',
          settledAmount: '150.00',
        ),
      ]),
    );
    expect(find.text('Call completed. You earned ₹150.00'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a request that cannot be loaded offers Try again', (
    tester,
  ) async {
    await openSheet(
      tester,
      FakeRepository([
        const ApiException('Server is down'),
        request('pending', role: 'provider', requesterName: 'Asha'),
      ]),
    );
    expect(find.text("Couldn't load your request"), findsOneWidget);
    expect(find.text('Server is down'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(_slide);
    expect(find.text('Asha wants a live 1:1 call with you'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('with no name on file it says "the requester"', (tester) async {
    await openSheet(
      tester,
      FakeRepository([
        request('pending', role: 'provider', requesterName: '  '),
      ]),
    );
    expect(
      find.text('the requester wants a live 1:1 call with you'),
      findsOneWidget,
    );
    await unmount(tester);
  });
}
