import '../../domain/entities/scratch_card_entity.dart';
import '../../domain/repositories/scratch_card_repository.dart';
import '../datasources/scratch_card_remote_datasource.dart';

class ScratchCardRepositoryImpl implements ScratchCardRepository {
  final ScratchCardRemoteDataSource _remote;

  ScratchCardRepositoryImpl(this._remote);

  @override
  Future<List<ScratchCardEntity>> listCards(String userId) =>
      _remote.listCards(userId);

  @override
  Future<ScratchResultEntity> scratch({
    required String userId,
    required String cardId,
    required String idempotencyKey,
  }) => _remote.scratch(
    userId: userId,
    cardId: cardId,
    idempotencyKey: idempotencyKey,
  );
}
