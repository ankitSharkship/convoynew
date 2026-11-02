import 'dart:convert';
import 'dart:typed_data';

import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/wallet/data/datasources/recharge_remote_datasource.dart';
import 'package:convoynew/features/wallet/data/gateway/razorpay_gateway.dart';
import 'package:convoynew/features/wallet/data/models/recharge_models.dart';
import 'package:convoynew/features/wallet/domain/entities/recharge_entities.dart';
import 'package:convoynew/features/wallet/domain/failures/recharge_exception.dart';
import 'package:convoynew/features/wallet/presentation/state/recharge_controller.dart';
import 'package:convoynew/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recharge_support.dart';

class _Reply implements HttpClientAdapter {
  final int status;
  final Object body;
  RequestOptions? last;

  _Reply(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

RechargeRemoteDataSourceImpl source(HttpClientAdapter reply) => RechargeRemoteDataSourceImpl(
  Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = reply,
);

Map<String, dynamic> orderJson({String status = 'created', bool checkout = true}) => {
  'id': 'rc1',
  'orderId': 'order_1',
  'status': status,
  'creditAmount': '500.00',
  'feeAmount': '12.09',
  'totalAmount': '512.09',
  'paidAt': null,
  if (checkout)
    'checkout': {
      'keyId': 'rzp_test_key',
      'orderId': 'order_1',
      'amountPaise': 51209,
      'currency': 'INR',
    },
};

late FakeRechargeRepository repo;
late FakeGateway gateway;
late ProviderContainer container;
late ProviderSubscription<RechargeState> sub;
final seen = <RechargePhase>[];
RechargeState get state => sub.read();

void main() {
  group('the fee shown before paying', () {
    // The very numbers the backend's tests expect (tests/test_recharge.py):
    // the phone and the server must agree to the paisa.
    for (final row in [
      (100, 242, 10242),
      (500, 1209, 51209),
      (10, 25, 1025),
      (10000, 24171, 1024171),
    ]) {
      test('₹${row.$1} to the wallet: fee ${row.$2} paise, pays ${row.$3} paise', () {
        final q = config.quote(row.$1);
        expect((q.creditPaise, q.feePaise, q.totalPaise), (row.$1 * 100, row.$2, row.$3));
      });
    }

    test('what is left after the gateway\'s cut is never less than what was asked', () {
      for (var credit = 10; credit <= 10000; credit += 37) {
        final q = config.quote(credit);
        final afterCut = q.totalPaise - (q.totalPaise * 236 / 10000);
        expect(afterCut, greaterThanOrEqualTo(q.creditPaise - 0.5), reason: '₹$credit');
        expect(q.totalPaise, q.creditPaise + q.feePaise);
      }
    });

    test('no fee configured: no fee', () {
      const free = RechargeConfig(enabled: true, minRupees: 10, maxRupees: 100, feeBasisPoints: 0, feeFixedPaise: 0);
      final q = free.quote(250);
      expect((q.feePaise, q.totalPaise), (0, 25000));
    });

    test('a fixed fee is added too', () {
      const fixed = RechargeConfig(enabled: true, minRupees: 10, maxRupees: 100, feeBasisPoints: 0, feeFixedPaise: 300);
      expect(fixed.quote(100).totalPaise, 10300);
    });

    test('limits are inclusive', () {
      expect(config.allows(9), isFalse);
      expect(config.allows(10), isTrue);
      expect(config.allows(10000), isTrue);
      expect(config.allows(10001), isFalse);
    });
  });

  group('reading the server\'s answers', () {
    test('the config: limits rounded inwards, the fee in hundredths of a percent', () {
      final c = rechargeConfigFromJson({
        'enabled': true,
        'minAmount': '10.50',
        'maxAmount': '9999.99',
        'feePercent': '2.36',
        'feeFixed': '3.00',
      });
      expect((c.minRupees, c.maxRupees, c.feeBasisPoints, c.feeFixedPaise), (11, 9999, 236, 300));
      expect(c.enabled, isTrue);
    });

    test('missing fields mean "off", not a crash', () {
      final c = rechargeConfigFromJson({});
      expect(c.enabled, isFalse);
    });

    test('an order with its checkout, and one without', () {
      final o = rechargeOrderFromJson(orderJson());
      expect(o.checkout!.amountPaise, 51209);
      expect(o.checkout!.keyId, 'rzp_test_key');
      expect(o.isPaid, isFalse);
      expect(rechargeOrderFromJson(orderJson(status: 'paid', checkout: false)).checkout, isNull);
      expect(rechargeOrderFromJson(orderJson(status: 'paid', checkout: false)).isPaid, isTrue);
    });
  });

  group('what the Razorpay plugin reports', () {
    test('a success for this order becomes the proof to confirm', () {
      final r = resultForSuccess(orderId: 'order_1', paymentId: 'pay_1', signature: 'sig', expectedOrderId: 'order_1');
      expect(r, isA<GatewayPaid>());
      final proofGot = (r! as GatewayPaid).proof;
      expect((proofGot.orderId, proofGot.paymentId, proofGot.signature), ('order_1', 'pay_1', 'sig'));
    });

    test('a result left over from an EARLIER order is ignored, not taken for this payment', () {
      expect(
        resultForSuccess(orderId: 'order_OLD', paymentId: 'pay_old', signature: 'sig', expectedOrderId: 'order_1'),
        isNull,
      );
    });

    test('a success with pieces missing is a failure, never a proof', () {
      for (final r in [
        resultForSuccess(orderId: null, paymentId: 'p', signature: 's', expectedOrderId: 'o'),
        resultForSuccess(orderId: 'o', paymentId: null, signature: 's', expectedOrderId: 'o'),
        resultForSuccess(orderId: 'o', paymentId: 'p', signature: null, expectedOrderId: 'o'),
      ]) {
        expect(r, isA<GatewayFailed>());
      }
    });

    test('closing the checkout is a cancel; anything else is a failure with words', () {
      expect(resultForFailure(code: 2, message: 'Payment Cancelled'), isA<GatewayCancelled>());
      final bank = resultForFailure(code: 0, message: 'Your bank declined the payment.') as GatewayFailed;
      expect(bank.message, 'Your bank declined the payment.');
      expect((resultForFailure(code: 0, message: null) as GatewayFailed).message, isNotEmpty);
      expect((resultForFailure(code: 100, message: '  ') as GatewayFailed).message, isNotEmpty);
    });
  });

  group('the datasource', () {
    test('config is read from /wallet/recharge/config', () async {
      final reply = _Reply(200, {'success': true, 'enabled': true, 'minAmount': '10.00', 'maxAmount': '10000.00', 'feePercent': '2.36', 'feeFixed': '0.00'});
      final c = await source(reply).getConfig();
      expect(reply.last!.uri.path, '/api/wallet/recharge/config');
      expect(c.maxRupees, 10000);
    });

    test('creating sends only the amount wanted in the wallet', () async {
      final reply = _Reply(201, {'success': true, 'recharge': orderJson()});
      final o = await source(reply).create('u1', 500);
      expect(reply.last!.uri.path, '/api/wallet/u1/recharges');
      expect(reply.last!.data, {'amount': '500'});
      expect(o.checkout, isNotNull);
    });

    test('confirming sends exactly what the checkout returned', () async {
      final reply = _Reply(200, {'success': true, 'recharge': orderJson(status: 'paid')});
      final o = await source(reply).confirm('u1', proof);
      expect(reply.last!.uri.path, '/api/wallet/u1/recharges/confirm');
      expect(reply.last!.data, {'orderId': 'order_1', 'paymentId': 'pay_1', 'signature': 'sig'});
      expect(o.isPaid, isTrue);
    });

    test('an order\'s status is read from its own path', () async {
      final reply = _Reply(200, {'success': true, 'recharge': orderJson(status: 'paid')});
      await source(reply).get('u1', 'order_1');
      expect(reply.last!.uri.path, '/api/wallet/u1/recharges/order_1');
    });

    test('a refused rule becomes a RechargeException the screen can show', () async {
      final reply = _Reply(400, {'detail': 'You can add between ₹10.00 and ₹10000.00 at a time', 'code': 'INVALID_AMOUNT'});
      await expectLater(
        source(reply).create('u1', 5),
        throwsA(isA<RechargeException>().having((e) => e.code, 'code', 'INVALID_AMOUNT').having((e) => e.message, 'message', contains('₹10.00'))),
      );
    });

    test('anything else (a crash on the server) is an ordinary ApiException', () async {
      await expectLater(source(_Reply(500, {'oops': 1})).create('u1', 500), throwsA(isA<ApiException>()));
    });
  });

  group('RechargeException', () {
    test('which problems are worth asking about again', () {
      RechargeException of(String code) => RechargeException(code: code, message: 'm');
      expect(of('PAYMENT_PENDING').isTemporary, isTrue);
      expect(of('GATEWAY_ERROR').isTemporary, isTrue);
      expect(of('INVALID_SIGNATURE').isTemporary, isFalse);
      expect(of('PAYMENT_FAILED').isTemporary, isFalse);
      expect(of('NEEDS_REVIEW').needsReview, isTrue);
      expect(of('NEEDS_REVIEW').isTemporary, isFalse);
    });
  });

  group('the payment flow', () {
    void boot({RechargeTiming timing = fastTiming}) {
      CountingWallet.builds = 0;
      seen.clear();
      container = ProviderContainer(overrides: rechargeOverrides(repo, gateway, timing: timing));
      sub = container.listen(rechargeControllerProvider, (_, next) {
        if (seen.isEmpty || seen.last != next.phase) seen.add(next.phase);
      });
      // keep the wallet alive so an invalidation is visible as a rebuild
      container.listen(walletNotifierProvider, (_, _) {});
    }

    RechargeController ctl() => container.read(rechargeControllerProvider.notifier);

    setUp(() {
      repo = FakeRechargeRepository();
      gateway = FakeGateway();
    });

    Future<void> run(WidgetTester tester, Future<void> Function() action) async {
      var done = false;
      action().whenComplete(() => done = true);
      for (var i = 0; i < 60 && !done; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(done, isTrue, reason: 'the flow never finished');
    }

    Future<void> close(WidgetTester tester) async {
      sub.close();
      container.dispose();
      await tester.pump(Duration.zero);
    }

    testWidgets('pay, confirm, done: the wallet is refreshed and the checkout got the server\'s numbers', (tester) async {
      boot();
      await container.read(walletNotifierProvider.future);
      final before = CountingWallet.builds;
      await run(tester, () => ctl().start(500));

      expect(seen, [RechargePhase.creating, RechargePhase.paying, RechargePhase.confirming, RechargePhase.done]);
      expect(repo.created, [500]);
      expect(gateway.opened.single.amountPaise, 51209);
      expect(repo.confirmed.single.paymentId, 'pay_1');
      expect(state.order!.isPaid, isTrue);
      await tester.pump();
      expect(CountingWallet.builds, greaterThan(before), reason: 'the new balance must be fetched');
      await close(tester);
    });

    testWidgets('closing the checkout without paying is not an error and charges nothing', (tester) async {
      gateway.result = const GatewayCancelled();
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.idle);
      expect(repo.confirmed, isEmpty);
      await close(tester);
    });

    testWidgets('a failed payment says so and can be tried again', (tester) async {
      gateway.result = const GatewayFailed('Your bank declined the payment.');
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.failed);
      expect(state.message, 'Your bank declined the payment.');
      expect(repo.confirmed, isEmpty);

      ctl().reset();
      expect(state.phase, RechargePhase.idle);
      gateway.result = const GatewayPaid(proof);
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.done);
      await close(tester);
    });

    testWidgets('a refused order shows the server\'s reason and never opens the checkout', (tester) async {
      repo.createResults = [const RechargeException(code: 'WALLET_FROZEN', message: 'Your wallet is frozen, contact support')];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.failed);
      expect(state.message, 'Your wallet is frozen, contact support');
      expect(gateway.opened, isEmpty);
      await close(tester);
    });

    testWidgets('no connection while making the order is a failure with a message', (tester) async {
      repo.createResults = [const ApiException()];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.failed);
      expect(state.message, isNotEmpty);
      expect(gateway.opened, isEmpty);
      await close(tester);
    });

    testWidgets('an order without checkout details is a failure, not a hang', (tester) async {
      repo.createResults = [order(withCheckout: false)];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.failed);
      expect(gateway.opened, isEmpty);
      await close(tester);
    });

    testWidgets('a temporary problem confirming is retried until it works', (tester) async {
      repo.confirmResults = [
        const RechargeException(code: 'GATEWAY_ERROR', message: 'busy'),
        const RechargeException(code: 'PAYMENT_PENDING', message: 'processing'),
        order(status: 'paid'),
      ];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.done);
      expect(repo.confirmed, hasLength(3));
      expect(gateway.opened, hasLength(1), reason: 'never asked to pay again');
      await close(tester);
    });

    testWidgets('losing the connection right after paying is retried too', (tester) async {
      repo.confirmResults = [const ApiException(), const ApiException(), order(status: 'paid')];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.done);
      await close(tester);
    });

    testWidgets('still unconfirmed after the retries: "pending", never "pay again", then it finishes when the server says paid', (tester) async {
      repo.confirmResults = [const RechargeException(code: 'GATEWAY_ERROR', message: 'busy')];
      repo.getResults = [order(status: 'created'), order(status: 'created'), order(status: 'paid')];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.pending);
      expect(gateway.opened, hasLength(1));

      // the watch keeps looking at the order (the webhook may complete it)
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(state.phase, RechargePhase.done);
      expect(repo.getCalls, 3);
      await close(tester);
    });

    testWidgets('if the watch never sees it paid it stops looking, and stays pending', (tester) async {
      repo.confirmResults = [const RechargeException(code: 'GATEWAY_ERROR', message: 'busy')];
      repo.getResults = [const ApiException()];
      boot();
      await run(tester, () => ctl().start(500));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(state.phase, RechargePhase.pending);
      expect(repo.getCalls, fastTiming.pollAttempts, reason: 'bounded: no endless polling');
      await close(tester);
    });

    testWidgets('"needs review" is passed on as it is and never retried', (tester) async {
      repo.confirmResults = [const RechargeException(code: 'NEEDS_REVIEW', message: 'Our team will sort it out.')];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.pending);
      expect(state.message, 'Our team will sort it out.');
      expect(repo.confirmed, hasLength(1));
      await close(tester);
    });

    testWidgets('a payment the server will not accept is a failure with its reason', (tester) async {
      repo.confirmResults = [const RechargeException(code: 'INVALID_SIGNATURE', message: "We couldn't verify this payment")];
      boot();
      await run(tester, () => ctl().start(500));
      expect(state.phase, RechargePhase.failed);
      expect(state.message, "We couldn't verify this payment");
      expect(repo.confirmed, hasLength(1));
      await close(tester);
    });

    testWidgets('starting twice at once opens one checkout', (tester) async {
      boot();
      var done = 0;
      ctl().start(500).whenComplete(() => done++);
      ctl().start(500).whenComplete(() => done++);
      for (var i = 0; i < 60 && done < 2; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(gateway.opened, hasLength(1));
      expect(repo.created, hasLength(1));
      await close(tester);
    });

    testWidgets('closing the SHEET in the middle does not abandon a payment: it is still confirmed and the wallet refreshed', (tester) async {
      repo.confirmResults = [
        const RechargeException(code: 'GATEWAY_ERROR', message: 'busy'),
        const RechargeException(code: 'GATEWAY_ERROR', message: 'busy'),
        order(status: 'paid'),
      ];
      boot();
      await container.read(walletNotifierProvider.future);
      final before = CountingWallet.builds;
      var done = false;
      ctl().start(500).whenComplete(() => done = true);
      await tester.pump();
      sub.close(); // the person swiped the sheet away: nothing is listening any more
      for (var i = 0; i < 20 && !done; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();

      expect(done, isTrue);
      expect(repo.confirmed, hasLength(3), reason: 'it kept going until the server confirmed');
      expect(CountingWallet.builds, greaterThan(before));
      container.dispose();
      await tester.pump(Duration.zero);
    });

    testWidgets('once nothing is in flight, closing the sheet does tear the flow down', (tester) async {
      boot();
      await run(tester, () => ctl().start(500));
      sub.close();
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      expect(container.exists(rechargeControllerProvider), isFalse);
      container.dispose();
    });

    testWidgets('closing the sheet mid-way stops the flow quietly', (tester) async {
      repo.confirmResults = [const RechargeException(code: 'GATEWAY_ERROR', message: 'busy')];
      boot();
      var done = false;
      ctl().start(500).whenComplete(() => done = true);
      await tester.pump();
      await close(tester); // the person closed the sheet while it was confirming
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(done, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
