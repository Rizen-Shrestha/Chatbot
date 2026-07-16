import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/save_user_preferences.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SaveUserPreferencesUseCase saveUserPreferencesUseCase;

  // Track selected tags locally within presentation memory
  final List<String> _selectedInterests = [];

  OnboardingCubit({required this.saveUserPreferencesUseCase}) : super(OnboardingInitial());

  List<String> get selectedInterests => _selectedInterests;

  void toggleInterest(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
    // Trigger UI redraw by emitting current state again
    emit(OnboardingInitial());
  }

  Future<void> submitPreferences(String uid) async {
    if (_selectedInterests.isEmpty) {
      emit(const OnboardingFailure("Please select at least one interest to personalize your AI."));
      return;
    }

    emit(OnboardingSubmitting());
    try {
      await saveUserPreferencesUseCase(uid, _selectedInterests);
      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingFailure(e.toString()));
    }
  }
}