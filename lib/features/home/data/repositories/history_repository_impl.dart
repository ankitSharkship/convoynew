import '../../../post/domain/entities/trip_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _remote;

  HistoryRepositoryImpl(this._remote);

  @override
  Future<List<TripEntity>> getPostHistory() => _remote.getPostHistory();

  @override
  Future<List<SearchHistoryEntity>> getSearchHistory() =>
      _remote.getSearchHistory();
}
