import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetCachedProfileUseCase {
  final ProfileRepository _repository;

  GetCachedProfileUseCase(this._repository);

  ProfileEntity? execute() => _repository.getCachedProfile();
}
