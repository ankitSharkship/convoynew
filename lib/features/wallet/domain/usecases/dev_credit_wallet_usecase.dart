import '../repositories/wallet_repository.dart';

/// DEV ONLY (see FeatureFlags.devWalletCreditEnabled): adds test money to the
/// caller's own wallet until the payment gateway exists.
class DevCreditWalletUseCase {
  final WalletRepository _repository;

  DevCreditWalletUseCase(this._repository);

  Future<void> execute({
    required String userId,
    required int amount,
    required String idempotencyKey,
  }) => _repository.devCredit(
    userId: userId,
    amount: amount,
    idempotencyKey: idempotencyKey,
  );
}
