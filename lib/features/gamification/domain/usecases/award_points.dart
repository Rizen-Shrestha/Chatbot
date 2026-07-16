import '../repositories/gamification_repository.dart';

class AwardPointsUseCase {
  final GamificationRepository repository;
  AwardPointsUseCase(this.repository);

  Future<void> call(String uid) async => await repository.awardPointsAndCheckMilestones(uid);
}