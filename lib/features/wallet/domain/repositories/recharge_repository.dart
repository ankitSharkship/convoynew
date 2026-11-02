import '../entities/recharge_entities.dart';

abstract class RechargeRepository {
  Future<RechargeConfig> getConfig();

  /// Makes the order for [amountRupees] to land in the wallet (the fee is added
  /// by the server). Throws [RechargeException] for a rule (limits, frozen
  /// wallet ...) and ApiException when there is no connection.
  Future<RechargeOrder> create(int amountRupees);

  /// Tells the server the payment happened; it checks with Razorpay and credits
  /// the wallet (once). Safe to repeat.
  Future<RechargeOrder> confirm(PaymentProof proof);

  Future<RechargeOrder> get(String orderId);
}

/// Razorpay's checkout, as the recharge flow sees it.
abstract class RechargeGateway {
  /// Opens the checkout and completes when the person has paid, closed it, or it
  /// failed. Never throws.
  Future<GatewayResult> pay(RechargeCheckout checkout, {String? contact});
}
