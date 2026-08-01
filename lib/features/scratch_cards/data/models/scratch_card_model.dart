import '../../domain/entities/scratch_card_entity.dart';

ScratchCardStatus _parseStatus(String value) => ScratchCardStatus.values.firstWhere(
  (v) => v.name == value,
  orElse: () => ScratchCardStatus.expired,
);

class ScratchCardModel extends ScratchCardEntity {
  const ScratchCardModel({
    required super.id,
    required super.status,
    required super.earnedAt,
    required super.expiresAt,
    super.scratchedAt,
    super.rewardRupees,
  });

  factory ScratchCardModel.fromJson(Map<String, dynamic> json) => ScratchCardModel(
    id: json['id'] as String,
    status: _parseStatus(json['status'] as String),
    earnedAt: DateTime.parse(json['earnedAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    scratchedAt: json['scratchedAt'] != null
        ? DateTime.parse(json['scratchedAt'] as String)
        : null,
    rewardRupees: json['rewardRupees'] as String?,
  );
}

class ScratchResultModel extends ScratchResultEntity {
  const ScratchResultModel({
    required super.cardId,
    required super.rewardPaise,
    required super.rewardRupees,
    required super.walletAvailableBalance,
  });

  // Flat top-level fields — unlike wallet's redeem response, this one is
  // not nested under a wrapper key.
  factory ScratchResultModel.fromJson(Map<String, dynamic> json) => ScratchResultModel(
    cardId: json['cardId'] as String,
    rewardPaise: json['rewardPaise'] as int,
    rewardRupees: json['rewardRupees'] as String,
    walletAvailableBalance: json['walletAvailableBalance'] as String,
  );
}
