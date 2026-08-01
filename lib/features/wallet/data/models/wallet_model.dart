import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.availableBalance,
    required super.reservedBalance,
    required super.status,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    availableBalance: json['availableBalance'] as String,
    reservedBalance: json['reservedBalance'] as String,
    status: json['status'] as String,
  );
}

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.availableAfter,
    required super.reservedAfter,
    required super.referenceType,
    super.referenceId,
    super.note,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: json['id'] as String,
        type: json['type'] as String,
        amount: json['amount'] as String,
        availableAfter: json['availableAfter'] as String,
        reservedAfter: json['reservedAfter'] as String,
        referenceType: json['referenceType'] as String,
        referenceId: json['referenceId'] as String?,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class RedeemRequestModel extends RedeemRequestEntity {
  const RedeemRequestModel({
    required super.id,
    required super.amount,
    required super.upiId,
    required super.status,
    required super.createdAt,
  });

  factory RedeemRequestModel.fromJson(Map<String, dynamic> json) =>
      RedeemRequestModel(
        id: json['id'] as String,
        amount: json['amount'] as String,
        upiId: json['upiId'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
