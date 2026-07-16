import '../repositories/onboarding_repository.dart';

class SaveUserPreferencesUseCase {
  final OnboardingRepository repository;

  SaveUserPreferencesUseCase(this.repository);

  Future<void> call(String uid, List<String> interests) async {
    return await repository.saveUserPreferences(uid, interests);
  }
}