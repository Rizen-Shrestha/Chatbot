import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthenticatedToGo extends AuthState {
  final UserEntity user;
  const AuthenticatedToGo(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthenticatedNeedsOnboarding extends AuthState {
  final UserEntity user;
  const AuthenticatedNeedsOnboarding(this.user);
  @override
  List<Object?> get props => [user];
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}