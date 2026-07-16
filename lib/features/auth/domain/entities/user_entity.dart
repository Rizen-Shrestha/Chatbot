import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool hasCompletedOnboarding;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.hasCompletedOnboarding,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, hasCompletedOnboarding];
}