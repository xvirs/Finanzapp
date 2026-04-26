part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthActionStatus { idle, loading, success, failure }

final class AuthBlocState extends Equatable {
  const AuthBlocState({
    this.status = AuthStatus.unknown,
    this.session,
    this.actionStatus = AuthActionStatus.idle,
    this.errorMessage,
    this.lastMagicLinkEmail,
  });

  final AuthStatus status;
  final Session? session;
  final AuthActionStatus actionStatus;
  final String? errorMessage;
  final String? lastMagicLinkEmail;

  String? get email => session?.user.email;

  AuthBlocState copyWith({
    AuthStatus? status,
    Session? session,
    bool clearSession = false,
    AuthActionStatus? actionStatus,
    String? errorMessage,
    bool clearError = false,
    String? lastMagicLinkEmail,
    bool clearLastMagicLinkEmail = false,
  }) {
    return AuthBlocState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastMagicLinkEmail: clearLastMagicLinkEmail
          ? null
          : (lastMagicLinkEmail ?? this.lastMagicLinkEmail),
    );
  }

  @override
  List<Object?> get props => [
        status,
        session?.accessToken,
        actionStatus,
        errorMessage,
        lastMagicLinkEmail,
      ];
}
