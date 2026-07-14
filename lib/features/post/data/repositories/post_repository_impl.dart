import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostLocalDataSource _dataSource;

  PostRepositoryImpl(this._dataSource);

  @override
  Future<PostEntity> submitPost({
    required String truckType,
    required String capacity,
    required String origin,
    required String destination,
    required String vehicleNumber,
  }) =>
      _dataSource.submitPost(
        truckType: truckType,
        capacity: capacity,
        origin: origin,
        destination: destination,
        vehicleNumber: vehicleNumber,
      );
}
