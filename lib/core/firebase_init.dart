import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Resultado de [initFirebase]: si la init fue exitosa, expone los
/// instances de Crashlytics y Analytics; si falló (placeholder no
/// reemplazado todavía o el dispositivo no tiene Play Services), todo
/// queda en `null` y la app arranca sin tracking.
class FirebaseSetup {
  const FirebaseSetup({this.crashlytics, this.analytics});

  final FirebaseCrashlytics? crashlytics;
  final FirebaseAnalytics? analytics;

  bool get isReady => crashlytics != null && analytics != null;
}

/// Inicializa Firebase + engancha Crashlytics a los handlers globales
/// de errores Dart/Flutter. Falla silencioso si el placeholder de
/// `firebase_options.dart` no fue reemplazado por `flutterfire
/// configure` — la app sigue corriendo, solo perdemos tracking.
Future<FirebaseSetup> initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('[Firebase] init falló: $e\n$st');
    return const FirebaseSetup();
  }

  final crashlytics = FirebaseCrashlytics.instance;
  final analytics = FirebaseAnalytics.instance;

  // Crashlytics solo en release. En debug los crashes los queremos
  // ver en consola, no en el dashboard.
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

  // Errores de Flutter framework (RenderObject, build phase, etc).
  FlutterError.onError = (errorDetails) {
    crashlytics.recordFlutterFatalError(errorDetails);
  };

  // Errores async de Dart no capturados (Future sin await, etc).
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  return FirebaseSetup(crashlytics: crashlytics, analytics: analytics);
}
