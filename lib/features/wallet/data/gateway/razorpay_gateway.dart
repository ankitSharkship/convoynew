import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/entities/recharge_entities.dart';
import '../../domain/repositories/recharge_repository.dart';

/// What a "payment succeeded" callback means for the payment in progress.
/// Null = ignore it: the plugin re-delivers a result that arrived while the app
/// was closed, which belongs to an *earlier* order (the server's webhook credits
/// that one) and must not be taken for this payment.
@visibleForTesting
GatewayResult? resultForSuccess({
  required String? orderId,
  required String? paymentId,
  required String? signature,
  required String expectedOrderId,
}) {
  if (orderId == null || paymentId == null || signature == null) {
    return const GatewayFailed('The payment could not be verified.');
  }
  if (orderId != expectedOrderId) return null;
  return GatewayPaid(
    PaymentProof(orderId: orderId, paymentId: paymentId, signature: signature),
  );
}

/// What a "payment failed" callback means: closing the checkout is not an error.
@visibleForTesting
GatewayResult resultForFailure({required int? code, required String? message}) =>
    code == Razorpay.PAYMENT_CANCELLED
    ? const GatewayCancelled()
    : GatewayFailed(
        (message == null || message.trim().isEmpty)
            ? 'The payment did not go through.'
            : message,
      );

/// Razorpay's checkout through the `razorpay_flutter` plugin. It also gets back
/// a result that arrived while the app was closed (the plugin re-delivers it
/// when listeners are attached), which the server's webhook backs up.
class RazorpayGateway implements RechargeGateway {
  /// A person who walks away from an open checkout must not leave the flow
  /// hanging forever.
  static const checkoutTimeout = Duration(minutes: 15);

  @override
  Future<GatewayResult> pay(RechargeCheckout checkout, {String? contact}) {
    final completer = Completer<GatewayResult>();
    final razorpay = Razorpay();

    void finish(GatewayResult result) {
      if (completer.isCompleted) return;
      completer.complete(result);
      razorpay.clear();
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      final result = resultForSuccess(
        orderId: r.orderId,
        paymentId: r.paymentId,
        signature: r.signature,
        expectedOrderId: checkout.orderId,
      );
      if (result != null) finish(result);
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      finish(resultForFailure(code: r.code, message: r.message));
    });
    // The person picked another wallet app: the checkout carries on by itself
    // and ends with a success or an error above.
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse _) {});

    try {
      razorpay.open({
        'key': checkout.keyId,
        'order_id': checkout.orderId,
        'amount': checkout.amountPaise,
        'currency': checkout.currency,
        'name': 'Bonut',
        'description': 'Wallet recharge',
        'timeout': checkoutTimeout.inSeconds,
        'retry': {'enabled': true, 'max_count': 3},
        'theme': {'color': '#F15A24'},
        if (contact != null) 'prefill': {'contact': contact},
      });
    } catch (e) {
      debugPrint('Opening the Razorpay checkout failed: $e');
      finish(const GatewayFailed('The payment screen could not be opened.'));
    }

    return completer.future.timeout(
      checkoutTimeout + const Duration(minutes: 1),
      onTimeout: () {
        finish(const GatewayCancelled());
        return const GatewayCancelled();
      },
    );
  }
}
