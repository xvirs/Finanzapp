import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  AuthBloc({required AuthRepository repository})
    : _repository = repository,
      super(_initialState(repository)) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthSessionChanged>(_onSessionChanged);
    on<AuthMagicLinkRequested>(_onMagicLinkRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);

    add(const AuthSubscriptionRequested());
  }

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  static AuthBlocState _initialState(AuthRepository repository) {
    final session = repository.currentSession;
    return AuthBlocState(
      status: session != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      session: session,
    );
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    await _authSubscription?.cancel();
    _authSubscription = _repository.authStateChanges.listen((authState) {
      add(AuthSessionChanged(authState.session));
    });
  }

  void _onSessionChanged(
    AuthSessionChanged event,
    Emitter<AuthBlocState> emit,
  ) {
    final session = event.session;
    if (session != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          actionStatus: AuthActionStatus.idle,
          clearError: true,
          clearLastMagicLinkEmail: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          actionStatus: AuthActionStatus.idle,
          clearError: true,
        ),
      );
    }
  }

  Future<void> _onMagicLinkRequested(
    AuthMagicLinkRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(
      state.copyWith(actionStatus: AuthActionStatus.loading, clearError: true),
    );
    try {
      await _repository.signInWithMagicLink(event.email);
      emit(
        state.copyWith(
          actionStatus: AuthActionStatus.success,
          lastMagicLinkEmail: event.email,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(
      state.copyWith(actionStatus: AuthActionStatus.loading, clearError: true),
    );
    try {
      await _repository.signInWithGoogle();
      emit(state.copyWith(actionStatus: AuthActionStatus.idle));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(
      state.copyWith(actionStatus: AuthActionStatus.loading, clearError: true),
    );
    try {
      await _repository.signInWithApple();
      emit(state.copyWith(actionStatus: AuthActionStatus.idle));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    try {
      await _repository.signOut();
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(
      state.copyWith(actionStatus: AuthActionStatus.loading, clearError: true),
    );
    try {
      await _repository.deleteAccount();
      // El signOut interno dispara onAuthStateChange(null) → _onSessionChanged
      // emite unauthenticated + idle, así que no hace falta emit extra acá.
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
