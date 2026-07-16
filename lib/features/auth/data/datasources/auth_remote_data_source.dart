import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithFacebook();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
    required this.facebookAuth,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In canceled by user.');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await firebaseAuth
        .signInWithCredential(credential);
    return await _getOrCreateUserModel(userCredential.user!);
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    if (result.status != LoginStatus.success)
      throw Exception('Facebook Sign-In failed or canceled.');

    final AuthCredential credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );
    final UserCredential userCredential = await firebaseAuth
        .signInWithCredential(credential);
    return await _getOrCreateUserModel(userCredential.user!);
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await facebookAuth.logOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return await _getOrCreateUserModel(user);
  }

  // Check Firestore to see if user preferences/onboarding are complete
  Future<UserModel> _getOrCreateUserModel(User user) async {
    final userDoc = await firestore.collection('users').doc(user.uid).get();

    bool onboardingComplete = false;
    if (userDoc.exists) {
      onboardingComplete = userDoc.data()?['hasCompletedOnboarding'] ?? false;
    } else {
      // First time initialized document setup
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Explorer',
        'hasCompletedOnboarding': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return UserModel.fromFirebaseUser(user, onboardingComplete);
  }
}
