import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja la autenticación biométrica + persistencia del flag "habilitado".
///
/// Uso:
/// 1. Al iniciar la app, llamar [refreshEnabledCache] para que [enabledCached]
///    refleje el valor en disco.
/// 2. El [AppLockGate] consulta [enabledCached] de forma sincrónica para
///    decidir si bloquear.
/// 3. El toggle de Config llama [setEnabled] (actualiza disco + cache).
class BiometricService {
  BiometricService();

  static const _prefKey = 'biometric_lock_enabled';

  final LocalAuthentication _auth = LocalAuthentication();
  bool _enabledCache = false;

  /// Valor cacheado en memoria del flag enabled. Sincronía garantizada
  /// después de [refreshEnabledCache].
  bool get enabledCached => _enabledCache;

  /// Lee el flag de disco y actualiza el cache. Devuelve el valor.
  Future<bool> refreshEnabledCache() async {
    final prefs = await SharedPreferences.getInstance();
    _enabledCache = prefs.getBool(_prefKey) ?? false;
    return _enabledCache;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    _enabledCache = value;
  }

  /// El dispositivo tiene hardware biométrico O passcode/PIN configurado.
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e, st) {
      debugPrint('[BiometricService] isAvailable error: $e\n$st');
      return false;
    }
  }

  /// El usuario tiene biometría enrolada (huella/face) además de
  /// passcode. Útil para la primera vez que activan el toggle.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e, st) {
      debugPrint('[BiometricService] canCheckBiometrics error: $e\n$st');
      return false;
    }
  }

  /// Lista de biométricos enrolados (face / fingerprint / strong / weak).
  /// En Android suele devolver `[strong]` o `[weak]` cuando hay huella.
  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e, st) {
      debugPrint('[BiometricService] availableBiometrics error: $e\n$st');
      return const [];
    }
  }

  /// Pide autenticar al usuario. Con [biometricOnly]=false (default), si
  /// no hay biométrico disponible cae al PIN/passcode del dispositivo.
  ///
  /// Las excepciones de plataforma (PlatformException) PROPAGAN al caller
  /// para que pueda mostrar el código/mensaje real. Solo errores no-platform
  /// se loguean y devuelven false.
  Future<bool> authenticate({
    String reason = 'Desbloqueá para acceder a Finanzapp',
  }) async {
    return _auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    );
  }
}
