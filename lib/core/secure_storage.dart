import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend de almacenamiento usando flutter_secure_storage:
///   - iOS: Keychain (con `accessibility = first_unlock`).
///   - Android: EncryptedSharedPreferences (AES256 + master key en
///     Keystore hardware si está disponible).
///
/// Reemplaza al default de Supabase (`SharedPreferencesLocalStorage`)
/// que persiste el refresh token en plaintext. En un device rooteado
/// o post-extracción adb, esto bloquea la lectura del token sin la
/// master key.
const _androidOptions = AndroidOptions(encryptedSharedPreferences: true);
const _secure = FlutterSecureStorage(aOptions: _androidOptions);

/// LocalStorage para la sesión Supabase (access + refresh token + user
/// serializados como JSON en una sola key).
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({this.persistSessionKey = 'sb_persist_session'});

  final String persistSessionKey;

  @override
  Future<void> initialize() async {
    // No-op. flutter_secure_storage no requiere init explícito (Keychain
    // / EncryptedSharedPreferences se inicializan lazy).
  }

  @override
  Future<bool> hasAccessToken() => _secure.containsKey(key: persistSessionKey);

  @override
  Future<String?> accessToken() => _secure.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _secure.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secure.write(key: persistSessionKey, value: persistSessionString);
}

/// Storage para el PKCE code verifier (auth temporal durante OAuth /
/// magic link). Es un mapa key→value genérico, no la sesión.
class SecureGotrueAsyncStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) => _secure.read(key: key);

  @override
  Future<void> removeItem({required String key}) => _secure.delete(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _secure.write(key: key, value: value);
}
