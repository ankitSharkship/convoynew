import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getWallet(String userId);

  Future<List<WalletTransactionEntity>> getTransactions(String userId);

  Future<RedeemRequestEntity> redeem({
    required String userId,
    required String upiId,
    required String idempotencyKey,
  });
}
