import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}
class OnboardingSubmitting extends OnboardingState {}
class OnboardingSuccess extends OnboardingState {}
class OnboardingFailure extends OnboardingState {
  final String message;
  const OnboardingFailure(this.message);
  @override
  List<Object?> get props => [message];
}