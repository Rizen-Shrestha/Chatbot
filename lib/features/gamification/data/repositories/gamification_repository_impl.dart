import '../../domain/entities/gamification_profile.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_data_source.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;

  GamificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<GamificationProfile> getGamificationProfile(String uid) =>
      remoteDataSource.getProfile(uid);

  @override
  Future<void> awardPointsAndCheckMilestones(String uid) async =>
      await remoteDataSource.awardInteractionRewards(uid);
}
