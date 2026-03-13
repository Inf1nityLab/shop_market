part of 'auth_cubit.dart';



sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final AuthModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ... ваши остальные стейты (AuthInitial, AuthLoading, AuthAuthenticated, AuthError)

final class AuthUnauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}