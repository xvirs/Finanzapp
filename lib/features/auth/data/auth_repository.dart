import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../../../core/supabase_client.dart';

class AuthRepository {
  AuthRepository()
      : _googleSignIn = GoogleSignIn(
          clientId: SupabaseConfig.googleIosClientId,
          serverClientId: SupabaseConfig.googleWebClientId,
          scopes: const ['email', 'profile', 'openid'],
        );

  final GoogleSignIn _googleSignIn;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Session? get currentSession => supabase.auth.currentSession;

  User? get currentUser => supabase.auth.currentUser;

  Future<void> signInWithMagicLink(String email) async {
    await supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: SupabaseConfig.authCallbackUrl,
    );
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the sign-in flow.
      return;
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException(
        'No se pudo obtener el ID token de Google.',
      );
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore — Google sign-out fails silently if user wasn't signed in there.
    }
    await supabase.auth.signOut();
  }
}
