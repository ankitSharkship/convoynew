import 'dart:async';

import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/wallet/domain/entities/recharge_entities.dart';
import 'package:convoynew/features/wallet/domain/failures/recharge_exception.dart';
import 'package:convoynew/features/wallet/presentation/widgets/recharge_sheet.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recharge_support.dart';

const _slide = Duration(milliseconds: 400);

Future<void> openSheet(
  WidgetTester tester, {
  required FakeRechargeRepository repo,
  required FakeGateway gateway,
  int? suggested,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  CountingWallet.builds = 0;
  await tester.pumpWidget(
    ProviderScope(
      overrides: rechargeOverrides(repo, gateway),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    RechargeSheet.show(context, suggestedRupees: suggested),
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
  await tester.pump();
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

/// The sheet's own button (the page behind it has one too).
Finder get payButton => find.descendant(
  of: find.byType(RechargeSheet),
  matching: find.byType(ElevatedButton),
);

Future<void> type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

void main() {
  test('paise are shown as rupees', () {
    expect(rupeesOfPaise(51209), '₹512.09');
    expect(rupeesOfPaise(1025), '₹10.25');
    expect(rupeesOfPaise(5), '₹0.05');
    expect(rupeesOfPaise(1024171), '₹10,241.71');
  });

  testWidgets('an amount shows what lands in the wallet, the fee on top, and what you pay', (tester) async {
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: FakeGateway());
    expect(find.text('Add money to your wallet'), findsOneWidget);
    expect(find.text('Between ₹10 and ₹10000 at a time'), findsOneWidget);

    await type(tester, '500');
    expect(find.text('Added to your wallet'), findsOneWidget);
    expect(find.text('₹500.00'), findsOneWidget);
    expect(find.text('Payment gateway fee'), findsOneWidget);
    expect(find.text('₹12.09'), findsOneWidget);
    expect(find.text('You pay'), findsOneWidget);
    expect(find.text('₹512.09'), findsWidgets); // in the breakdown and on the button
    expect(find.text('Pay ₹512.09'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('with nothing typed (or an amount out of range) there is nothing to pay yet', (tester) async {
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: FakeGateway());
    expect(tester.widget<ElevatedButton>(payButton).onPressed, isNull);

    for (final bad in ['5', '10001', '99999']) {
      await type(tester, bad);
      expect(find.text('Enter an amount between ₹10 and ₹10000'), findsOneWidget, reason: bad);
      expect(find.text('You pay'), findsNothing, reason: bad);
      expect(tester.widget<ElevatedButton>(payButton).onPressed, isNull, reason: bad);
    }
    await type(tester, '10');
    expect(find.text('Pay ₹10.25'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('only digits can be typed', (tester) async {
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: FakeGateway());
    await type(tester, '12ab.5-');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '125');
    await unmount(tester);
  });

  testWidgets('the quick amounts fill the box', (tester) async {
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: FakeGateway());
    await tester.tap(find.text('₹250'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '250');
    expect(find.text('Pay ₹256.05'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a suggested amount (the shortfall that stopped a request) is already filled in', (tester) async {
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: FakeGateway(), suggested: 150);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '150');
    expect(find.text('Added to your wallet'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('paying: the order is made for the amount wanted, Razorpay opens with the server\'s total, and the result is shown', (tester) async {
    final repo = FakeRechargeRepository();
    final gateway = FakeGateway();
    await openSheet(tester, repo: repo, gateway: gateway);
    await type(tester, '500');
    await tester.tap(find.text('Pay ₹512.09'));
    await settle(tester);

    expect(repo.created, [500]);
    expect(gateway.opened.single.amountPaise, 51209);
    expect(find.text('₹500.00 added to your wallet'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Add money to your wallet'), findsNothing); // the sheet closed
    expect(CountingWallet.builds, greaterThan(0));
    await unmount(tester);
  });

  testWidgets('closing the checkout puts the form back, untouched', (tester) async {
    final gateway = FakeGateway()..result = const GatewayCancelled();
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: gateway);
    await type(tester, '500');
    await tester.tap(find.text('Pay ₹512.09'));
    await settle(tester);
    expect(find.text('Pay ₹512.09'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '500');
    await unmount(tester);
  });

  testWidgets('a failed payment shows why, keeps the amount, and can be retried', (tester) async {
    final gateway = FakeGateway()..result = const GatewayFailed('Your bank declined the payment.');
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: gateway);
    await type(tester, '500');
    await tester.tap(find.text('Pay ₹512.09'));
    await settle(tester);
    expect(find.text('Your bank declined the payment.'), findsOneWidget);
    expect(find.text('Pay ₹512.09'), findsOneWidget);

    gateway.result = const GatewayPaid(proof);
    await tester.tap(find.text('Pay ₹512.09'));
    await settle(tester);
    expect(find.text('₹500.00 added to your wallet'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a refused order shows the server\'s reason', (tester) async {
    final repo = FakeRechargeRepository()
      ..createResults = [const RechargeException(code: 'TOO_MANY_RECHARGES', message: 'Please wait a few minutes before trying again')];
    await openSheet(tester, repo: repo, gateway: FakeGateway());
    await type(tester, '500');
    await tester.tap(find.text('Pay ₹512.09'));
    await settle(tester);
    expect(find.text('Please wait a few minutes before trying again'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('paid but not yet confirmed: reassures, never asks to pay again', (tester) async {
    final repo = FakeRechargeRepository()
      ..confirmResults = [const RechargeException(code: 'GATEWAY_ERROR', message: 'busy')]
      ..getResults = [const ApiException()];
    final gateway = FakeGateway();
    await openSheet(tester, repo: repo, gateway: gateway);
    await type(tester, '500');
    await tester.tap(find.text('Pay ₹512.09'));
    await settle(tester);

    expect(find.textContaining("We're still confirming your payment"), findsOneWidget);
    expect(find.textContaining("You don't need to pay again"), findsOneWidget);
    expect(find.textContaining('Pay ₹'), findsNothing);
    expect(gateway.opened, hasLength(1));
    expect(find.text('Close'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('while the checkout is open there is a progress message and no second Pay button', (tester) async {
    final gateway = FakeGateway()..hold = Completer<GatewayResult>();
    await openSheet(tester, repo: FakeRechargeRepository(), gateway: gateway);
    await type(tester, '500');
    await tester.tap(find.text('Pay ₹512.09'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Complete the payment in the payment window'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Pay ₹'), findsNothing);
    expect(gateway.opened, hasLength(1));

    gateway.hold!.complete(const GatewayPaid(proof));
    await settle(tester);
    expect(find.text('₹500.00 added to your wallet'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('with recharging switched off the sheet says so', (tester) async {
    final repo = FakeRechargeRepository()
      ..configResult = const RechargeConfig(enabled: false, minRupees: 10, maxRupees: 10000, feeBasisPoints: 236, feeFixedPaise: 0);
    await openSheet(tester, repo: repo, gateway: FakeGateway());
    expect(find.text("Adding money isn't available right now"), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await unmount(tester);
  });

  testWidgets('if the settings cannot be loaded it offers Try again', (tester) async {
    final repo = FakeRechargeRepository()..configResult = const ApiException();
    await openSheet(tester, repo: repo, gateway: FakeGateway());
    expect(find.text("Adding money isn't available right now"), findsOneWidget);
    repo.configResult = config;
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a limit that changes (server side) is respected: nothing outside it is offered', (tester) async {
    final repo = FakeRechargeRepository()
      ..configResult = const RechargeConfig(enabled: true, minRupees: 200, maxRupees: 600, feeBasisPoints: 236, feeFixedPaise: 0);
    await openSheet(tester, repo: repo, gateway: FakeGateway());
    expect(find.text('₹100'), findsNothing);
    expect(find.text('₹250'), findsOneWidget);
    expect(find.text('₹1000'), findsNothing);
    await type(tester, '150');
    expect(find.text('Enter an amount between ₹200 and ₹600'), findsOneWidget);
    await unmount(tester);
  });
}
