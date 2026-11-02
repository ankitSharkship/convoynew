import '../../domain/entities/recharge_entities.dart';

int _rupees(Object? value, {required bool roundUp}) {
  final parsed = double.tryParse('$value') ?? 0;
  return roundUp ? parsed.ceil() : parsed.floor();
}

/// "2.36" -> 236 (hundredths of a percent).
int _basisPoints(Object? percent) =>
    ((double.tryParse('$percent') ?? 0) * 100).round();

int _paise(Object? rupees) => ((double.tryParse('$rupees') ?? 0) * 100).round();

RechargeConfig rechargeConfigFromJson(Map<String, dynamic> json) =>
    RechargeConfig(
      enabled: json['enabled'] as bool? ?? false,
      // A limit with paise is rounded inwards, so the app never offers an amount
      // the server would refuse.
      minRupees: _rupees(json['minAmount'], roundUp: true),
      maxRupees: _rupees(json['maxAmount'], roundUp: false),
      feeBasisPoints: _basisPoints(json['feePercent']),
      feeFixedPaise: _paise(json['feeFixed']),
    );

RechargeOrder rechargeOrderFromJson(Map<String, dynamic> json) {
  final checkout = json['checkout'];
  return RechargeOrder(
    id: json['id'] as String,
    orderId: json['orderId'] as String,
    status: json['status'] as String,
    creditAmount: json['creditAmount'] as String,
    feeAmount: json['feeAmount'] as String,
    totalAmount: json['totalAmount'] as String,
    checkout: checkout is Map<String, dynamic>
        ? RechargeCheckout(
            keyId: checkout['keyId'] as String,
            orderId: checkout['orderId'] as String,
            amountPaise: (checkout['amountPaise'] as num).toInt(),
            currency: checkout['currency'] as String? ?? 'INR',
          )
        : null,
  );
}
