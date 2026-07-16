import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/gamification/presentation/pages/profile_screen.dart';
import '../di/injection_container.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = sl<FirebaseAuth>().currentUser;
      final loggingIn = state.matchedLocation == '/';

      // If user is not signed in, force them to stay/go to the login page
      if (user == null) {
        return '/';
      }

      // If user is signed in and trying to access login, redirect them to chat
      if (loggingIn) {
        return '/chat';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}