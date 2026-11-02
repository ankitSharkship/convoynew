/// A recharge's amounts in paise (1/100 rupee), so no fraction is ever rounded
/// by the phone.
class RechargeQuote {
  /// What lands in the wallet.
  final int creditPaise;

  /// The payment gateway's fee, paid on top.
  final int feePaise;

  /// What the person pays.
  final int totalPaise;

  const RechargeQuote({
    required this.creditPaise,
    required this.feePaise,
    required this.totalPaise,
  });
}

/// Whether adding money is on, its limits, and the gateway fee (GET
/// /api/wallet/recharge/config). The fee is worked out here only to *show* what
/// the person will pay before they commit; the server's order is what is charged.
class RechargeConfig {
  final bool enabled;
  final int minRupees;
  final int maxRupees;

  /// The fee as a percentage in hundredths (2.36% is 236).
  final int feeBasisPoints;
  final int feeFixedPaise;

  const RechargeConfig({
    required this.enabled,
    required this.minRupees,
    required this.maxRupees,
    required this.feeBasisPoints,
    required this.feeFixedPaise,
  });

  bool allows(int rupees) => rupees >= minRupees && rupees <= maxRupees;

  /// The same sum the server does (services/recharge.py `compute_fee`): the fee
  /// is grossed up because the gateway takes its percentage of the *whole*
  /// payment, and rounded up to the paisa.
  RechargeQuote quote(int creditRupees) {
    final creditPaise = creditRupees * 100;
    final base = creditPaise + feeFixedPaise;
    final keep = 10000 - feeBasisPoints;
    final total = (base * 10000 + keep - 1) ~/ keep; // ceiling division
    return RechargeQuote(
      creditPaise: creditPaise,
      feePaise: total - creditPaise,
      totalPaise: total,
    );
  }
}

/// What Razorpay's checkout needs to take the payment.
class RechargeCheckout {
  final String keyId;
  final String orderId;
  final int amountPaise;
  final String currency;

  const RechargeCheckout({
    required this.keyId,
    required this.orderId,
    required this.amountPaise,
    required this.currency,
  });
}

class RechargeStatus {
  static const created = 'created';
  static const paid = 'paid';
  static const review = 'review';
}

/// One recharge as the server holds it. The amounts are rupee strings ("512.09").
class RechargeOrder {
  final String id;
  final String orderId;
  final String status;
  final String creditAmount;
  final String feeAmount;
  final String totalAmount;
  final RechargeCheckout? checkout;

  const RechargeOrder({
    required this.id,
    required this.orderId,
    required this.status,
    required this.creditAmount,
    required this.feeAmount,
    required this.totalAmount,
    this.checkout,
  });

  bool get isPaid => status == RechargeStatus.paid;
}

/// What Razorpay's checkout gives back after a successful payment.
class PaymentProof {
  final String orderId;
  final String paymentId;
  final String signature;

  const PaymentProof({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });
}

/// How the checkout ended.
sealed class GatewayResult {
  const GatewayResult();
}

class GatewayPaid extends GatewayResult {
  final PaymentProof proof;
  const GatewayPaid(this.proof);
}

/// The person closed the checkout without paying: not an error.
class GatewayCancelled extends GatewayResult {
  const GatewayCancelled();
}

class GatewayFailed extends GatewayResult {
  final String message;
  const GatewayFailed(this.message);
}
