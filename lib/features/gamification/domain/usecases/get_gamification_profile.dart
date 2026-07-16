import '../entities/gamification_profile.dart';
import '../repositories/gamification_repository.dart';

class GetGamificationProfileUseCase {
  final GamificationRepository repository;
  GetGamificationProfileUseCase(this.repository);

  Stream<GamificationProfile> call(String uid) => repository.getGamificationProfile(uid);
}