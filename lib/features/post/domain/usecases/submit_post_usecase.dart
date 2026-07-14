import '../../../search/domain/entities/location_entity.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class SubmitPostUseCase {
  final PostRepository _repository;

  SubmitPostUseCase(this._repository);

  Future<PostEntity> execute({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    required DateTime availableDate,
  }) =>
      _repository.submitPost(
        userId: userId,
        vehicleId: vehicleId,
        origin: origin,
        destinations: destinations,
        currentLocation: currentLocation,
        availableDate: availableDate,
      );
}
