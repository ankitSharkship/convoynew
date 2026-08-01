import '../entities/scratch_card_entity.dart';

abstract class ScratchCardRepository {
  Future<List<ScratchCardEntity>> listCards(String userId);

  Future<ScratchResultEntity> scratch({
    required String userId,
    required String cardId,
    required String idempotencyKey,
  });
}
