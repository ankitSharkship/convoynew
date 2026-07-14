import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remote;

  PostRepositoryImpl(this._remote);

  @override
  Future<PostEntity> submitPost({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    required DateTime availableDate,
    String? contactName,
    String? contactNumber,
  }) => _remote.submitPost(
    userId: userId,
    vehicleId: vehicleId,
    origin: origin,
    destinations: destinations,
    currentLocation: currentLocation,
    availableDate: availableDate,
    contactName: contactName,
    contactNumber: contactNumber,
  );
}
