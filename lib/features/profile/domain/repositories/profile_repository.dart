import 'dart:io';

import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  ProfileEntity? getCachedProfile();
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updatePhotoPath(String path);

  /// Uploads [imageFile] as the user's profile photo on the server.
  Future<void> uploadPhoto(File imageFile);

  /// Downloads the user's profile photo from the server (if any) and
  /// caches it to local storage. Safe to call repeatedly — [getProfile]
  /// already does so whenever there's no local copy on disk yet.
  Future<void> cacheProfilePhotoFromServer();
}
