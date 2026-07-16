import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/gamification_cubit.dart';
import '../../domain/entities/gamification_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = sl<FirebaseAuth>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Your Progression Hub")),
      body: BlocProvider(
        create: (_) => sl<GamificationCubit>()..loadProfile(uid),
        child: BlocBuilder<GamificationCubit, GamificationProfile?>(
          builder: (context, profile) {
            if (profile == null)
              return const Center(child: CircularProgressIndicator());

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Level ${profile.level}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Rank: ${profile.rankTitle}",
                    style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // XP Progress bar
                  LinearProgressIndicator(
                    value: profile.xp / profile.nextLevelXpRequired,
                    backgroundColor: Colors.grey[800],
                    color: Colors.deepPurpleAccent,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${profile.xp} / ${profile.nextLevelXpRequired} XP to next level",
                    textAlign: Alignment.centerLeft.x == 0
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                  const SizedBox(height: 32),

                  // Streak view card
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 36,
                      ),
                      title: Text("${profile.currentStreak} Day Streak!"),
                      subtitle: const Text(
                        "Chat daily to maximize interest multiplier bonuses.",
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Unlocked Badges",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Grid array mapping earned badges
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: profile.unlockedBadges.map((badgeId) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              badgeId == "5_questions"
                                  ? Icons.question_answer
                                  : Icons.bolt,
                              size: 44,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badgeId == "5_questions"
                                  ? "Curious Mind"
                                  : "Consistent",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
