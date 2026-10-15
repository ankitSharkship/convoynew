import '../repositories/profile_repository.dart';

class CheckHasNameUseCase {
  final ProfileRepository _repository;

  CheckHasNameUseCase(this._repository);

  Future<bool> execute() => _repository.hasName();
}
