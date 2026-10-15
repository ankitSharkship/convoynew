import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileNameUseCase {
  final ProfileRepository _repository;

  UpdateProfileNameUseCase(this._repository);

  Future<ProfileEntity> execute(String name) => _repository.updateName(name);
}
