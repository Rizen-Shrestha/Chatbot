abstract class OnboardingRepository {
  Future<void> saveUserPreferences(String uid, List<String> interests);
}