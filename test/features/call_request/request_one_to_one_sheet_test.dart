import 'package:convoynew/core/constants/feature_flags.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:convoynew/features/call_request/presentation/state/call_request_notifier.dart';
import 'package:convoynew/features/call_request/presentation/widgets/request_one_to_one_sheet.dart';
import 'package:convoynew/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _slide = Duration(milliseconds: 400);

/// A page with one button that opens the form, like the truck details sheet does.
Future<(FakeComposer, FakeRepository)> openForm(
  WidgetTester tester, {
  String? spendable = '500.00',
  Size logicalSize = const Size(800, 2000),
  double pixelRatio = 1,
}) async {
  tester.view.physicalSize = logicalSize * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  final composer = FakeComposer()..result = request('pending');
  final repo = FakeRepository([request('pending')]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        walletNotifierProvider.overrideWith(() => FakeWallet(spendable)),
        callRequestComposerProvider.overrideWith(() => composer),
        ...repoOverrides(repo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => RequestOneToOneSheet.show(context, truck()),
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
  return (composer, repo);
}

/// Closes everything so no timer outlives the test.
Future<void> tearDownTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

Finder get _topicField => find.byType(TextFormField).at(0);
Finder get _amountField => find.byType(TextFormField).at(1);

Future<void> typeTopic(
  WidgetTester tester, [
  String text = 'Route status',
]) async {
  await tester.enterText(_topicField, text);
  await tester.pump();
}

Future<void> typeAmount(WidgetTester tester, String text) async {
  await tester.enterText(_amountField, text);
  await tester.pump();
}

Future<void> tapSend(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Send request'));
  await tester.tap(find.text('Send request'));
  await tester.pump();
  await tester.pump(_slide);
}

void main() {
  // iPhone 16e: 390 x 844 logical points. The form is taller than that, so its
  // Send button must not be something you have to scroll to find.
  testWidgets(
    'on a phone-sized screen Send request is on screen without scrolling',
    (tester) async {
      final (composer, _) = await openForm(
        tester,
        logicalSize: const Size(390, 844),
        pixelRatio: 3,
      );
      final send = tester.getRect(find.text('Send request'));
      expect(send.top, greaterThan(0));
      expect(send.bottom, lessThanOrEqualTo(844));

      await typeTopic(tester);
      await tester.tap(
        find.text('Send request'),
      ); // no ensureVisible / scrolling
      await tester.pump(_slide);
      expect(composer.calls, hasLength(1));
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'even with the recharge notice showing, Send request stays on screen',
    (tester) async {
      await openForm(
        tester,
        spendable: '10.00',
        logicalSize: const Size(390, 844),
        pixelRatio: 3,
      );
      expect(
        find.textContaining('to your wallet to send this request'),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.text('Send request')).bottom,
        lessThanOrEqualTo(844),
      );
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'shows the form with the driver, the defaults and the money explained',
    (tester) async {
      await openForm(tester);

      expect(find.text('Request 1:1 Live Session'), findsOneWidget);
      expect(find.textContaining('Vikramjeet Singh'), findsOneWidget);
      expect(find.text('10 mins'), findsOneWidget);
      expect(find.text('15 mins'), findsOneWidget);
      expect(find.text('30 mins'), findsOneWidget);
      expect(find.text('Wallet: ₹500.00 available'), findsOneWidget);
      // default offer ₹100 freezes the ₹25 minimum
      expect(find.textContaining('₹25.00 is frozen now'), findsOneWidget);
      expect(find.textContaining('pay the full ₹100.00'), findsOneWidget);
      await tearDownTree(tester);
    },
  );

  testWidgets('the explanation follows the offer (25% above the ₹25 floor)', (
    tester,
  ) async {
    await openForm(tester);
    await typeAmount(tester, '150');
    expect(find.textContaining('₹37.50 is frozen now'), findsOneWidget);
    await typeAmount(tester, '1000');
    expect(find.textContaining('₹250.00 is frozen now'), findsOneWidget);
    await tearDownTree(tester);
  });

  testWidgets('quick amount chips fill in the offer', (tester) async {
    await openForm(tester);
    await tester.tap(find.text('₹200'));
    await tester.pump();
    expect(tester.widget<TextFormField>(_amountField).controller!.text, '200');
    await tearDownTree(tester);
  });

  testWidgets('a topic is required and nothing is sent without one', (
    tester,
  ) async {
    final (composer, _) = await openForm(tester);
    await tapSend(tester);
    expect(
      find.text('Tell the driver what you want to discuss'),
      findsOneWidget,
    );
    expect(composer.calls, isEmpty);
    await tearDownTree(tester);
  });

  testWidgets('an offer outside ₹50 to ₹10,000 is refused before sending', (
    tester,
  ) async {
    final (composer, _) = await openForm(tester);
    await typeTopic(tester);
    for (final bad in ['10', '10001', '']) {
      await typeAmount(tester, bad);
      await tapSend(tester);
      expect(
        find.text('Offer between ₹50.00 and ₹10,000.00'),
        findsOneWidget,
        reason: 'amount "$bad"',
      );
    }
    expect(composer.calls, isEmpty);
    await tearDownTree(tester);
  });

  testWidgets(
    'a wallet that cannot cover the offer says how much to add and sends nothing',
    (tester) async {
      final (composer, _) = await openForm(tester, spendable: '40.00');
      await typeTopic(tester);
      expect(
        find.text('Add ₹60.00 to your wallet to send this request'),
        findsOneWidget,
      );
      if (FeatureFlags.rechargeEnabled || FeatureFlags.devWalletCreditEnabled) {
        // a way to add money is switched on: the button is offered
        expect(find.text('Add money'), findsOneWidget);
        expect(find.text('Wallet recharge is coming soon'), findsNothing);
      } else {
        // no way to add money is on: say so
        expect(find.text('Wallet recharge is coming soon'), findsOneWidget);
        expect(find.text('Add money'), findsNothing);
      }

      await tapSend(tester);
      expect(composer.calls, isEmpty);
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'a valid request is sent exactly as filled in, then its status opens',
    (tester) async {
      final (composer, _) = await openForm(tester);
      await typeTopic(tester, '  Load negotiation  ');
      await tester.tap(find.text('30 mins'));
      await typeAmount(tester, '250');
      await tapSend(tester);
      await tester.pump(_slide);

      expect(composer.calls, [
        {
          'providerId': 'u',
          'truckRouteId': 'r',
          'topic': 'Load negotiation',
          'durationMinutes': 30,
          'amountRupees': 250,
        },
      ]);
      expect(
        find.text('Request 1:1 Live Session'),
        findsNothing,
      ); // the form is gone
      expect(
        find.text('Your 1:1 request'),
        findsOneWidget,
      ); // the status sheet took over
      await tearDownTree(tester);
    },
  );

  testWidgets(
    'a 402 the form could not foresee still shows the recharge prompt',
    (tester) async {
      // wallet balance unknown (couldn't load): the server is the one to say no
      final (composer, _) = await openForm(tester, spendable: null);
      composer.error = const CallRequestException(
        code: 'INSUFFICIENT_BALANCE',
        message: 'Add ₹60.00 to your wallet to offer ₹100.00',
        extra: {'shortfall': '60.00'},
      );
      await typeTopic(tester);
      await tapSend(tester);

      expect(composer.calls, hasLength(1));
      expect(
        find.text('Add ₹60.00 to your wallet to send this request'),
        findsOneWidget,
      );
      expect(
        find.text('Request 1:1 Live Session'),
        findsOneWidget,
      ); // still open to fix it
      await tearDownTree(tester);
    },
  );

  testWidgets('an open request with this driver opens that request instead', (
    tester,
  ) async {
    final (composer, repo) = await openForm(tester);
    composer.error = const CallRequestException(
      code: 'ALREADY_OPEN',
      message: 'You already have an open request with this driver',
      extra: {'requestId': 'existing-1'},
    );
    await typeTopic(tester);
    await tapSend(tester);
    await tester.pump(_slide);

    expect(find.text('Your 1:1 request'), findsOneWidget);
    expect(repo.getCalls, greaterThan(0));
    await tearDownTree(tester);
  });

  testWidgets("any other refusal shows the server's sentence", (tester) async {
    final (composer, _) = await openForm(tester);
    composer.error = const CallRequestException(
      code: 'TRUCK_POST_UNAVAILABLE',
      message: 'This truck post is no longer available',
    );
    await typeTopic(tester);
    await tapSend(tester);

    expect(find.text('This truck post is no longer available'), findsOneWidget);
    expect(find.text('Request 1:1 Live Session'), findsOneWidget);
    await tearDownTree(tester);
  });
}
