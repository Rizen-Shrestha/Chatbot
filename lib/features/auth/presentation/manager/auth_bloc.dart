import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_google.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  AuthBloc({
    required this.authRepository,
    required this.signInWithGoogleUseCase,
  }) : super(AuthInitial()) {

    on<AppStarted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          if (user.hasCompletedOnboarding) {
            emit(AuthenticatedToGo(user));
          } else {
            emit(AuthenticatedNeedsOnboarding(user));
          }
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<SignInWithGoogleRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInWithGoogleUseCase();
        if (user.hasCompletedOnboarding) {
          emit(AuthenticatedToGo(user));
        } else {
          emit(AuthenticatedNeedsOnboarding(user));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignInWithFacebookRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithFacebook();
        if (user.hasCompletedOnboarding) {
          emit(AuthenticatedToGo(user));
        } else {
          emit(AuthenticatedNeedsOnboarding(user));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }
}