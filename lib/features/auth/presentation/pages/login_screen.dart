import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/auth_bloc.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)), // Dart automatically promotes 'state' to AuthError here
            );
          }
          if (state is AuthenticatedNeedsOnboarding) {
            // Navigate to Onboarding Screen
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
          if (state is AuthenticatedToGo) {
            // Navigate to Main Chat Screen
            Navigator.pushReplacementNamed(context, '/chat');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.rocket_launch, size: 80, color: Colors.deepPurpleAccent),
                const SizedBox(height: 24),
                const Text(
                  "NexusAI Companion",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Level up your life with your specialized AI advisor.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // Google Sign In Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Continue with Google"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithGoogleRequested());
                  },
                ),
                const SizedBox(height: 16),

                // Facebook Sign In Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.facebook),
                  label: const Text("Continue with Facebook"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithFacebookRequested());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}