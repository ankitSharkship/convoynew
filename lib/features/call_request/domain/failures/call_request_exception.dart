/// A rule of the 1:1 call flow the server refused, with the stable `code` the
/// app switches on (docs/ONE_TO_ONE_CALL_API.md "Errors"). [message] is the
/// server's plain-language sentence, safe to show as is.
class CallRequestException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  /// The numbers/ids some codes carry (`shortfall`, `requestId`, ...).
  final Map<String, dynamic> extra;

  const CallRequestException({
    required this.code,
    required this.message,
    this.statusCode,
    this.extra = const {},
  });

  /// The wallet can't cover the offer: show the recharge prompt for [shortfall].
  bool get isInsufficientBalance => code == 'INSUFFICIENT_BALANCE';

  /// Rupees missing from the wallet (INSUFFICIENT_BALANCE), as a decimal string.
  String? get shortfall => extra['shortfall'] as String?;

  /// There already is an open request with this driver (ALREADY_OPEN).
  bool get isAlreadyOpen => code == 'ALREADY_OPEN';

  /// The id of that existing request, to open it instead.
  String? get existingRequestId => extra['requestId'] as String?;

  @override
  String toString() => message;
}
