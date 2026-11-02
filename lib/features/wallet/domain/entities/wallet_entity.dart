class WalletEntity {
  final String availableBalance;
  final String reservedBalance;
  final String status; // "active" | "frozen"

  /// Money promised to open 1:1 call offers but not frozen yet (the part of an
  /// offer beyond its up-front hold). Absent from older backends: "0.00".
  final String callCommitments;

  /// What a new 1:1 offer (or a redeem) can actually use: available minus
  /// [callCommitments]. Null from older backends, then it equals available.
  final String? _spendableBalance;

  const WalletEntity({
    required this.availableBalance,
    required this.reservedBalance,
    required this.status,
    this.callCommitments = '0.00',
    String? spendableBalance,
  }) : _spendableBalance = spendableBalance;

  String get spendableBalance => _spendableBalance ?? availableBalance;

  bool get isFrozen => status == 'frozen';

  /// Same wallet with a new available balance (e.g. right after a credit whose
  /// response carries it); keeps the spendable figure consistent.
  WalletEntity withAvailableBalance(String available) {
    final spendable =
        (double.parse(available) - double.parse(callCommitments)).clamp(
          0,
          double.infinity,
        );
    return WalletEntity(
      availableBalance: available,
      reservedBalance: reservedBalance,
      status: status,
      callCommitments: callCommitments,
      spendableBalance: spendable.toStringAsFixed(2),
    );
  }
}

class WalletTransactionEntity {
  final String id;
  final String type; // credit | reserve_redeem | confirm_payout | release_reserve | call_hold | call_release | call_debit | call_earning
  final String amount;
  final String availableAfter;
  final String reservedAfter;
  final String referenceType; // "scratch_card" | "redeem_request" | "call_request" | "dev_credit"
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

  /// Credits, released reserves and call earnings/releases add to the user's
  /// money; redeems, payouts and call holds/payments move it out of reach —
  /// used to pick the +/- sign and icon color in the transaction list.
  bool get isCredit => const {
    'credit',
    'release_reserve',
    'call_release',
    'call_earning',
  }.contains(type);
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
