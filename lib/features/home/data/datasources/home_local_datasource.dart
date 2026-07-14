import '../../domain/entities/home_data_entity.dart';

abstract class HomeLocalDataSource {
  Future<HomeDataEntity> getHomeData();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<HomeDataEntity> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const HomeDataEntity(
      nearbyTrucks: [],
      recentPosts: [],
    );
  }
}
