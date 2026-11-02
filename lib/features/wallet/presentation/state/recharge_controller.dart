import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/recharge_remote_datasource.dart';
import '../../data/gateway/razorpay_gateway.dart';
import '../../data/repositories/recharge_repository_impl.dart';
import '../../domain/entities/recharge_entities.dart';
import '../../domain/failures/recharge_exception.dart';
import '../../domain/repositories/recharge_repository.dart';
import 'wallet_notifier.dart';

// Plain (hand-written) providers: they are the seams the tests replace (the
// repository, Razorpay's checkout and the waiting times).

final rechargeRepositoryProvider = Provider<RechargeRepository>(
  (ref) => RechargeRepositoryImpl(
    RechargeRemoteDataSourceImpl(ref.watch(dioProvider)),
    () => ref.read(tokenStorageProvider).getUserId(),
  ),
);

final rechargeGatewayProvider = Provider<RechargeGateway>(
  (ref) => RazorpayGateway(),
);

/// Whether adding money is on, its limits and the gateway fee.
final rechargeConfigProvider = FutureProvider.autoDispose<RechargeConfig>(
  (ref) => ref.watch(rechargeRepositoryProvider).getConfig(),
);

/// How long the flow waits before asking the server again about a payment.
class RechargeTiming {
  /// Waits before each attempt to confirm a payment (the first is at once).
  final List<Duration> confirmDelays;

  /// Then, if still unconfirmed, how often to look at the order and how many times.
  final Duration pollEvery;
  final int pollAttempts;

  const RechargeTiming({
    this.confirmDelays = const [
      Duration.zero,
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 12),
    ],
    this.pollEvery = const Duration(seconds: 6),
    this.pollAttempts = 20,
  });
}

final rechargeTimingProvider = Provider<RechargeTiming>(
  (ref) => const RechargeTiming(),
);

enum RechargePhase {
  /// Nothing under way (also after the person closed the checkout).
  idle,

  /// The server is making the order.
  creating,

  /// Razorpay's checkout is open.
  paying,

  /// Paid; the server is checking the payment and crediting the wallet.
  confirming,

  /// The money is in the wallet.
  done,

  /// Paid, but the credit isn't confirmed yet (or a person has to look at it).
  /// The person must NOT be asked to pay again.
  pending,

  /// Nothing was charged; see [RechargeState.message].
  failed,
}

class RechargeState {
  final RechargePhase phase;
  final RechargeOrder? order;
  final String? message;

  const RechargeState({
    this.phase = RechargePhase.idle,
    this.order,
    this.message,
  });

  bool get busy =>
      phase == RechargePhase.creating ||
      phase == RechargePhase.paying ||
      phase == RechargePhase.confirming;
}

final rechargeControllerProvider =
    NotifierProvider.autoDispose<RechargeController, RechargeState>(
      RechargeController.new,
    );

/// One attempt to add money: make the order, take the payment in Razorpay's
/// checkout, then have the server confirm it and credit the wallet. After a
/// payment the person is never asked to pay again for the same money: if the
/// confirmation can't be completed straight away it is retried, then watched,
/// and the server's webhook finishes it even if the app is gone.
class RechargeController extends AutoDisposeNotifier<RechargeState> {
  bool _disposed = false;
  bool _busy = false;

  /// Held from the moment money may be on its way until the outcome is known, so
  /// that closing the sheet in the middle cannot abandon a payment halfway.
  KeepAliveLink? _inFlight;

  late RechargeRepository _repo;
  late RechargeGateway _gateway;
  late RechargeTiming _timing;

  @override
  RechargeState build() {
    _disposed = false;
    _repo = ref.read(rechargeRepositoryProvider);
    _gateway = ref.read(rechargeGatewayProvider);
    _timing = ref.read(rechargeTimingProvider);
    ref.onDispose(() => _disposed = true);
    return const RechargeState();
  }

  /// Back to the start (after a failure, to try again).
  void reset() {
    if (!_busy) state = const RechargeState();
  }

  /// [rupees] is what should land in the wallet; the fee is added on top.
  Future<void> start(int rupees) async {
    if (_busy) return;
    _busy = true;
    _inFlight ??= ref.keepAlive();
    try {
      state = const RechargeState(phase: RechargePhase.creating);
      final RechargeOrder order;
      try {
        order = await _repo.create(rupees);
      } catch (e) {
        _fail(e);
        return;
      }
      if (_disposed) return;
      final checkout = order.checkout;
      if (checkout == null) {
        state = const RechargeState(
          phase: RechargePhase.failed,
          message: 'Something went wrong. Please try again.',
        );
        return;
      }

      state = RechargeState(phase: RechargePhase.paying, order: order);
      final result = await _gateway.pay(checkout);
      if (_disposed) return;
      switch (result) {
        case GatewayCancelled():
          state = const RechargeState();
        case GatewayFailed(:final message):
          state = RechargeState(
            phase: RechargePhase.failed,
            order: order,
            message: message,
          );
        case GatewayPaid(:final proof):
          await _confirm(order, proof);
      }
    } finally {
      _busy = false;
      // Still waiting for the server's word on a payment: stay alive (the watch
      // lets go when it is over). Otherwise nothing is in flight any more.
      if (state.phase != RechargePhase.pending) _release();
    }
  }

  void _release() {
    _inFlight?.close();
    _inFlight = null;
  }

  Future<void> _confirm(RechargeOrder order, PaymentProof proof) async {
    state = RechargeState(phase: RechargePhase.confirming, order: order);
    for (final delay in _timing.confirmDelays) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (_disposed) return;
      try {
        _done(await _repo.confirm(proof));
        return;
      } on RechargeException catch (e) {
        if (e.needsReview) {
          state = RechargeState(
            phase: RechargePhase.pending,
            order: order,
            message: e.message,
          );
          return;
        }
        if (!e.isTemporary) {
          state = RechargeState(
            phase: RechargePhase.failed,
            order: order,
            message: e.message,
          );
          return;
        }
        // temporary: try again after the next wait
      } on ApiException {
        // no connection: try again after the next wait
      }
    }
    // Paid, but still not confirmed. Never ask for the money again: watch the
    // order (the server's webhook may finish it first).
    state = RechargeState(phase: RechargePhase.pending, order: order);
    unawaited(_watch(order));
  }

  Future<void> _watch(RechargeOrder order) async {
    try {
      for (var i = 0; i < _timing.pollAttempts; i++) {
        await Future<void>.delayed(_timing.pollEvery);
        if (_disposed) return;
        try {
          final latest = await _repo.get(order.orderId);
          if (_disposed) return;
          if (latest.isPaid) {
            _done(latest);
            return;
          }
        } catch (_) {
          // keep watching
        }
      }
    } finally {
      _release();
    }
  }

  void _done(RechargeOrder order) {
    ref.invalidate(walletNotifierProvider); // the new balance
    state = RechargeState(phase: RechargePhase.done, order: order);
  }

  void _fail(Object error) {
    if (_disposed) return;
    state = RechargeState(
      phase: RechargePhase.failed,
      message: error is RechargeException
          ? error.message
          : ApiException.messageFor(error),
    );
  }
}
