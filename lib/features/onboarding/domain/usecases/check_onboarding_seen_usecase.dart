import '../repositories/onboarding_repository.dart';

class CheckOnboardingSeenUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingSeenUseCase(this._repository);

  Future<bool> execute() => _repository.hasSeen();
}
