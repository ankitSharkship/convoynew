import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<PostEntity> submitPost({
    required String truckType,
    required String capacity,
    required String origin,
    required String destination,
    required String vehicleNumber,
  });
}
