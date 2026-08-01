import '../entities/scratch_card_entity.dart';
import '../repositories/scratch_card_repository.dart';

class ScratchCardUseCase {
  final ScratchCardRepository _repository;

  ScratchCardUseCase(this._repository);

  Future<ScratchResultEntity> execute({
    required String userId,
    required String cardId,
    required String idempotencyKey,
  }) => _repository.scratch(
    userId: userId,
    cardId: cardId,
    idempotencyKey: idempotencyKey,
  );
}
