import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/get_wallet_transactions_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../domain/usecases/redeem_wallet_usecase.dart';

part 'wallet_notifier.g.dart';

@riverpod
WalletRemoteDataSource walletRemoteDataSource(WalletRemoteDataSourceRef ref) {
  return WalletRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
WalletRepositoryImpl walletRepository(WalletRepositoryRef ref) {
  return WalletRepositoryImpl(ref.watch(walletRemoteDataSourceProvider));
}

@riverpod
GetWalletUseCase getWalletUseCase(GetWalletUseCaseRef ref) {
  return GetWalletUseCase(ref.watch(walletRepositoryProvider));
}

@riverpod
GetWalletTransactionsUseCase getWalletTransactionsUseCase(
  GetWalletTransactionsUseCaseRef ref,
) {
  return GetWalletTransactionsUseCase(ref.watch(walletRepositoryProvider));
}

@riverpod
RedeemWalletUseCase redeemWalletUseCase(RedeemWalletUseCaseRef ref) {
  return RedeemWalletUseCase(ref.watch(walletRepositoryProvider));
}

class WalletData {
  final WalletEntity wallet;
  final List<WalletTransactionEntity> transactions;

  const WalletData({required this.wallet, required this.transactions});
}

@riverpod
class WalletNotifier extends _$WalletNotifier {
  // One idempotency key per redeem *attempt* — generated on the first try
  // and deliberately reused across retries of that same attempt (only
  // cleared after a success), so retrying a timed-out request is a safe
  // no-op server-side instead of possibly queuing a second payout.
  String? _pendingIdempotencyKey;

  @override
  Future<WalletData> build() async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();

    final results = await Future.wait([
      ref.watch(getWalletUseCaseProvider).execute(userId),
      ref.watch(getWalletTransactionsUseCaseProvider).execute(userId),
    ]);
    return WalletData(
      wallet: results[0] as WalletEntity,
      transactions: results[1] as List<WalletTransactionEntity>,
    );
  }

  /// Patches just the available balance in place — used right after a
  /// scratch-card reveal, whose response already carries the post-credit
  /// balance, so the wallet UI can update instantly without waiting on a
  /// second GET /wallet round trip. The transaction list is intentionally
  /// left stale until the next [refresh]; callers typically fire one of
  /// those in the background right after calling this.
  void applyAvailableBalance(String availableBalance) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      WalletData(
        wallet: WalletEntity(
          availableBalance: availableBalance,
          reservedBalance: current.wallet.reservedBalance,
          status: current.wallet.status,
        ),
        transactions: current.transactions,
      ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Throws [ApiException] on failure — the caller (redeem sheet) is
  /// expected to catch it and show [ApiException.messageFor]. On success,
  /// refreshes the wallet/transactions so the new reserved/available split
  /// is reflected rather than guessed client-side.
  Future<void> redeem(String upiId) async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();

    _pendingIdempotencyKey ??= const Uuid().v4();
    await ref
        .read(redeemWalletUseCaseProvider)
        .execute(
          userId: userId,
          upiId: upiId,
          idempotencyKey: _pendingIdempotencyKey!,
        );
    _pendingIdempotencyKey = null;

    ref.invalidateSelf();
    await future;
  }
}
