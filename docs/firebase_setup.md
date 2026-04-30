# Setup Firebase — Crashlytics + Analytics

Estado del repo: **Firebase está integrado en el código pero no configurado**. La app arranca sin tracking hasta que corras `flutterfire configure`. Este documento te guía paso a paso.

---

## 1. ¿Qué da Firebase?

| Feature | Valor para Finanzapp |
|---|---|
| **Crashlytics** | Stack traces de crashes en producción, agrupados por similitud, con device/OS context. **Crítico** para iterar la primera versión del app. Sin esto, los crashes son una caja negra. |
| **Analytics** | Métricas: DAU/MAU, retention, screen views, eventos custom (`bill_created`, `card_created`, `signed_in`, etc.). Te ayuda a entender uso real. |

Trade-off de privacidad: tenés que declarar en Privacy Policy + Data Safety form que usás analytics y crashlytics. Ya está actualizado en este repo.

---

## 2. Crear proyecto Firebase

1. Andá a https://console.firebase.google.com con el Google que querés asociar (el mismo que la cuenta de Play Console te conviene).
2. **Add project** → name: `Finanzapp` (o `finanzapp-prod`) → Continue.
3. Google Analytics:
   - **Enable Google Analytics for this project** → Yes.
   - Cuenta: usá la default o creá una nueva.
4. Create project. Espera 1-2 minutos.

---

## 3. Instalar Firebase CLI + FlutterFire CLI

En tu Mac:

```bash
# 1. Firebase CLI (Node)
npm install -g firebase-tools
# o si preferís sin npm:
curl -sL https://firebase.tools | bash

# 2. Login
firebase login

# 3. FlutterFire CLI (Dart)
dart pub global activate flutterfire_cli

# 4. Verificar PATH (debería estar ~/.pub-cache/bin)
flutterfire --version
```

---

## 4. Configurar el proyecto

Desde la raíz del proyecto Flutter:

```bash
cd /Users/xavier/Proyectos/Finanzapp
flutterfire configure
```

El CLI te pregunta:
- **Select a Firebase project**: elegí `Finanzapp` (el que creaste en paso 2).
- **Which platforms?**: marcá `android` y `ios` (no web).
- **Android package name**: confirmar `com.xavier.finanzapp`.
- **iOS bundle ID**: confirmar `com.xavier.finanzapp`.

El CLI hace automáticamente:
- Crea apps Android e iOS dentro de tu proyecto Firebase.
- Descarga `google-services.json` → `android/app/google-services.json`.
- Descarga `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`.
- **Sobrescribe `lib/firebase_options.dart`** con las credenciales reales.
- Modifica `android/build.gradle.kts` y `android/app/build.gradle.kts` para agregar los plugins de Google Services y Crashlytics.
- Modifica `ios/Runner.xcodeproj` para agregar `GoogleService-Info.plist` al target Runner.

---

## 5. Activar Crashlytics en Firebase Console

1. Firebase Console → tu proyecto → **Crashlytics** (sidebar).
2. Click **Get started**.
3. Te pide forzar un crash de prueba para verificar wiring.
4. (Más adelante en el doc te muestro cómo forzar el crash desde la app.)

---

## 6. Verificar el build

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Android
flutter build apk --debug

# iOS (si tenés Apple Dev account configurado)
flutter build ios --debug --no-codesign
```

Si hay errores de compilación tipo "Default FirebaseApp is not initialized", quiere decir que `flutterfire configure` no pudo modificar correctamente los Gradle files. Solución manual:

### Manual fallback Android

`android/settings.gradle.kts` — agregá:

```kotlin
plugins {
    // ... (los que ya hay)
    id("com.google.gms.google-services") version "4.4.4" apply false
    id("com.google.firebase.crashlytics") version "3.0.5" apply false
}
```

`android/app/build.gradle.kts` — agregá al bloque `plugins`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")        // <-- nuevo
    id("com.google.firebase.crashlytics")       // <-- nuevo
}
```

### Manual fallback iOS

Generalmente no hace falta — `flutterfire configure` agrega `GoogleService-Info.plist` al target Runner via xcodeproj patching. Si no lo hizo:

1. Abrir Xcode: `open ios/Runner.xcworkspace`.
2. Click derecho en `Runner` (folder en sidebar) → **Add Files to "Runner"**.
3. Seleccionar `ios/Runner/GoogleService-Info.plist`.
4. ✅ "Copy items if needed" + ✅ "Add to targets: Runner".

---

## 7. Forzar un crash de prueba (validar Crashlytics)

Agregar temporalmente un botón en alguna screen (Config es buen candidato):

```dart
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: const Text('TEST: forzar crash'),
)
```

1. Build release: `flutter run --release`
2. Login normal.
3. Tocás el botón → la app se cierra de golpe.
4. Re-abrís la app (importante — Crashlytics envía el crash al inicio del próximo run).
5. Esperás 5-10 minutos.
6. Firebase Console → Crashlytics → ves el crash con stack trace.

**Después del test, ELIMINAR el botón.** No queremos crashear users por accidente.

---

## 8. Crashlytics + R8/ProGuard mapping (Android)

Para que los stack traces de release sean legibles (los nombres de clases minified vuelven a su forma original), Firebase necesita el archivo de mapping de R8. El plugin Gradle de Crashlytics lo sube automáticamente cuando hacés `flutter build appbundle --release`. Ya está cubierto.

Verificalo en Firebase Console → Crashlytics → tu app → tab `dSYMs/Mappings`. Debería aparecer la versión luego del primer build release.

---

## 9. Eventos de Analytics que ya están instrumentados

`lib/core/analytics_service.dart` expone:

| Evento | Cuándo se dispara | Parámetros |
|---|---|---|
| `screen_view` | Apertura de cada screen principal | `screen_name`, `screen_class` |
| `bill_created` | Crear nueva cuenta fija | `kind` (electricity, water, etc.) |
| `bill_paid` | Marcar como pagada | `kind`, `amount` |
| `card_created` | Agregar tarjeta de crédito | `brand` |
| `installment_created` | Cargar compra en cuotas | `total_installments` |
| `biometric_toggled` | Activar/desactivar lock | `enabled` |
| `notifications_toggled` | Activar/desactivar notifs | `enabled` |
| `login` | Login exitoso | `method` (`google` o `magic_link`) |
| `sign_out` | Logout | — |

Las screens todavía no llaman estos métodos — los wireamos en una iteración futura. Por ahora `setUser(uuid)` se llama post-login para correlacionar eventos.

---

## 10. Limitaciones / heads-up

### En debug builds
Crashlytics está **desactivado** (`setCrashlyticsCollectionEnabled(!kDebugMode)`). Los crashes en debug los ves en consola, no en el dashboard. Esto es intencional — si dejás crashlytics activo en debug, te llenás el dashboard de crashes que vos mismo provocás iterando.

### Si Firebase no está configurado
La función `initFirebase()` cae al catch silencioso y devuelve `FirebaseSetup()` con todo en `null`. La app funciona normalmente sin tracking. Esto te permite buildear y correr la app antes de hacer `flutterfire configure`.

### iOS Bundle ID y Bundle Name
El Bundle ID en `Info.plist` es `com.xavier.finanzapp` y el `CFBundleName` interno es `finanzapp`. Si Firebase Console te genera un Bundle ID distinto al que tenés en Xcode, va a fallar en runtime. Confirmá que coincida.

### Privacy Policy
El repo ya tiene la Privacy Policy actualizada para mencionar Firebase Crashlytics y Analytics (ver `docs/privacy_policy.md` y `docs/index.html`). Cuando Firebase esté activo en producción, la URL pública refleja eso. Si por alguna razón decidís no usar Firebase, hay que revertir esos cambios.

---

## 11. Costos

Free tier de Firebase para Crashlytics + Analytics: **gratis ilimitado** para apps con < 25K users. Una vez que cruzás eso podés mantener gratis o pasar a Blaze (pay-as-you-go) — en cualquier caso el costo de Crashlytics + Analytics solos sigue siendo ~0.

---

**Última actualización:** 2026-04-30
