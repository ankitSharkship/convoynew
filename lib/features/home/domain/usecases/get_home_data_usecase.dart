import '../entities/home_data_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository _repository;

  GetHomeDataUseCase(this._repository);

  Future<HomeDataEntity> execute() => _repository.getHomeData();
}
