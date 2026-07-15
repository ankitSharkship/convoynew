import '../../../post/domain/entities/trip_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';

abstract class HistoryRepository {
  Future<List<TripEntity>> getPostHistory();

  Future<List<SearchHistoryEntity>> getSearchHistory();
}
