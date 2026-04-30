import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../../../core/supabase_client.dart';

class AuthRepository {
  AuthRepository();

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Session? get currentSession => supabase.auth.currentSession;

  User? get currentUser => supabase.auth.currentUser;

  /// Genera un raw nonce criptográficamente seguro (32 chars alfa-num).
  String _generateRawNonce({int length = 32}) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<void> signInWithMagicLink(String email) async {
    await supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: SupabaseConfig.authCallbackUrl,
    );
  }

  /// Login nativo con Google + Supabase signInWithIdToken.
  ///
  /// Flow del nonce (necesario porque iOS embebe nonce en el id_token
  /// automáticamente; sin esto Supabase rompe con
  /// "Passed nonce and nonce in id_token should either both exist or not"):
  ///
  ///   1. Generamos `rawNonce` random.
  ///   2. `hashedNonce = SHA256(rawNonce)`.
  ///   3. Se lo damos a Google Sign-In via `initialize(nonce: hashedNonce)`.
  ///      Google lo embebe en el id_token como claim `nonce`.
  ///   4. Le damos `rawNonce` a Supabase. Supabase verifica que
  ///      `SHA256(rawNonce) == claim "nonce" del JWT`.
  Future<void> signInWithGoogle() async {
    final rawNonce = _generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    // Re-init por sesión con el nuevo hashedNonce. `initialize` es por
    // singleton pero permite reinicializar sin problema; cada llamada
    // reemplaza el nonce previo en el plugin nativo.
    await GoogleSignIn.instance.initialize(
      clientId: SupabaseConfig.googleIosClientId,
      serverClientId: SupabaseConfig.googleWebClientId,
      nonce: hashedNonce,
    );

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );
    } on GoogleSignInException catch (e) {
      // Cancelación del usuario: silencio. El resto sí lo dejamos
      // propagar para que la UI muestre el error.
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('No se pudo obtener el ID token de Google.');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  /// Login nativo con Apple + Supabase signInWithIdToken.
  ///
  /// **Solo iOS** (la UI debe mostrar el botón con `Platform.isIOS`).
  /// Apple Review Guideline 4.8 lo exige cuando se ofrece Google
  /// Sign-In. El flow del nonce es análogo al de Google:
  ///
  ///   1. Generamos `rawNonce` random.
  ///   2. `hashedNonce = SHA256(rawNonce)`.
  ///   3. Pasamos `hashedNonce` a `getAppleIDCredential(nonce: ...)`.
  ///      Apple lo embebe en el identityToken como claim `nonce`.
  ///   4. Le damos `rawNonce` a Supabase para verificar.
  Future<void> signInWithApple() async {
    final rawNonce = _generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      // Cancelación del usuario: silencio. El resto propaga.
      if (e.code == AuthorizationErrorCode.canceled) return;
      rethrow;
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
        'No se pudo obtener el identity token de Apple.',
      );
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google sign-out falla silencioso si no había sesión Google.
    }
    await supabase.auth.signOut();
  }
}
