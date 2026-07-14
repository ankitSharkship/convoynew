abstract class OnboardingRepository {
  Future<bool> hasSeen();
  Future<void> markSeen();
}
