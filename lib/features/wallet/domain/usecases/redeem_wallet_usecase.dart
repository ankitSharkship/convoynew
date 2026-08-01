import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class RedeemWalletUseCase {
  final WalletRepository _repository;

  RedeemWalletUseCase(this._repository);

  Future<RedeemRequestEntity> execute({
    required String userId,
    required String upiId,
    required String idempotencyKey,
  }) => _repository.redeem(
    userId: userId,
    upiId: upiId,
    idempotencyKey: idempotencyKey,
  );
}
