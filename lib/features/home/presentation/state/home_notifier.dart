import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

part 'home_notifier.g.dart';

@riverpod
HomeLocalDataSource homeLocalDataSource(HomeLocalDataSourceRef ref) {
  return HomeLocalDataSourceImpl();
}

@riverpod
HomeRepositoryImpl homeRepository(HomeRepositoryRef ref) {
  return HomeRepositoryImpl(ref.watch(homeLocalDataSourceProvider));
}

@riverpod
GetHomeDataUseCase getHomeDataUseCase(GetHomeDataUseCaseRef ref) {
  return GetHomeDataUseCase(ref.watch(homeRepositoryProvider));
}

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  Future<HomeDataEntity> build() async {
    final useCase = ref.watch(getHomeDataUseCaseProvider);
    return useCase.execute();
  }
}
