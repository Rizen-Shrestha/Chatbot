import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/presentation/manager/auth_bloc.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_chat_history.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/presentation/manager/chat_cubit.dart';
import '../../features/gamification/data/datasources/gamification_remote_data_source.dart';
import '../../features/gamification/data/repositories/gamification_repository_impl.dart';
import '../../features/gamification/domain/repositories/gamification_repository.dart';
import '../../features/gamification/domain/usecases/award_points.dart';
import '../../features/gamification/domain/usecases/get_gamification_profile.dart';
import '../../features/gamification/presentation/manager/gamification_cubit.dart';
import '../../features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/save_user_preferences.dart';
import '../../features/onboarding/presentation/manager/onboarding_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FacebookAuth.instance);
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
      facebookAuth: sl(),
    ),
  );

  sl.registerFactory(
    () => AuthBloc(authRepository: sl(), signInWithGoogleUseCase: sl()),
  );

  sl.registerFactory(() => OnboardingCubit(saveUserPreferencesUseCase: sl()));

  sl.registerLazySingleton(() => SaveUserPreferencesUseCase(sl()));

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(firestore: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => ChatCubit(
      getChatHistoryUseCase: sl(),
      sendMessageUseCase: sl(),
      awardPointsUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Gamification
  // Cubit
  sl.registerFactory(
    () => GamificationCubit(getGamificationProfileUseCase: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetGamificationProfileUseCase(sl()));
  sl.registerLazySingleton(() => AwardPointsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<GamificationRemoteDataSource>(
    () => GamificationRemoteDataSourceImpl(firestore: sl()),
  );
}
