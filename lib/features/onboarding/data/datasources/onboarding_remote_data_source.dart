import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OnboardingRemoteDataSource {
  Future<void> savePreferences(String uid, List<String> interests);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final FirebaseFirestore firestore;

  OnboardingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> savePreferences(String uid, List<String> interests) async {
    await firestore.collection('users').doc(uid).update({
      'interests': interests,
      'hasCompletedOnboarding': true,
    });
  }
}