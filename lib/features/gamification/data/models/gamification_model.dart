import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/gamification_profile.dart';

class GamificationModel extends GamificationProfile {
  const GamificationModel({
    required super.xp,
    required super.level,
    required super.currentStreak,
    super.lastActiveDate,
    required super.unlockedBadges,
  });

  factory GamificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GamificationModel(
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      unlockedBadges: List<String>.from(data['unlockedBadges'] ?? []),
    );
  }
}
