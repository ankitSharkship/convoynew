import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository _repository;

  GetWalletUseCase(this._repository);

  Future<WalletEntity> execute(String userId) => _repository.getWallet(userId);
}
