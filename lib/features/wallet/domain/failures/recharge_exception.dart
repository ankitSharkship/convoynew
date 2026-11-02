/// A recharge rule the server refused, with its stable `code` (docs: the
/// recharge errors in ONE_TO_ONE_CALL_API.md / services/recharge.py) and the
/// plain-language `detail` to show.
class RechargeException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const RechargeException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  /// A passing problem: asking again shortly can work.
  bool get isTemporary => code == 'PAYMENT_PENDING' || code == 'GATEWAY_ERROR';

  /// Paid, but a person has to sort it out (nothing a retry fixes).
  bool get needsReview => code == 'NEEDS_REVIEW';

  @override
  String toString() => 'RechargeException($code, $message)';
}
