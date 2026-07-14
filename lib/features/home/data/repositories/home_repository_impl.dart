import '../../domain/entities/home_data_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _dataSource;

  HomeRepositoryImpl(this._dataSource);

  @override
  Future<HomeDataEntity> getHomeData() => _dataSource.getHomeData();
}
