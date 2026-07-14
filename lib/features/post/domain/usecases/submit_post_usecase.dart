import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class SubmitPostUseCase {
  final PostRepository _repository;

  SubmitPostUseCase(this._repository);

  Future<PostEntity> execute({
    required String truckType,
    required String capacity,
    required String origin,
    required String destination,
    required String vehicleNumber,
  }) =>
      _repository.submitPost(
        truckType: truckType,
        capacity: capacity,
        origin: origin,
        destination: destination,
        vehicleNumber: vehicleNumber,
      );
}
