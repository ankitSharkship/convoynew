import '../../../search/domain/entities/search_history_entity.dart';
import '../repositories/history_repository.dart';

class GetSearchHistoryUseCase {
  final HistoryRepository _repository;

  GetSearchHistoryUseCase(this._repository);

  Future<List<SearchHistoryEntity>> execute() => _repository.getSearchHistory();
}
