import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  ProfileEntity? getCachedProfile();
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updatePhotoPath(String path);
}
