# Guía iOS — Apple Developer + App Store Connect

Plan paralelo a Play Store: mientras se resuelve el chargeback de Google, vamos avanzando con iOS para tener la app en App Store.

---

## Resumen

| Paso | Quién | Tiempo | Costo |
|---|---|---|---|
| 1. Crear cuenta Apple Developer | 👤 Vos | 30 min + 24-48h verificación | USD 99/año |
| 2. Configurar Bundle ID y certificados | 🤝 yo guío, vos clickeás | 30 min | — |
| 3. Crear app en App Store Connect | 👤 Vos | 15 min | — |
| 4. Build IPA firmado | 🤖 Yo (con tu cuenta) | 15 min | — |
| 5. Subir a TestFlight | 🤖 Yo (con tu cuenta) | 10 min | — |
| 6. Smoke test en TestFlight | 👤 Vos en device | 30 min | — |
| 7. Submit a App Review | 🤖 Yo + 👤 vos | 15 min | — |
| 8. Espera revisión Apple | — | 24-48h típico | — |

**Total estimado**: 4-7 días desde cero hasta app en App Store.

---

## Estado actual del repo (ya configurado)

| Item | Valor |
|---|---|
| Bundle ID | `com.xavier.finanzapp` |
| Display name | `Finanzapp` |
| iOS deployment target | 13.0 |
| Face ID usage description | ✅ presente |
| Deep link scheme `finanzapp://` | ✅ presente |
| Google Sign-In URL scheme | ✅ presente |
| `ITSAppUsesNonExemptEncryption = false` | ✅ recién agregado (evita pregunta de export compliance) |
| `LSApplicationCategoryType = finance` | ✅ recién agregado |
| Build iOS release-ready | ✅ verificado con `flutter build ios` |

---

## 1. Crear cuenta Apple Developer (👤 vos)

**Costo:** USD 99/año (renovable). Si no pagás el año siguiente, tu app sale del App Store.

### Pasos

1. Andá a https://developer.apple.com/programs/enroll/
2. Login con tu Apple ID. Si no tenés Apple ID o querés uno separado para developer, crealo primero en https://appleid.apple.com.
3. Te va a preguntar tipo de entidad:
   - **Individual / Sole Proprietor** → tu nombre + DNI. **Recomendado** para Finanzapp (más simple, menos docs).
   - **Organization** → necesita D-U-N-S Number, registro de empresa, autorización legal. No vale la pena salvo que tengas SRL/SA.
4. Llenás formulario: nombre legal, dirección, teléfono. Tiene que ser tu info real porque Apple verifica.
5. Pago USD 99 con tarjeta. **Importante**: usá una tarjeta distinta a la del problema con Google si querés evitar cualquier asociación cruzada (paranoia, pero por las dudas).
6. Esperás verificación. **Tiempo típico: 24-48h** (puede ser más rápido si la info está limpia).

### Cuando se aprueba

Recibís email "Welcome to the Apple Developer Program". Desde ese momento:
- Podés acceder a https://developer.apple.com/account
- Podés acceder a https://appstoreconnect.apple.com

Avisame cuando recibas el email y seguimos.

---

## 2. Configurar Bundle ID + certificados (🤝 vos clickeás, yo guío)

### 2.1 Registrar Bundle ID

1. https://developer.apple.com/account → **Identifiers** → **+** (botón add).
2. Tipo: **App IDs** → Continue.
3. Type: **App** → Continue.
4. Description: `Finanzapp`. Bundle ID: **Explicit** = `com.xavier.finanzapp`.
5. Capabilities a habilitar:
   - ✅ **Associated Domains** (futuro: deep links via Universal Links — opcional)
   - ✅ **Push Notifications** (si más adelante querés push remoto; las locales actuales no lo requieren)
   - ❌ Sign in with Apple — solo si decidís agregarlo (recomendado a futuro porque Apple lo exige cuando ofrecés Google Sign-In, ver sección 7).
6. Register.

### 2.2 Certificados (Xcode los gestiona automáticamente)

**No hace falta crear certs manualmente desde la web.** Xcode (con Automatic Signing activado) los crea por vos cuando hacés el primer build. El flow:

1. Abrís el proyecto en Xcode: `open ios/Runner.xcworkspace` (NO abras el `.xcodeproj` solo).
2. Click en `Runner` arriba a la izquierda → tab **Signing & Capabilities**.
3. **Team**: seleccioná tu equipo de developer (recién aparece después de loguearte con tu Apple ID en Xcode → Settings → Accounts).
4. **Bundle Identifier**: tiene que decir `com.xavier.finanzapp`.
5. ✅ **Automatically manage signing** debe estar activo.
6. Xcode genera los certificados y provisioning profiles automáticamente la primera vez.

Yo te guío paso a paso cuando estés en este punto.

---

## 3. Crear app en App Store Connect (👤 vos)

1. https://appstoreconnect.apple.com → **My Apps** → **+** → **New App**.
2. Llenás:
   - **Platforms**: iOS.
   - **Name**: `Finanzapp` (este es el nombre que aparece en la App Store).
   - **Primary Language**: Spanish (Argentina) — `es-AR`.
   - **Bundle ID**: seleccioná `com.xavier.finanzapp` del dropdown (aparece después del paso 2.1).
   - **SKU**: `finanzapp-001` (interno tuyo, no visible al user).
   - **User Access**: Full Access (default).
3. Create.

Ya tenés la app creada en App Store Connect. Ahora hay que llenar el listing (similar a Play Store):

### 3.1 Información del listing — usar los textos pre-redactados

Apple separa la información en varios tabs. Te paso qué va dónde (los textos de Play Store sirven, son casi iguales):

#### **App Information**
- **Subtitle** (max 30 chars): `Gastos fijos sin sorpresas` (26 chars).
- **Category**: Primary = **Finance**, Secondary (optional) = Productivity.
- **Privacy Policy URL**: https://xvirs.github.io/Finanzapp/

#### **Pricing and Availability**
- **Price**: Free.
- **Availability**: All countries (o solo Argentina si querés empezar acotado).

#### **App Privacy** (equivalente al Data Safety de Google)
Mismo contenido que el Data Safety de Play Store. Apple usa una UI distinta pero el mismo concepto. En `docs/play_store_listing.md` sección 4 está el detalle. Puntos clave:
- ✅ Email address (Account management, App functionality)
- ✅ Name (si Google Sign-In)
- ✅ User ID (Account management)
- ✅ Other Financial Info (App functionality)
- ❌ Tracking — **NO**

#### **Version (1.0)** — el listing real
- **Description** (max 4000): el de `docs/play_store_listing.md` sección 3 sirve tal cual.
- **Keywords** (max 100, separados por coma): `gastos,finanzas,presupuesto,tarjetas,cuotas,vencimientos,recordatorio,servicios,suscripciones`.
- **Support URL**: https://github.com/xvirs/Finanzapp (o un mailto:rosales.xavier.eloy@gmail.com)
- **Marketing URL** (opcional): https://xvirs.github.io/Finanzapp/
- **Screenshots**: 6.7" (iPhone 15 Pro Max — 1290×2796) o 6.5" (iPhone 11 Pro Max — 1242×2688). Mínimo 3, máximo 10. Apple es más exigente que Google con el screenshot size.
- **App Icon**: ya está en el Asset Catalog del proyecto (Xcode lo extrae solo).
- **Copyright**: `2026 Xavier Rosales` o `© 2026 Finanzapp`.

#### **Build**
Acá es donde subimos el IPA después. Detallado en sección 4-5.

---

## 4. Build IPA firmado (🤖 yo, con tu Apple ID)

Una vez que tengas:
- Cuenta Apple Developer aprobada.
- Bundle ID registrado (paso 2.1).
- Apple ID logueado en Xcode → Settings → Accounts.

Comandos:

```bash
# Limpiar build anterior
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build IPA con signing automático
flutter build ipa --release

# Output: build/ios/ipa/Finanzapp.ipa
```

Si Xcode tiene tu Apple ID configurado y "Automatically manage signing" activo, el comando funciona sin intervención.

Si falla con error de signing:
- Abrir Xcode con `open ios/Runner.xcworkspace`.
- Tab **Signing & Capabilities** → resolver el error que muestra (típicamente "No team selected" → seleccionás team).
- Re-correr `flutter build ipa --release`.

---

## 5. Subir a TestFlight

Dos formas:

### Opción A — Xcode (visual, recomendada primera vez)

```bash
open build/ios/archive/Runner.xcarchive
```

(Abre Xcode Organizer.) En el panel: click en el archive → **Distribute App** → **App Store Connect** → **Upload** → seguís los wizards (firma, validación). Te avisa cuando se subió.

### Opción B — `xcrun altool` (CLI, mejor para CI/CD)

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/Finanzapp.ipa \
  --apiKey "<API_KEY_ID>" \
  --apiIssuer "<ISSUER_ID>"
```

Necesita una API key de App Store Connect (https://appstoreconnect.apple.com/access/api).

### Después del upload

Apple procesa el build (5-30 min). Cuando termina:
1. https://appstoreconnect.apple.com → tu app → tab **TestFlight**.
2. Vas a ver el build con estado "Processing" → "Ready to Test".
3. **Internal Testing**: agregás tu propio Apple ID como tester. Recibís email con link para descargar TestFlight + tu app.
4. Probás en device real → si OK, avanzás a External Testing o directamente a App Store submission.

---

## 6. Smoke test en TestFlight (👤 vos)

Mismo checklist que Android pero en iOS:
- ✅ Login Google (con nonce — ya lo arreglamos)
- ✅ Login Magic Link (deep link `finanzapp://login-callback`)
- ✅ Crear bill / tarjeta
- ✅ Notificación local (cuenta marcada como pagada con día anterior al actual debería disparar notif a las 9 AM)
- ✅ Face ID lock + unlock
- ✅ Signout + restore session
- ✅ Background → foreground (app lock kicks in después de 60s)

---

## 7. Sign in with Apple — código ya agregado ✅, falta config server

Apple **exige Sign in with Apple** si tu app ofrece login con Google/Facebook/etc. (App Store Review Guideline 4.8). Para evitar rechazo, ya está implementado en código:

- ✅ Package `sign_in_with_apple: ^7.0.1` en `pubspec.yaml`.
- ✅ `auth_repository.signInWithApple()` con nonce flow (igual que Google).
- ✅ Evento `AuthAppleSignInRequested` en el bloc.
- ✅ Botón "Continuar con Apple" en login screen — **solo iOS** (`Platform.isIOS`).
- ✅ `ios/Runner/Runner.entitlements` con `com.apple.developer.applesignin = Default`.
- ✅ `CODE_SIGN_ENTITLEMENTS` apuntando al entitlements file en Debug/Release/Profile.

**Lo que falta para que funcione en runtime** (lo hacés cuando tengas la cuenta Apple Developer activa):

### 7.1 Habilitar capability en App ID

1. https://developer.apple.com/account → **Identifiers** → click en `com.xavier.finanzapp`.
2. Scroll a **Capabilities** → marcar **✅ Sign in with Apple**.
3. **Configure** (botón al lado del checkbox) → dejar como "Enable as a primary App ID" → Save.
4. **Save** abajo.

### 7.2 Crear Service ID + Key para Supabase

Supabase necesita validar el `identityToken` que Apple emite. Para eso requiere:
- Tu **Team ID** (10 chars, en Membership).
- Un **Service ID** (lo creás vos para el server-side flow).
- Una **Key ID** + **Private Key (.p8)** firmada por Apple.

Pasos:

1. **Service ID**: developer.apple.com → Identifiers → `+` → tipo **Services IDs** → Continue.
   - Description: `Finanzapp Auth (Supabase)`.
   - Identifier: `com.xavier.finanzapp.auth` (distinto al Bundle ID).
   - Continue → Register.
   - Re-abrirlo después → **Sign in with Apple** ✅ marcado → **Configure**.
     - Primary App ID: `com.xavier.finanzapp`.
     - Domains and Subdomains: el dominio de tu Supabase (ej `iyuhohfbfhjuiyyrmasj.supabase.co`).
     - Return URLs: `https://iyuhohfbfhjuiyyrmasj.supabase.co/auth/v1/callback`.
     - Save → Continue → Save.

2. **Key**: developer.apple.com → **Keys** → `+`.
   - Name: `Finanzapp Apple Sign-In`.
   - ✅ Marcar **Sign in with Apple** → Configure → Primary App ID = `com.xavier.finanzapp` → Save.
   - Continue → Register.
   - **Download** el `.p8` ahora — Apple no lo deja descargar dos veces. Anotate el **Key ID** (10 chars).

### 7.3 Configurar Apple provider en Supabase

1. https://supabase.com/dashboard/project/iyuhohfbfhjuiyyrmasj/auth/providers
2. Apple → toggle ON.
3. Llenar:
   - **Service ID**: `com.xavier.finanzapp.auth` (el del paso 7.2.1).
   - **Team ID**: tu Team ID.
   - **Key ID**: el del paso 7.2.2.
   - **Secret Key (.p8)**: pegar el contenido del archivo `.p8` (incluye `-----BEGIN PRIVATE KEY-----` y `-----END PRIVATE KEY-----`).
4. Save.

### 7.4 Probar

1. Build iOS y abrí en device.
2. Tap **Continuar con Apple** en login.
3. Sale el sheet nativo de Apple → autenticás con Touch ID / Face ID / password de tu Apple ID.
4. La sesión Supabase queda creada con provider `apple`.

Si algo falla, mirá los logs de Supabase en Auth → Logs.

---

## 8. Cosas a tener listas antes de submitear

- ✅ Privacy Policy URL: https://xvirs.github.io/Finanzapp/
- ✅ Screenshots 6.5" o 6.7" (vos los hacés)
- ✅ App icon 1024×1024 RGB sin alpha (Apple es estricto): `assets/icons/app_icon.png` ya cumple. Si Apple lo rechaza por alpha, lo regeneramos con `convert("RGB")`.
- ✅ Description, keywords, subtitle (en `docs/play_store_listing.md` y arriba).
- ✅ Demo account credentials para reviewers — **NO necesario** porque cualquiera puede crear cuenta gratis con magic link en cualquier email. **Importante**: en el campo "Notes for Reviewer" aclará: *"Use any email to create an account via Magic Link. No demo credentials needed."*
- ⚠️ **Sign in with Apple**: ver sección 7.

---

## 9. Costos totales año 1 (iOS)

| Item | Costo |
|---|---|
| Apple Developer Program | USD 99 |
| App Store fees | 0% para apps gratis |
| **Total año 1** | **USD 99** |

Año 2+: USD 99 anuales (recurrente).

---

**Última actualización:** 2026-04-30
