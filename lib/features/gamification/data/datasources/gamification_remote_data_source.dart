import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_model.dart';

abstract class GamificationRemoteDataSource {
  Stream<GamificationModel> getProfile(String uid);

  Future<void> awardInteractionRewards(String uid);
}

class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final FirebaseFirestore firestore;

  GamificationRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<GamificationModel> getProfile(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => GamificationModel.fromFirestore(doc));
  }

  @override
  Future<void> awardInteractionRewards(String uid) async {
    final userRef = firestore.collection('users').doc(uid);
    final messagesQuery = userRef
        .collection('messages')
        .where('sender', isEqualTo: 'user');

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};
      int currentXp = data['xp'] ?? 0;
      int currentLevel = data['level'] ?? 1;
      int streak = data['currentStreak'] ?? 0;

      Timestamp? lastActiveTs = data['lastActiveDate'] as Timestamp?;
      List<String> badges = List<String>.from(data['unlockedBadges'] ?? []);

      // 1. Calculate Streak Changes
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastActiveTs == null) {
        streak = 1;
      } else {
        final lastActiveDate = lastActiveTs.toDate();
        final lastActiveDay = DateTime(
          lastActiveDate.year,
          lastActiveDate.month,
          lastActiveDate.day,
        );
        final difference = today.difference(lastActiveDay).inDays;

        if (difference == 1) {
          streak += 1; // Streak sustained!
        } else if (difference > 1) {
          streak = 1; // Streak broken, reset
        }
      }

      // 2. Award XP (+15 XP per interaction)
      currentXp += 15;

      // 3. Evaluate Level Ups (100 XP threshold progression scale)
      int xpNeeded = currentLevel * 100;
      if (currentXp >= xpNeeded) {
        currentXp -= xpNeeded;
        currentLevel += 1;
      }

      // 4. Milestone Check for Badge Unlocks
      final msgCountSnapshot = await messagesQuery.get();
      int totalQuestionsAsked = msgCountSnapshot.docs.length;

      if (totalQuestionsAsked >= 5 && !badges.contains("5_questions")) {
        badges.add("5_questions");
      }
      if (streak >= 7 && !badges.contains("7_day_streak")) {
        badges.add("7_day_streak");
      }

      // 5. Commit Transaction
      transaction.update(userRef, {
        'xp': currentXp,
        'level': currentLevel,
        'currentStreak': streak,
        'lastActiveDate': Timestamp.fromDate(now),
        'unlockedBadges': badges,
      });
    });
  }
}
