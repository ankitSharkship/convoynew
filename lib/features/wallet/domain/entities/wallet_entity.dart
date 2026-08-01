class WalletEntity {
  final String availableBalance;
  final String reservedBalance;
  final String status; // "active" | "frozen"

  const WalletEntity({
    required this.availableBalance,
    required this.reservedBalance,
    required this.status,
  });

  bool get isFrozen => status == 'frozen';
}

class WalletTransactionEntity {
  final String id;
  final String type; // credit | reserve_redeem | confirm_payout | release_reserve
  final String amount;
  final String availableAfter;
  final String reservedAfter;
  final String referenceType; // "scratch_card" | "redeem_request"
  final String? referenceId;
  final String? note;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.availableAfter,
    required this.reservedAfter,
    required this.referenceType,
    this.referenceId,
    this.note,
    required this.createdAt,
  });

  /// Credits and released reserves add to the user's money; redeems and
  /// confirmed payouts move it out of reach — used to pick the +/- sign and
  /// icon color in the transaction list.
  bool get isCredit => type == 'credit' || type == 'release_reserve';
}

class RedeemRequestEntity {
  final String id;
  final String amount;
  final String upiId;
  final String status; // pending | paid | rejected
  final DateTime createdAt;

  const RedeemRequestEntity({
    required this.id,
    required this.amount,
    required this.upiId,
    required this.status,
    required this.createdAt,
  });
}
