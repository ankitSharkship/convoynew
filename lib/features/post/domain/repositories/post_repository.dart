import '../../../search/domain/entities/location_entity.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<PostEntity> submitPost({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    required DateTime availableDate,
    String? contactName,
    String? contactNumber,
  });
}
