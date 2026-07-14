import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilePhotoUseCase {
  final ProfileRepository _repository;

  UpdateProfilePhotoUseCase(this._repository);

  Future<ProfileEntity> execute(String photoPath) =>
      _repository.updatePhotoPath(photoPath);
}
