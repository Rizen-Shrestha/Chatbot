import '../entities/gamification_profile.dart';

abstract class GamificationRepository {
  Stream<GamificationProfile> getGamificationProfile(String uid);
  Future<void> awardPointsAndCheckMilestones(String uid);
}