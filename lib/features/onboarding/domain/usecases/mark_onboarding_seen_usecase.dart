import '../repositories/onboarding_repository.dart';

class MarkOnboardingSeenUseCase {
  final OnboardingRepository _repository;

  MarkOnboardingSeenUseCase(this._repository);

  Future<void> execute() => _repository.markSeen();
}
