import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Wrapper de Firebase Analytics. Centraliza la lista de eventos
/// trackeados y degrada a no-op silencioso cuando Firebase no está
/// configurado (analytics == null). Pensado para que las screens
/// llamen `AnalyticsService(firebase.analytics).billCreated()` sin
/// preocuparse por null checks.
class AnalyticsService {
  const AnalyticsService(this._analytics);

  final FirebaseAnalytics? _analytics;

  /// Identifica la sesión con un user_id (UUID de Supabase). Llamar
  /// post-login y null al signout. **No** mandamos email ni nombre —
  /// solo el UUID, suficiente para correlacionar eventos sin PII.
  Future<void> setUser(String? userId) async {
    final a = _analytics;
    if (a == null) return;
    try {
      await a.setUserId(id: userId);
    } catch (e) {
      debugPrint('[Analytics] setUser failed: $e');
    }
  }

  /// Útil para debugging local: forzar reset de instance ID en debug.
  Future<void> resetForTesting() async {
    final a = _analytics;
    if (a == null) return;
    await a.resetAnalyticsData();
  }

  // ============================================================
  // Eventos de la app. Lista cerrada — agregar acá los nuevos.
  // ============================================================

  Future<void> screenView(String name) =>
      _log('screen_view', {'screen_name': name, 'screen_class': name});

  Future<void> billCreated({required String kind}) =>
      _log('bill_created', {'kind': kind});

  Future<void> billPaid({required String kind, required double amount}) =>
      _log('bill_paid', {'kind': kind, 'amount': amount});

  Future<void> cardCreated({required String brand}) =>
      _log('card_created', {'brand': brand});

  Future<void> installmentCreated({required int totalInstallments}) =>
      _log('installment_created', {'total_installments': totalInstallments});

  Future<void> biometricToggled({required bool enabled}) =>
      _log('biometric_toggled', {'enabled': enabled});

  Future<void> notificationsToggled({required bool enabled}) =>
      _log('notifications_toggled', {'enabled': enabled});

  Future<void> signedIn({required String method}) =>
      _log('login', {'method': method});

  Future<void> signedOut() => _log('sign_out', null);

  // ============================================================
  // Internals
  // ============================================================

  Future<void> _log(String name, Map<String, Object>? params) async {
    final a = _analytics;
    if (a == null) return;
    try {
      await a.logEvent(name: name, parameters: params);
    } catch (e) {
      // No queremos que un bug de analytics rompa funcionalidad.
      debugPrint('[Analytics] logEvent($name) failed: $e');
    }
  }
}
