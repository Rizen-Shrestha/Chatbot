import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.photoUrl,
    required super.hasCompletedOnboarding,
  });

  factory UserModel.fromFirebaseUser(dynamic user, bool onboardingComplete) {
    return UserModel(
      uid: user.uid ?? '',
      email: user.email ?? '',
      displayName: user.displayName ?? 'Anonymous User',
      photoUrl: user.photoURL ?? '',
      hasCompletedOnboarding: onboardingComplete,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
}