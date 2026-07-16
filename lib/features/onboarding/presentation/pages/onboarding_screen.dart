import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/onboarding_cubit.dart';
import '../manager/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  final List<String> availableInterests = const [
    'Tech',
    'Fitness',
    'Travel',
    'Food',
    'Finance',
    'Art',
    'Gaming',
  ];

  @override
  Widget build(BuildContext context) {
    // Safely retrieve the current authenticated user's ID
    final uid = sl<FirebaseAuth>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Tailor Your AI"), centerTitle: true),
      body: BlocProvider(
        create: (_) => sl<OnboardingCubit>(),
        child: BlocConsumer<OnboardingCubit, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            if (state is OnboardingSuccess) {
              // Onboarding complete, advance to Core AI chatbot screen
              context.go('/chat');
            }
          },
          builder: (context, state) {
            final cubit = context.read<OnboardingCubit>();

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "What topics interest you most?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your AI companion wraps its context engine around your chosen paths.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Wrap layouts let the tags dynamic auto-wrap natively based on screen width
                  Expanded(
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: availableInterests.map((interest) {
                        final isSelected = cubit.selectedInterests.contains(
                          interest,
                        );
                        return FilterChip(
                          label: Text(interest),
                          selected: isSelected,
                          selectedColor: Colors.deepPurple,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => cubit.toggleInterest(interest),
                        );
                      }).toList(),
                    ),
                  ),

                  if (state is OnboardingSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => cubit.submitPreferences(uid),
                      child: const Text("Finalize Setup & Connect AI"),
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
