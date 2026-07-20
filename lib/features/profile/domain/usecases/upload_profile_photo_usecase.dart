import 'dart:io';

import '../repositories/profile_repository.dart';

class UploadProfilePhotoUseCase {
  final ProfileRepository _repository;

  UploadProfilePhotoUseCase(this._repository);

  Future<void> execute(File imageFile) => _repository.uploadPhoto(imageFile);
}
