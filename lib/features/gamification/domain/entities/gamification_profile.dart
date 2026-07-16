import 'package:equatable/equatable.dart';

class GamificationProfile extends Equatable {
  final int xp;
  final int level;
  final int currentStreak;
  final DateTime? lastActiveDate;
  final List<String> unlockedBadges;

  const GamificationProfile({
    required this.xp,
    required this.level,
    required this.currentStreak,
    this.lastActiveDate,
    required this.unlockedBadges,
  });

  // Calculate experience required to level up (e.g., level 1 requires 100 XP, level 2 requires 200 XP...)
  int get nextLevelXpRequired => level * 100;

  String get rankTitle {
    if (level >= 10) return "Pro";
    if (level >= 5) return "Explorer";
    return "Beginner";
  }

  @override
  List<Object?> get props => [
    xp,
    level,
    currentStreak,
    lastActiveDate,
    unlockedBadges,
  ];
}
