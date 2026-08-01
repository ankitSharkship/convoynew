import '../entities/scratch_card_entity.dart';
import '../repositories/scratch_card_repository.dart';

class GetScratchCardsUseCase {
  final ScratchCardRepository _repository;

  GetScratchCardsUseCase(this._repository);

  Future<List<ScratchCardEntity>> execute(String userId) =>
      _repository.listCards(userId);
}
