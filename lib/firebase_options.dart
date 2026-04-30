// PLACEHOLDER — Será sobrescrito por `flutterfire configure`.
//
// Este archivo se genera automáticamente con tus credenciales de
// proyecto Firebase real cuando corrés:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<tu-firebase-project-id>
//
// Hasta entonces, el getter `currentPlatform` lanza UnimplementedError
// y la inicialización en main.dart cae al catch silencioso → la app
// arranca sin Firebase pero funciona normalmente.
//
// Ver docs/firebase_setup.md para el setup completo.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnimplementedError(
      'Firebase no configurado. Corré `flutterfire configure` para '
      'generar este archivo con tus credenciales reales. Detalles en '
      'docs/firebase_setup.md.',
    );
  }
}
