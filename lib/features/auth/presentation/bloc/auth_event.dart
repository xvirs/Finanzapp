part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

final class AuthSessionChanged extends AuthEvent {
  const AuthSessionChanged(this.session);

  final Session? session;

  @override
  List<Object?> get props => [session?.accessToken];
}

final class AuthMagicLinkRequested extends AuthEvent {
  const AuthMagicLinkRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
