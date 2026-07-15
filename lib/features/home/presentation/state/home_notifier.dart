import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../post/domain/entities/trip_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';
import '../../data/datasources/history_remote_datasource.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_post_history_usecase.dart';
import '../../domain/usecases/get_search_history_usecase.dart';

part 'home_notifier.g.dart';

@riverpod
HistoryRemoteDataSource historyRemoteDataSource(
  HistoryRemoteDataSourceRef ref,
) {
  return HistoryRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
HistoryRepositoryImpl historyRepository(HistoryRepositoryRef ref) {
  return HistoryRepositoryImpl(ref.watch(historyRemoteDataSourceProvider));
}

@riverpod
GetPostHistoryUseCase getPostHistoryUseCase(GetPostHistoryUseCaseRef ref) {
  return GetPostHistoryUseCase(ref.watch(historyRepositoryProvider));
}

@riverpod
GetSearchHistoryUseCase getSearchHistoryUseCase(
  GetSearchHistoryUseCaseRef ref,
) {
  return GetSearchHistoryUseCase(ref.watch(historyRepositoryProvider));
}

// Kept as two independent providers (rather than one combined "home data"
// notifier) so a failure fetching one history list can't turn the whole
// Home screen into an error page — each section owns its own AsyncValue and
// fails in isolation.

@riverpod
class PostHistoryNotifier extends _$PostHistoryNotifier {
  @override
  Future<List<TripEntity>> build() {
    return ref.read(getPostHistoryUseCaseProvider).execute();
  }
}

@riverpod
class SearchHistoryNotifier extends _$SearchHistoryNotifier {
  @override
  Future<List<SearchHistoryEntity>> build() {
    return ref.read(getSearchHistoryUseCaseProvider).execute();
  }
}
