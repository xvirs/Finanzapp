# 📦 DEPLOY MAESTRO — Flutter → App Store + Play Store, de cero y automatizado

> Guía **autocontenida** para arrancar un proyecto Flutter nuevo y dejarlo con:
> deploy firmado a **ambas stores** + **actualizaciones automatizadas** por CI, sin
> tropezar con los muros típicos.
>
> Estructura: **Fase 0** (fundaciones, una sola vez) → **Fase 1** (CI/CD) →
> **Fase 2** (secrets) → **Fase 3** (deploy y updates). Al final: gotchas + checklist.
>
> Reemplazá los `<PLACEHOLDERS>` por los valores de tu proyecto.

---

## 🧭 Mapa rápido

| Necesito… | Fase |
|---|---|
| Firmar la app (keystore Android / cert iOS) | Fase 0 |
| Registrar la app en las stores | Fase 0 |
| Que el CI compile y suba solo | Fase 1 + 2 |
| Publicar una actualización con un comando | Fase 3 |
| Que no me falle como la primera vez | Gotchas |

**Costos:** Apple Developer **US$99/año** · Google Play **US$25 (pago único)**.

---

# FASE 0 — Fundaciones (una sola vez por proyecto)

## 0.A — Identificadores base
Definí el **ID único** de tu app (debe ser el MISMO en Android e iOS):
- Android `applicationId` en `android/app/build.gradle.kts`
- iOS `PRODUCT_BUNDLE_IDENTIFIER` en `ios/Runner.xcodeproj/project.pbxproj`

Formato recomendado: `app.<tuapp>.client` (evitá `com.<tunombre>.*` si puede estar
reservado por otro Team de Apple — pasa y te obliga a renombrar TODO).

## 0.B — Android: firma (keystore)

**1. Generar el keystore** (guardalo FUERA del repo, ej. `~/.keys/<app>/`):
```bash
keytool -genkey -v -keystore ~/.keys/<app>/release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias <app>
```
Anotá el **storePassword**, **keyPassword** y **alias**. Backup del `.jks` + passwords
en un lugar seguro (si lo perdés, **no podés volver a actualizar la app** en Play).

**2. `android/key.properties`** (GITIGNOREALO):
```properties
storePassword=<store_pass>
keyPassword=<key_pass>
keyAlias=<app>
storeFile=/ruta/absoluta/a/release.jks
```

**3. Cargar la firma en `android/app/build.gradle.kts`:**
```kotlin
import java.util.Properties
import java.io.FileInputStream
// … arriba del android { }:
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystore = keystorePropertiesFile.exists()
if (hasKeystore) keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
  defaultConfig { applicationId = "<APP_ID>"; targetSdk = 36 /*…*/ }
  signingConfigs {
    if (hasKeystore) create("release") {
      keyAlias = keystoreProperties["keyAlias"] as String
      keyPassword = keystoreProperties["keyPassword"] as String
      storeFile = file(keystoreProperties["storeFile"] as String)
      storePassword = keystoreProperties["storePassword"] as String
    }
  }
  buildTypes {
    release {
      signingConfig = if (hasKeystore) signingConfigs.getByName("release")
                      else signingConfigs.getByName("debug") // fallback dev
      isMinifyEnabled = true
      isShrinkResources = true
      proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
  }
}
```

**4. Crear la app en Play Console** (play.google.com/console) → "Crear aplicación" →
completar ficha, política de contenido, clasificación, Data Safety, etc. Primer
release: subir un AAB (aunque sea a **prueba interna**) para inicializar la app.

## 0.C — iOS: firma + registro (necesitás Apple Developer activo)

**1. Registrar el App ID / Bundle ID:** developer.apple.com → Certificates, IDs &
Profiles → **Identifiers** → `+` → App ID → **Explicit** = `<APP_ID>` → habilitar
capabilities que uses (Sign in with Apple, Push, etc.).

**2. Certificado de distribución (`.p12`):**
- En Xcode: Settings → Accounts → tu Apple ID → **Manage Certificates** → `+` →
  **Apple Distribution**. Después, click derecho → **Export** → guarda un `.p12` con password.
- (O manual con CSR en developer.apple.com → Certificates → Apple Distribution).

**3. Provisioning profile (App Store):** developer.apple.com → **Profiles** → `+` →
**App Store** → elegí tu App ID + el cert de distribution → descargá el `.mobileprovision`.

**4. `ios/ExportOptions.plist`** (commitealo — necesario para `flutter build ipa` sin device):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>app-store</string>
  <key>teamID</key><string><TEAM_ID></string>
  <key>uploadBitcode</key><false/>
  <key>uploadSymbols</key><true/>
  <key>signingStyle</key><string>manual</string>
  <key>signingCertificate</key><string>Apple Distribution</string>
  <key>provisioningProfiles</key><dict>
    <key><APP_ID></key><string><NOMBRE_DEL_PROFILE></string>
  </dict>
  <key>destination</key><string>export</string>
</dict></plist>
```
(`<TEAM_ID>`: developer.apple.com → Membership. `<NOMBRE_DEL_PROFILE>`: el nombre exacto del profile del paso 3.)

**5. Crear la app en App Store Connect** (appstoreconnect.apple.com) → Apps → `+` →
elegí el Bundle ID → completá listing, privacidad, screenshots, etc.

**6. App Store Connect API key** (para que el CI suba): App Store Connect → **Users
and Access → Integrations → App Store Connect API → Claves del equipo** → **Generar**
(rol *App Manager*) → **descargá el `.p8` (¡una sola vez!)**. Anotá **Key ID** (del nombre
`AuthKey_XXXX.p8`) e **Issuer ID** (UUID arriba de la lista).
> ⚠️ NO confundir con la key de **Sign in with Apple** (esa es para login, no para subir).

## 0.D — (Opcional) Firebase
Si usás Firebase (Crashlytics/Analytics): `dart pub global activate flutterfire_cli`
y `flutterfire configure`. Esto agrega `firebase_options.dart`, los `google-services.json`/
`GoogleService-Info.plist`, y **un build phase de Xcode que llama al CLI `flutterfire`**
(recordá el gotcha #2 en Fase 1).

---

# FASE 1 — CI/CD (GitHub Actions + comandos de flujo)

Git-flow: **`develop`** = trabajo, **`main`** = producción (lleva el tag `vX.Y.Z`).
El push de un tag `v*.*.*` dispara los workflows de release.

## 1.A — Comandos de Claude Code (`.claude/commands/`)
4 archivos que orquestan el flujo (agnósticos al stack). Su contenido completo está en
**`SETUP-flow-cicd.portable.md`** (copialo también). Resumen:
- **`/flow`** — menú: Empezar / Terminar / Publicar.
- **`/start`** — pregunta tipo (fix/feature/…) + descripción → crea rama `<prefijo>/<slug>` desde develop.
- **`/finish`** — commitea + mergea la rama a develop.
- **`/release [patch|minor|major|X.Y.Z] [--dry-run]`** — bumpea versión+build, `develop→main`, tag, push (dispara deploy).

## 1.B — Workflows (`.github/workflows/`) — CON LOS FIXES YA APLICADOS

**`ci.yml`** (sin secrets): en push/PR a main y develop → `dart format --set-exit-if-changed`,
`flutter analyze --fatal-infos`, `flutter test`.

**`release-android.yml`** (secrets: `PLAY_KEYSTORE_BASE64`, `PLAY_KEYSTORE_PASSWORD`,
`PLAY_KEY_PASSWORD`, `PLAY_KEY_ALIAS`, `PLAY_SERVICE_ACCOUNT_JSON`):
```yaml
on:
  workflow_dispatch: { inputs: { track: { type: choice, default: internal,
    options: [internal, alpha, beta, production] } } }
  push: { tags: ['v*.*.*'] }
jobs:
  build-and-upload:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: "17" }
      - uses: subosito/flutter-action@v2
        with: { flutter-version: "<FLUTTER_VERSION>", channel: stable, cache: true }
      - run: echo "${{ secrets.PLAY_KEYSTORE_BASE64 }}" | base64 -d > $RUNNER_TEMP/release.jks
      - run: |
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.PLAY_KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.PLAY_KEY_PASSWORD }}
          keyAlias=${{ secrets.PLAY_KEY_ALIAS }}
          storeFile=$RUNNER_TEMP/release.jks
          EOF
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: <APP_ID>
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: ${{ github.event.inputs.track || 'alpha' }}   # ⚠️ ver gotcha #4
          status: completed
```

**`release-ios.yml`** (secrets: `APPLE_ID_CERTIFICATE_BASE64`, `APPLE_ID_CERTIFICATE_PASSWORD`,
`APPLE_ID_PROVISIONING_PROFILE_BASE64`, `APP_STORE_CONNECT_API_KEY_ID`,
`APP_STORE_CONNECT_API_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_BASE64`, `KEYCHAIN_PASSWORD`):
```yaml
on: { workflow_dispatch: {}, push: { tags: ['v*.*.*'] } }
jobs:
  build-and-upload:
    runs-on: macos-26   # ⚠️ gotcha #1: Xcode 26+ obligatorio por Apple
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: "<FLUTTER_VERSION>", channel: stable, cache: true }
      - name: Setup signing keychain
        env: { CERTIFICATE_BASE64: "${{ secrets.APPLE_ID_CERTIFICATE_BASE64 }}",
               CERTIFICATE_PASSWORD: "${{ secrets.APPLE_ID_CERTIFICATE_PASSWORD }}",
               PROVISIONING_PROFILE_BASE64: "${{ secrets.APPLE_ID_PROVISIONING_PROFILE_BASE64 }}",
               KEYCHAIN_PASSWORD: "${{ secrets.KEYCHAIN_PASSWORD }}" }
        run: |
          CERT=$RUNNER_TEMP/c.p12; PROF=$RUNNER_TEMP/p.mobileprovision; KC=$RUNNER_TEMP/a.keychain-db
          echo "$CERTIFICATE_BASE64" | base64 -d > $CERT
          echo "$PROVISIONING_PROFILE_BASE64" | base64 -d > $PROF
          security create-keychain -p "$KEYCHAIN_PASSWORD" $KC
          security set-keychain-settings -lut 21600 $KC
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KC
          security import $CERT -P "$CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k $KC
          security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KC
          security list-keychain -d user -s $KC
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          cp $PROF ~/Library/MobileDevice/Provisioning\ Profiles/
      - run: flutter pub get
      - name: Install FlutterFire CLI   # ⚠️ gotcha #2 (si usás Firebase)
        run: dart pub global activate flutterfire_cli && echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
      - run: cd ios && pod install && cd ..
      - run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
      - env: { API_KEY_ID: "${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}",
               API_ISSUER_ID: "${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}",
               API_KEY_BASE64: "${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}" }
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "$API_KEY_BASE64" | base64 -d > ~/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8
          xcrun altool --upload-app --type ios --file build/ios/ipa/*.ipa \
            --apiKey "$API_KEY_ID" --apiIssuer "$API_ISSUER_ID"
```

---

# FASE 2 — Cargar secrets (con `gh`, sin exponerlos)

`brew install gh` → `gh auth login` (web browser) → cargá desde tus archivos locales:
```bash
REPO="<OWNER>/<REPO>"
# --- Android ---
base64 -i ~/.keys/<app>/release.jks | gh secret set PLAY_KEYSTORE_BASE64 --repo $REPO
printf 'STORE_PASS' | gh secret set PLAY_KEYSTORE_PASSWORD --repo $REPO
printf 'KEY_PASS'   | gh secret set PLAY_KEY_PASSWORD --repo $REPO
printf 'ALIAS'      | gh secret set PLAY_KEY_ALIAS --repo $REPO
gh secret set PLAY_SERVICE_ACCOUNT_JSON --repo $REPO < service-account.json
# --- iOS ---
base64 -i distribution.p12          | gh secret set APPLE_ID_CERTIFICATE_BASE64 --repo $REPO
printf 'P12_PASS'                   | gh secret set APPLE_ID_CERTIFICATE_PASSWORD --repo $REPO
base64 -i App_Store.mobileprovision | gh secret set APPLE_ID_PROVISIONING_PROFILE_BASE64 --repo $REPO
printf 'KEY_ID'                     | gh secret set APP_STORE_CONNECT_API_KEY_ID --repo $REPO
printf 'ISSUER_ID'                  | gh secret set APP_STORE_CONNECT_API_ISSUER_ID --repo $REPO
base64 -i AuthKey_KEYID.p8          | gh secret set APP_STORE_CONNECT_API_KEY_BASE64 --repo $REPO
openssl rand -base64 32 | tr -d '\n'| gh secret set KEYCHAIN_PASSWORD --repo $REPO
gh secret list --repo $REPO   # verificar (deben ser 12)
```

### Service account de Play (lo más enredado — la página "Acceso a la API" a veces rebota)
1. **Google Cloud Console** → crear proyecto (ej. `<app>-play`).
2. **IAM → Cuentas de servicio → Crear** (nombre `play-uploader`, sin rol) → Listo.
3. Click en la cuenta → **Claves → Agregar clave → JSON** → descarga el `.json`. Copiá su **email**.
4. Habilitar API: `console.cloud.google.com/apis/library/androidpublisher.googleapis.com?project=<app>-play` → **Habilitar**.
5. **Play Console → Usuarios y permisos → Invitar usuario** → pegá el email → **Administrador**.

---

# FASE 3 — Deploy y actualizaciones automatizadas

**Primer deploy / cada actualización, desde Claude Code:**
1. `/flow` → Empezar → trabajás → `/flow` → Terminar (mergea a develop).
2. `/release patch` (o `minor`/`major`). Confirmás. Automático:
   - bumpea versión **y build number** en `pubspec.yaml`
   - `develop → main`, crea tag `vX.Y.Z`, pushea → **dispara los 2 workflows**
3. **Android** → sube al track configurado (arranca en `alpha`/prueba cerrada).
4. **iOS** → sube a App Store Connect. **Paso manual final:** appstoreconnect.apple.com →
   versión → asignar build → **Enviar a revisión** (Apple, ~24-48h). No se automatiza.

**Versionado:** el build number (`+N` en `pubspec.yaml`) **siempre** sube — Apple/Google
rechazan un build repetido. El comando `/release` lo maneja solo.

---

# ⚠️ GOTCHAS (los muros que te ahorra esta guía)

1. **iOS runner = `macos-26`** (Xcode 26+). Apple exige el SDK más reciente para subir;
   runners viejos → error **409 "SDK version issue"**. También resuelve errores de **Swift 6**
   en dependencias (`Cannot find type 'sending'`).
2. **`flutterfire: command not found`** en el build iOS (si usás Firebase): el workflow debe
   instalar el CLI (`dart pub global activate flutterfire_cli` + PATH) antes del build.
3. **`.claude/settings.local.json` gitignored.** Si está trackeado, se modifica solo y
   **bloquea los `git checkout` a mitad del release**. `git rm --cached` + gitignore.
4. **Android: no publiques a `production` a ciegas.** Si la app está en prueba cerrada, el push
   a `production` falla ("Precondition check failed"). Cuentas **personales** de Play necesitan
   **12 testers / 14 días** + solicitar acceso a producción antes de habilitarla. Publicá al
   track real (`alpha`) mientras tanto. **Verificá el track con la API** (script abajo).
5. **`packageName` (workflow Android) == `applicationId` real.** Si no, "Package not found".
6. **2 claves Apple distintas:** Sign in with Apple key (login) ≠ App Store Connect API key (subir builds).
7. **`dart format`:** el CI falla si hay archivos sin formatear (reglas nuevas del formatter).
   Corré `dart format .` y commiteá antes de releasear.
8. **iOS review es manual** siempre. Android production requiere acceso habilitado por Google.

### Verificar el track real de Play (antes de elegir track)
```bash
JSON=service-account.json; APPID=<APP_ID>
python3 -c "import json;open('/tmp/k.pem','w').write(json.load(open('$JSON'))['private_key'])"
CE=$(python3 -c "import json;print(json.load(open('$JSON'))['client_email'])")
now=$(python3 -c "import time;print(int(time.time()))"); exp=$((now+3600))
b64(){ openssl base64 -e -A | tr '+/' '-_' | tr -d '='; }
jh=$(printf '%s' '{"alg":"RS256","typ":"JWT"}'|b64)
jc=$(printf '%s' "{\"iss\":\"$CE\",\"scope\":\"https://www.googleapis.com/auth/androidpublisher\",\"aud\":\"https://oauth2.googleapis.com/token\",\"exp\":$exp,\"iat\":$now}"|b64)
sig=$(printf '%s' "$jh.$jc"|openssl dgst -sha256 -sign /tmp/k.pem|b64)
TK=$(curl -s -X POST https://oauth2.googleapis.com/token -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jh.$jc.$sig"|python3 -c "import sys,json;print(json.load(sys.stdin)['access_token'])")
EID=$(curl -s -X POST -H "Authorization: Bearer $TK" "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$APPID/edits"|python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")
curl -s -H "Authorization: Bearer $TK" "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$APPID/edits/$EID/tracks"|python3 -m json.tool; rm -f /tmp/k.pem
```

---

# ✅ CHECKLIST MAESTRO (nuevo proyecto)

**Fundaciones**
- [ ] `applicationId` == Bundle ID (mismo en Android e iOS)
- [ ] Keystore Android generado + backup seguro + `key.properties` gitignoreado
- [ ] `build.gradle.kts` con signingConfig release + minify
- [ ] App creada en Play Console (primer AAB subido para inicializar)
- [ ] Apple: App ID registrado + cert distribution (`.p12`) + provisioning profile
- [ ] `ios/ExportOptions.plist` con tu Team ID y nombre de profile
- [ ] App creada en App Store Connect
- [ ] App Store Connect API key generada (`.p8` + Key ID + Issuer ID)
- [ ] (Si Firebase) `flutterfire configure` corrido

**CI/CD**
- [ ] 4 comandos en `.claude/commands/` (de `SETUP-flow-cicd.portable.md`)
- [ ] 3 workflows en `.github/workflows/` (con `macos-26` + flutterfire + track correcto)
- [ ] Rama `develop` creada
- [ ] `.claude/settings.local.json` gitignored + destrackeado
- [ ] 12 secrets cargados (`gh secret list`)
- [ ] Service account de Play creado, API habilitada, invitado en Play Console

**Primer release**
- [ ] `dart format .` aplicado y commiteado
- [ ] Track Android verificado con el script (no `production` a ciegas)
- [ ] `/release --dry-run` para revisar el plan
- [ ] `/release patch` → workflows en verde
- [ ] iOS: enviar a revisión manual en App Store Connect

---

**Doc companion:** `SETUP-flow-cicd.portable.md` (contenido completo de los 4 comandos y
los workflows YAML verbatim). Llevá ambos a tu proyecto nuevo.
