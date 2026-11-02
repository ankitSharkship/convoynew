import 'dart:async';

import 'package:convoynew/features/wallet/domain/entities/recharge_entities.dart';
import 'package:convoynew/features/wallet/domain/repositories/recharge_repository.dart';
import 'package:convoynew/features/wallet/presentation/state/recharge_controller.dart';
import 'package:convoynew/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:convoynew/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Razorpay 2.36% as the backend sends it.
const config = RechargeConfig(
  enabled: true,
  minRupees: 10,
  maxRupees: 10000,
  feeBasisPoints: 236,
  feeFixedPaise: 0,
);

RechargeOrder order({
  String status = 'created',
  String credit = '500.00',
  String fee = '12.09',
  String total = '512.09',
  bool withCheckout = true,
}) => RechargeOrder(
  id: 'rc1',
  orderId: 'order_1',
  status: status,
  creditAmount: credit,
  feeAmount: fee,
  totalAmount: total,
  checkout: withCheckout
      ? const RechargeCheckout(
          keyId: 'rzp_test_key',
          orderId: 'order_1',
          amountPaise: 51209,
          currency: 'INR',
        )
      : null,
);

const proof = PaymentProof(
  orderId: 'order_1',
  paymentId: 'pay_1',
  signature: 'sig',
);

/// Answers from scripts: each list is consumed in order, the last item repeats.
/// An item that is an [Exception]/[Error] is thrown.
class FakeRechargeRepository implements RechargeRepository {
  Object configResult = config;
  List<Object> createResults = [order()];
  List<Object> confirmResults = [order(status: 'paid')];
  List<Object> getResults = [order(status: 'created')];

  int configCalls = 0;
  final List<int> created = [];
  final List<PaymentProof> confirmed = [];
  int getCalls = 0;

  static Object _next(List<Object> list, int index) =>
      list[index < list.length ? index : list.length - 1];

  @override
  Future<RechargeConfig> getConfig() async {
    configCalls++;
    final r = configResult;
    if (r is RechargeConfig) return r;
    throw r;
  }

  @override
  Future<RechargeOrder> create(int amountRupees) async {
    final r = _next(createResults, created.length);
    created.add(amountRupees);
    if (r is RechargeOrder) return r;
    throw r;
  }

  @override
  Future<RechargeOrder> confirm(PaymentProof p) async {
    final r = _next(confirmResults, confirmed.length);
    confirmed.add(p);
    if (r is RechargeOrder) return r;
    throw r;
  }

  @override
  Future<RechargeOrder> get(String orderId) async {
    final r = _next(getResults, getCalls++);
    if (r is RechargeOrder) return r;
    throw r;
  }
}

class FakeGateway implements RechargeGateway {
  GatewayResult result = const GatewayPaid(proof);
  final List<RechargeCheckout> opened = [];

  /// When set, the checkout stays open until the test completes it.
  Completer<GatewayResult>? hold;

  @override
  Future<GatewayResult> pay(RechargeCheckout checkout, {String? contact}) async {
    opened.add(checkout);
    final pending = hold;
    return pending == null ? result : pending.future;
  }
}

/// Counts how many times the wallet was (re)loaded: a recharge must refresh it.
class CountingWallet extends WalletNotifier {
  static int builds = 0;

  @override
  Future<WalletData> build() async {
    builds++;
    return const WalletData(
      wallet: WalletEntity(
        availableBalance: '0.00',
        reservedBalance: '0.00',
        status: 'active',
      ),
      transactions: [],
    );
  }
}

const fastTiming = RechargeTiming(
  confirmDelays: [Duration.zero, Duration(seconds: 1), Duration(seconds: 1)],
  pollEvery: Duration(seconds: 1),
  pollAttempts: 3,
);

List<Override> rechargeOverrides(
  FakeRechargeRepository repo,
  FakeGateway gateway, {
  RechargeTiming timing = fastTiming,
}) => [
  rechargeRepositoryProvider.overrideWithValue(repo),
  rechargeGatewayProvider.overrideWithValue(gateway),
  rechargeTimingProvider.overrideWithValue(timing),
  walletNotifierProvider.overrideWith(CountingWallet.new),
];
