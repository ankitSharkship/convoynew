import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../wallet/presentation/state/wallet_notifier.dart';
import '../../data/datasources/scratch_card_remote_datasource.dart';
import '../../data/repositories/scratch_card_repository_impl.dart';
import '../../domain/entities/scratch_card_entity.dart';
import '../../domain/usecases/get_scratch_cards_usecase.dart';
import '../../domain/usecases/scratch_card_usecase.dart';

part 'scratch_cards_notifier.g.dart';

@riverpod
ScratchCardRemoteDataSource scratchCardRemoteDataSource(
  ScratchCardRemoteDataSourceRef ref,
) {
  return ScratchCardRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
ScratchCardRepositoryImpl scratchCardRepository(
  ScratchCardRepositoryRef ref,
) {
  return ScratchCardRepositoryImpl(ref.watch(scratchCardRemoteDataSourceProvider));
}

@riverpod
GetScratchCardsUseCase getScratchCardsUseCase(GetScratchCardsUseCaseRef ref) {
  return GetScratchCardsUseCase(ref.watch(scratchCardRepositoryProvider));
}

@riverpod
ScratchCardUseCase scratchCardUseCase(ScratchCardUseCaseRef ref) {
  return ScratchCardUseCase(ref.watch(scratchCardRepositoryProvider));
}

@riverpod
class ScratchCardsNotifier extends _$ScratchCardsNotifier {
  // One idempotency key per card per scratch attempt — reused across
  // retries of that same attempt, cleared only once it succeeds. Keyed by
  // card id since, unlike a wallet redeem, more than one card could
  // plausibly be mid-attempt at once (e.g. the grid on the wallet page).
  final Map<String, String> _pendingIdempotencyKeys = {};

  @override
  Future<List<ScratchCardEntity>> build() async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();
    return ref.watch(getScratchCardsUseCaseProvider).execute(userId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Throws [ApiException] on failure. Either way, the card list is
  /// resynced afterward — on success to reflect the reveal, on failure
  /// because a 409/410 means the card's true server state (already
  /// scratched / expired) differs from what's shown locally.
  Future<ScratchResultEntity> scratch(String cardId) async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();

    final idempotencyKey = _pendingIdempotencyKeys[cardId] ??= const Uuid().v4();
    try {
      final result = await ref
          .read(scratchCardUseCaseProvider)
          .execute(userId: userId, cardId: cardId, idempotencyKey: idempotencyKey);
      _pendingIdempotencyKeys.remove(cardId);

      final walletNotifier = ref.read(walletNotifierProvider.notifier);
      walletNotifier.applyAvailableBalance(result.walletAvailableBalance);
      unawaited(walletNotifier.refresh());

      await refresh();
      return result;
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}
