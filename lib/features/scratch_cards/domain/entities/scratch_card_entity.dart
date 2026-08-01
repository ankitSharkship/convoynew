enum ScratchCardStatus { unscratched, scratched, expired }

class ScratchCardEntity {
  final String id;
  final ScratchCardStatus status;
  final DateTime earnedAt;
  final DateTime expiresAt;
  final DateTime? scratchedAt;

  /// Precomputed and attached at issuance — present even for
  /// still-`unscratched` cards. The scratch endpoint no longer decides this
  /// number, only commits it; the UI must still keep it hidden behind the
  /// scratch-off foil until the user actually reveals it, rather than
  /// surfacing it anywhere before that (e.g. in a card list preview).
  final String? rewardRupees;

  const ScratchCardEntity({
    required this.id,
    required this.status,
    required this.earnedAt,
    required this.expiresAt,
    this.scratchedAt,
    this.rewardRupees,
  });

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
}

class ScratchResultEntity {
  final String cardId;
  final int rewardPaise;
  final String rewardRupees;

  /// Balance *after* this credit — lets the wallet UI update immediately
  /// without a second GET /wallet call.
  final String walletAvailableBalance;

  const ScratchResultEntity({
    required this.cardId,
    required this.rewardPaise,
    required this.rewardRupees,
    required this.walletAvailableBalance,
  });
}
