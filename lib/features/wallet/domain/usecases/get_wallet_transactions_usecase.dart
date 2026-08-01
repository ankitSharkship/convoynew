import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletTransactionsUseCase {
  final WalletRepository _repository;

  GetWalletTransactionsUseCase(this._repository);

  Future<List<WalletTransactionEntity>> execute(String userId) =>
      _repository.getTransactions(userId);
}
