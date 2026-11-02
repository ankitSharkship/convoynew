import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remote;

  WalletRepositoryImpl(this._remote);

  @override
  Future<WalletEntity> getWallet(String userId) => _remote.getWallet(userId);

  @override
  Future<List<WalletTransactionEntity>> getTransactions(String userId) =>
      _remote.getTransactions(userId);

  @override
  Future<RedeemRequestEntity> redeem({
    required String userId,
    required String upiId,
    required String idempotencyKey,
  }) => _remote.redeem(
    userId: userId,
    upiId: upiId,
    idempotencyKey: idempotencyKey,
  );

  @override
  Future<void> devCredit({
    required String userId,
    required int amount,
    required String idempotencyKey,
  }) => _remote.devCredit(
    userId: userId,
    amount: amount,
    idempotencyKey: idempotencyKey,
  );
}
