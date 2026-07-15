import '../../../post/domain/entities/trip_entity.dart';
import '../repositories/history_repository.dart';

class GetPostHistoryUseCase {
  final HistoryRepository _repository;

  GetPostHistoryUseCase(this._repository);

  Future<List<TripEntity>> execute() => _repository.getPostHistory();
}
