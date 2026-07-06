# 🚀 Setup CI/CD + Flujo de release (Flutter · git-flow) — Guía battle-tested

> Guía portable para replicar en otro proyecto Flutter el sistema de:
> comandos `/flow` `/start` `/finish` `/release` + workflows de GitHub Actions
> que publican a **Play Store** y **App Store Connect**.
>
> **Cómo usarla:** copiá este archivo al repo destino y, en Claude Code, decí:
> *"Leé `SETUP-flow-cicd.portable.md` y configurá todo esto"*. O seguila a mano.
>
> Incluye los **gotchas reales** que hicieron fallar el primer deploy, ya resueltos.

---

## ⚠️ LÉEME PRIMERO — Gotchas que te van a ahorrar horas

Estos son los muros con los que choqué en el primer deploy. Ya vienen resueltos en
los templates de abajo, pero entendé por qué:

1. **iOS: el runner DEBE ser `macos-26` (o el que traiga el Xcode más nuevo).**
   Apple exige compilar con el **SDK de iOS más reciente** (Xcode 26+). Runners viejos
   (`macos-14`/`macos-15` con Xcode 15/16) fallan el upload con error **409 "SDK version issue"**.

2. **iOS: si usaste `flutterfire configure` (Firebase), hay un build phase que llama al CLI `flutterfire`.**
   En tu Mac está global, pero en el CI no → el build de Xcode falla con
   `flutterfire: command not found`. Solución: instalar el CLI en el workflow
   (`dart pub global activate flutterfire_cli` + agregar `~/.pub-cache/bin` al PATH) antes del build.

3. **iOS: dependencias modernas pueden requerir Swift 6.** Otro motivo más para `macos-26`
   (los errores tipo `Cannot find type 'sending'` son Swift 6; runner viejo = Swift 5 = falla).

4. **Android: NO publiques a `production` sin verificar.** Si la app está en **prueba cerrada**,
   el push a `track: production` falla con **"Precondition check failed"**. Para **cuentas personales**
   de Play (creadas post nov-2023) Google exige **12 testers / 14 días** + solicitar acceso a
   producción ANTES de habilitarla. Mientras tanto, publicá al track real (`alpha` = prueba cerrada).
   👉 Verificá el track real con la API (script al final) en vez de asumir.

5. **`.claude/settings.local.json` debe estar gitignored.** Si está trackeado, se modifica solo
   con cada permiso nuevo y **bloquea los `git checkout` a mitad del release**
   (`error: Your local changes would be overwritten by checkout`). Gitignoralo y destrackealo:
   ```bash
   echo ".claude/settings.local.json" >> .gitignore
   git rm --cached .claude/settings.local.json
   ```

6. **Cuidado con 2 claves Apple distintas que se confunden:**
   - **Sign in with Apple key** (`.p8`, para login OAuth/Supabase) — NO sirve para subir builds.
   - **App Store Connect API key** (`.p8`, en App Store Connect → Users and Access → Integrations) — ESTA
     es la que usa el CI para subir. Si "Activa (0)", generá una nueva (ver más abajo).

7. **iOS siempre tiene un paso manual final:** el CI sube a App Store Connect/TestFlight, pero
   **enviar a revisión** es manual en appstoreconnect.apple.com (Apple no lo automatiza). Tarda ~24-48h.

8. **El `packageName` del workflow Android debe ser el `applicationId` real**, no el nombre del repo.
   Si no coinciden → "Package not found".

---

## Paso 0 — Detectar valores del proyecto

| Placeholder | Cómo obtenerlo |
|---|---|
| `<OWNER>/<REPO>` | `git remote get-url origin` |
| `<APP_ID>` | `grep applicationId android/app/build.gradle.kts` (debe == `PRODUCT_BUNDLE_IDENTIFIER` de iOS) |
| `<FLUTTER_VERSION>` | la que usás local (`flutter --version`) |

Asegurá que exista la rama `develop` (`git checkout -b develop` desde `main` si no).

---

## Paso 1 — Comandos de flujo (`.claude/commands/`)

Agnósticos al stack. 4 archivos. (Reemplazá `<OWNER>/<REPO>` en `release.md`.)

<details><summary><b>.claude/commands/flow.md</b> (menú central)</summary>

```markdown
---
description: Menú central del flujo — preguntá qué hacer y enrutá al comando correcto.
allowed-tools: Bash, Read, Edit, AskUserQuestion
---
Sos el orquestador del flujo (git-flow: develop trabajo, main producción).
Mostrá rama actual (`git rev-parse --abbrev-ref HEAD`) y `git status --short`.
Usá AskUserQuestion "¿Qué querés hacer?":
1. Empezar trabajo → leé y ejecutá `.claude/commands/start.md`
2. Terminar trabajo → leé y ejecutá `.claude/commands/finish.md`
3. Publicar release → leé y ejecutá `.claude/commands/release.md`
Si $ARGUMENTS ya dice qué (empezar/terminar/release), salteá la pregunta.
```
</details>

<details><summary><b>.claude/commands/start.md</b> (crear rama)</summary>

```markdown
---
description: Empezar trabajo — pregunta tipo (fix/feature/refactor…) + descripción y crea la rama desde develop.
argument-hint: "[tipo] [descripción corta]"
allowed-tools: Bash, Read, AskUserQuestion
---
1. Tipo (AskUserQuestion, opciones Feature/Fix/Refactor/Chore; "Other" cubre docs/perf/test):
   feature→feature/+feat · fix→fix/+fix · refactor→refactor/+refactor · chore→chore/+chore · docs→docs/+docs · perf→perf/+perf
2. Descripción → slug kebab-case (≤5 palabras, sin acentos). Rama = `<prefijo>/<slug>`.
3. Con confirmación: `git checkout develop && git fetch origin && git pull --ff-only origin develop && git checkout -b <prefijo>/<slug>`.
4. Recordá usar el prefijo de commit (feat:/fix:…) — de ahí /release deduce el bump.
```
</details>

<details><summary><b>.claude/commands/finish.md</b> (merge a develop)</summary>

```markdown
---
description: Terminar trabajo — commitea pendiente, mergea la rama a develop, limpia y opcionalmente lanza release.
allowed-tools: Bash, Read, Edit, AskUserQuestion
---
1. Validar: estar en rama de trabajo (no develop/main). Si no, frená.
2. Commitear pendiente con mensaje conventional según prefijo de la rama (con confirmación).
3. Con confirmación: `git checkout develop && git fetch origin && git pull --ff-only origin develop && git merge --no-ff <rama> -m "Merge <rama> into develop" && git push origin develop`.
4. Preguntar si borrar la rama (local `git branch -d`, remota `git push origin --delete`).
5. Preguntar si publicar ahora → leé `.claude/commands/release.md`.
```
</details>

<details><summary><b>.claude/commands/release.md</b> (release completo)</summary>

```markdown
---
description: Publica versión — analiza commits, bumpea, develop→main, tag, dispara deploy.
argument-hint: "[patch|minor|major|X.Y.Z] [--dry-run]"
allowed-tools: Bash, Read, Edit
---
Argumentos: $ARGUMENTS (bump explícito, o --dry-run para solo plan).
Flujo de ramas: develop trabajo, main producción con tag vX.Y.Z. El push del tag dispara los workflows.

PASO 1 — Precondiciones: `git status --porcelain` limpio; estar en develop; `git fetch origin --tags`; chequear que develop no diverja de origin.
PASO 2 — Versión actual (pubspec `version: X.Y.Z+N`); último tag (`git describe --tags --abbrev=0 --match 'v*'`); commits desde el tag.
PASO 3 — Deducir bump: BREAKING/`!`→major; `feat`→minor; resto→patch. Ignorar `chore(release):` y merges. El build number (+N) SIEMPRE +1.
PASO 4 — Mostrar plan + changelog agrupado + acciones git. Si --dry-run, terminar. Si no, pedir confirmación explícita (dispara deploy).
PASO 5 — Ejecutar: bump pubspec → commit `chore(release): X.Y.Z (build N)` en develop → `git checkout main && git merge --no-ff develop` → `git tag -a vX.Y.Z` → `git push origin main && git push origin vX.Y.Z` → `git checkout develop && git merge main && git push origin develop`.
PASO 6 — Reportar: link a https://github.com/<OWNER>/<REPO>/actions. Android → track alpha (prod requiere acceso de Google). iOS → llega a App Store Connect; enviar a revisión es MANUAL en appstoreconnect.apple.com.
```
</details>

---

## Paso 2 — Workflows (`.github/workflows/`) — YA CON LOS FIXES

### `ci.yml` (sin secrets)
```yaml
name: CI
on:
  push: { branches: [main, develop] }
  pull_request: { branches: [main, develop] }
env:
  FLUTTER_VERSION: "<FLUTTER_VERSION>"
  JAVA_VERSION: "17"
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: "${{ env.FLUTTER_VERSION }}", channel: stable, cache: true }
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: "${{ env.FLUTTER_VERSION }}", channel: stable, cache: true }
      - run: flutter pub get
      - run: flutter test
```
> 💡 CI corre `dart format --set-exit-if-changed`: si tu versión de Dart trae reglas nuevas,
> archivos viejos pueden fallar. Corré `dart format .` y commiteá antes de releasear.

### `release-android.yml`
Secrets: `PLAY_KEYSTORE_BASE64`, `PLAY_KEYSTORE_PASSWORD`, `PLAY_KEY_PASSWORD`, `PLAY_KEY_ALIAS`, `PLAY_SERVICE_ACCOUNT_JSON`.
```yaml
name: Release Android (Play Store)
on:
  workflow_dispatch:
    inputs:
      track:
        description: 'Play Store track'
        default: 'internal'
        type: choice
        options: [internal, alpha, beta, production]
  push: { tags: ['v*.*.*'] }
env: { FLUTTER_VERSION: "<FLUTTER_VERSION>", JAVA_VERSION: "17" }
jobs:
  build-and-upload:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: "${{ env.JAVA_VERSION }}" }
      - uses: subosito/flutter-action@v2
        with: { flutter-version: "${{ env.FLUTTER_VERSION }}", channel: stable, cache: true }
      - name: Decode keystore
        run: |
          echo "${{ secrets.PLAY_KEYSTORE_BASE64 }}" | base64 -d > $RUNNER_TEMP/release.jks
          echo "KEYSTORE_PATH=$RUNNER_TEMP/release.jks" >> $GITHUB_ENV
      - name: Create key.properties
        run: |
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.PLAY_KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.PLAY_KEY_PASSWORD }}
          keyAlias=${{ secrets.PLAY_KEY_ALIAS }}
          storeFile=${{ env.KEYSTORE_PATH }}
          EOF
      - run: flutter pub get
      - run: flutter build appbundle --release
      - run: jarsigner -verify build/app/outputs/bundle/release/app-release.aab
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: <APP_ID>
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          # ⚠️ 'alpha' = prueba cerrada. Cambiá a 'production' SOLO cuando Google
          # te haya habilitado producción (ver gotcha #4).
          track: ${{ github.event.inputs.track || 'alpha' }}
          status: completed
```

### `release-ios.yml`
Secrets: `APPLE_ID_CERTIFICATE_BASE64`(.p12), `APPLE_ID_CERTIFICATE_PASSWORD`, `APPLE_ID_PROVISIONING_PROFILE_BASE64`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_BASE64`(.p8), `KEYCHAIN_PASSWORD`.
Requiere `ios/ExportOptions.plist` (method `app-store`, tu Team ID). Omitir si es solo Android.
```yaml
name: Release iOS (App Store / TestFlight)
on:
  workflow_dispatch:
  push: { tags: ['v*.*.*'] }
env: { FLUTTER_VERSION: "<FLUTTER_VERSION>" }
jobs:
  build-and-upload:
    runs-on: macos-26   # ⚠️ Xcode 26+ obligatorio por Apple (gotcha #1)
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: "${{ env.FLUTTER_VERSION }}", channel: stable, cache: true }
      - name: Setup signing keychain
        env:
          CERTIFICATE_BASE64: ${{ secrets.APPLE_ID_CERTIFICATE_BASE64 }}
          CERTIFICATE_PASSWORD: ${{ secrets.APPLE_ID_CERTIFICATE_PASSWORD }}
          PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_ID_PROVISIONING_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          CERT=$RUNNER_TEMP/cert.p12; PROF=$RUNNER_TEMP/p.mobileprovision; KC=$RUNNER_TEMP/app.keychain-db
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
      # ⚠️ gotcha #2: build phase de Crashlytics necesita el CLI flutterfire
      - name: Install FlutterFire CLI
        run: |
          dart pub global activate flutterfire_cli
          echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
      - run: cd ios && pod install && cd ..
      - run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
      - name: Upload to App Store Connect
        env:
          API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          API_KEY_BASE64: ${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "$API_KEY_BASE64" | base64 -d > ~/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8
          xcrun altool --upload-app --type ios --file build/ios/ipa/*.ipa \
            --apiKey "$API_KEY_ID" --apiIssuer "$API_ISSUER_ID"
      - if: always()
        run: security delete-keychain $RUNNER_TEMP/app.keychain-db || true
```

---

## Paso 3 — Cargar secrets (rápido, con `gh`, sin exponerlos)

Lo más eficiente: instalar `gh` (`brew install gh`), `gh auth login` (web browser), y cargar
desde tus archivos locales (los valores van de tu disco a GitHub, nunca al chat):

```bash
REPO="<OWNER>/<REPO>"
# Android
base64 -i ruta/al/release.jks | gh secret set PLAY_KEYSTORE_BASE64 --repo $REPO
printf 'STORE_PASS'  | gh secret set PLAY_KEYSTORE_PASSWORD --repo $REPO
printf 'KEY_PASS'    | gh secret set PLAY_KEY_PASSWORD --repo $REPO
printf 'ALIAS'       | gh secret set PLAY_KEY_ALIAS --repo $REPO
gh secret set PLAY_SERVICE_ACCOUNT_JSON --repo $REPO < ruta/al/service-account.json
# iOS
base64 -i distribution.p12            | gh secret set APPLE_ID_CERTIFICATE_BASE64 --repo $REPO
printf 'P12_PASS'                     | gh secret set APPLE_ID_CERTIFICATE_PASSWORD --repo $REPO
base64 -i App_Store.mobileprovision   | gh secret set APPLE_ID_PROVISIONING_PROFILE_BASE64 --repo $REPO
printf 'KEY_ID'                       | gh secret set APP_STORE_CONNECT_API_KEY_ID --repo $REPO
printf 'ISSUER_ID'                    | gh secret set APP_STORE_CONNECT_API_ISSUER_ID --repo $REPO
base64 -i AuthKey_KEYID.p8            | gh secret set APP_STORE_CONNECT_API_KEY_BASE64 --repo $REPO
openssl rand -base64 32 | tr -d '\n'  | gh secret set KEYCHAIN_PASSWORD --repo $REPO
gh secret list --repo $REPO   # verificar
```

### Cómo obtener cada cosa (lo que más cuesta)

**App Store Connect API key** (NO la de Sign in with Apple): appstoreconnect.apple.com →
**Users and Access → Integrations → App Store Connect API → Claves del equipo**. Si "Activa (0)",
**Generar clave** (rol *App Manager*). Descargá el `.p8` (¡una sola vez!). El **Key ID** sale del
nombre `AuthKey_XXXX.p8`. El **Issuer ID** está arriba de la lista (UUID).

**Service account de Play** (es lo más enredado — la página "Acceso a la API" a veces rebota):
1. **Google Cloud Console** → crear proyecto (ej. `tuapp-play`).
2. **IAM → Cuentas de servicio → Crear** (nombre `play-uploader`, sin rol) → **Listo**.
3. Clic en la cuenta → **Claves → Agregar clave → JSON** → descarga el `.json`. Copiá su **email**.
4. Habilitar la API: `console.cloud.google.com/apis/library/androidpublisher.googleapis.com?project=tuapp-play` → **Habilitar**.
5. **Play Console → Usuarios y permisos → Invitar usuario** → pegá el email → permiso **Administrador**.

**Apple cert + provisioning** (.p12 + .mobileprovision): exportar el cert "Apple Distribution"
desde Xcode (Settings → Accounts → Manage Certificates → Export, con password) y bajar el
App Store provisioning profile de developer.apple.com.

---

## Paso 4 — Verificar el track real de Play (no asumir)

Antes de elegir track, consultá qué tiene tu app realmente (con el service account JSON):
```bash
JSON=ruta/al/service-account.json; APPID=<APP_ID>
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
Mirá qué track tiene `versionCodes`. Ese es donde vive tu app → usá ese track en el workflow.

---

## Paso 5 — Usar el sistema

1. **Reiniciá Claude Code** para que registre los comandos de `.claude/commands/`.
2. Probá sin riesgo: `/release --dry-run`.
3. Día a día: `/flow` → Empezar → trabajás → `/flow` → Terminar → `/release patch`.
4. iOS: tras el deploy, entrá a App Store Connect → versión → asigná build → **Enviar a revisión**.

### Checklist primer deploy
- [ ] `.claude/settings.local.json` gitignored + destrackeado (gotcha #5)
- [ ] `packageName` Android == `applicationId` real
- [ ] Runner iOS = `macos-26`; paso de `flutterfire_cli` presente (si usás Firebase)
- [ ] Track Android = el real (verificado con script del Paso 4), NO `production` a ciegas
- [ ] 12 secrets cargados (`gh secret list`)
- [ ] `ExportOptions.plist` presente (si hay iOS)
- [ ] `dart format .` aplicado y commiteado (para que CI no quede en rojo)
- [ ] Existe rama `develop`

### Camino a producción en Play (cuenta personal)
12+ testers en prueba cerrada / 14 días corridos → Play Console → tu app → **Producción** →
**Solicitar acceso a producción** → cuando Google habilite, cambiá `track` a `production` en el workflow.
```
