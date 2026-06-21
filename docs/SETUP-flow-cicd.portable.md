# Setup portable — Sistema de flujo + CI/CD (Flutter, git-flow)

> **Cómo usar este archivo:** copialo al repo destino (ej. Habiturs) y, en Claude Code,
> decile: *"Leé `SETUP-flow-cicd.portable.md` y configurá todo esto en este proyecto"*.
> Claude va a detectar lo específico del proyecto y rellenar los placeholders.
> También podés seguirlo a mano: cada archivo está completo abajo.

Este setup replica el sistema de Finanzapp: comandos de flujo (`/flow`, `/start`,
`/finish`, `/release`) + workflows de GitHub Actions para publicar a las stores, todo
sobre git-flow (`develop` = trabajo, `main` = producción con tags).

---

## Paso 0 — Detectar valores del proyecto (Claude: hacé esto primero)

Antes de escribir archivos, obtené estos valores y usalos para reemplazar los
`<PLACEHOLDERS>` en todo el documento:

| Placeholder | Cómo obtenerlo |
|---|---|
| `<OWNER>/<REPO>` | `git remote get-url origin` (ej. `xvirs/Habiturs`) |
| `<APP_ID>` | `grep applicationId android/app/build.gradle.kts` y `grep PRODUCT_BUNDLE_IDENTIFIER ios/Runner.xcodeproj/project.pbxproj` — **deben coincidir**; si no, avisá |
| `<FLUTTER_VERSION>` | `cat .tool-versions` / `flutter --version` / preguntá al usuario. Usá la misma que usás localmente |
| `<JAVA_VERSION>` | `17` salvo que el proyecto requiera otra |

Verificá también que exista el flujo de ramas: si no hay rama `develop`, creala con
`git checkout -b develop` desde `main` y pusheala, o preguntá al usuario.

> ⚠️ **Bug clásico a evitar:** el `packageName` del workflow de Android DEBE ser el
> `applicationId` real (`<APP_ID>`), no el nombre del repo ni un placeholder. Si no
> coinciden, el upload a Play Store falla con "Package not found".

---

## Paso 1 — Comandos de flujo (`.claude/commands/`)

Agnósticos al stack. Creá estos 4 archivos tal cual (no llevan placeholders salvo
`release.md`, que usa `<OWNER>/<REPO>`).

### `.claude/commands/flow.md`

```markdown
---
description: Menú central del flujo de desarrollo — preguntá qué querés hacer (empezar trabajo, terminar, publicar release) y enrutá al comando correcto.
allowed-tools: Bash, Read, Edit, AskUserQuestion
---

Sos el orquestador del flujo de desarrollo (Flutter, git-flow: `develop` trabajo, `main` producción).

Primero, dale contexto al usuario de dónde está parado: corré `git rev-parse --abbrev-ref HEAD`
(rama actual) y `git status --short` (cambios pendientes), y mostralo en una línea.

Después usá **AskUserQuestion** para preguntar "¿Qué querés hacer?" con estas opciones:

1. **Empezar un trabajo nuevo** — crear una rama para un fix/feature/refactor.
   → Seguí las instrucciones de `.claude/commands/start.md` (leelo y ejecutalo).
2. **Terminar el trabajo actual** — mergear la rama actual a `develop`.
   → Seguí las instrucciones de `.claude/commands/finish.md` (leelo y ejecutalo).
3. **Publicar un release** — bump de versión, `develop→main`, tag y deploy a las stores.
   → Seguí las instrucciones de `.claude/commands/release.md` (leelo y ejecutalo).

Según la opción elegida, leé el archivo de comando correspondiente con la tool Read y ejecutá
ese playbook completo. No reimplementes la lógica acá — el archivo es la fuente de verdad.

Si el usuario ya dijo en `$ARGUMENTS` qué quiere (ej. "empezar", "terminar", "release"),
salteá la pregunta y andá directo al playbook correspondiente.
```

### `.claude/commands/start.md`

```markdown
---
description: Empezar un trabajo nuevo — pregunta el tipo (fix/feature/refactor…) y una descripción, y crea la rama bien nombrada desde develop.
argument-hint: "[tipo] [descripción corta]"
allowed-tools: Bash, Read, AskUserQuestion
---

Sos el asistente de inicio de trabajo (git-flow: las ramas nacen de `develop`).

## Paso 1 — Tipo de trabajo

Si `$ARGUMENTS` ya trae un tipo válido y una descripción, usalos y salteá la pregunta.
Si no, usá **AskUserQuestion** "¿Qué tipo de trabajo es?" con estas opciones (la opción
"Other" que aparece sola cubre los casos menos comunes: docs, perf, test, style):

- **Feature** — funcionalidad nueva. Prefijo de rama `feature/`, commits `feat:`.
- **Fix** — corrección de bug. Prefijo `fix/`, commits `fix:`.
- **Refactor** — reorganizar código sin cambiar comportamiento. Prefijo `refactor/`, commits `refactor:`.
- **Chore** — mantenimiento, deps, config. Prefijo `chore/`, commits `chore:`.

Mapeo tipo → prefijo de rama / tipo de commit:
`feature→feature/ + feat` · `fix→fix/ + fix` · `refactor→refactor/ + refactor` ·
`chore→chore/ + chore` · `docs→docs/ + docs` · `perf→perf/ + perf`.

## Paso 2 — Descripción

Si no vino en `$ARGUMENTS`, pedile al usuario una descripción corta de qué va a hacer
(una frase). De ahí derivá un **slug kebab-case** (minúsculas, sin acentos, palabras con `-`,
máx ~5 palabras). Ej: "rediseño del alta de gasto" → `rediseno-alta-de-gasto`.

Nombre de rama final: `<prefijo>/<slug>` (ej. `feature/rediseno-alta-de-gasto`).

## Paso 3 — Crear la rama (con confirmación)

Mostrale al usuario: tipo, nombre de rama, y el prefijo de commit que va a usar.
Pedí confirmación corta. Tras el OK:

1. `git status --porcelain` — si hay cambios sin commitear, avisá y preguntá antes de cambiar de rama.
2. `git checkout develop`
3. `git fetch origin && git pull --ff-only origin develop` (partir de develop al día).
4. `git checkout -b <prefijo>/<slug>`
5. Confirmá con `git rev-parse --abbrev-ref HEAD`.

## Paso 4 — Reportar

Decile al usuario:
- Que ya está en la rama nueva, lista para trabajar.
- Que use el prefijo de commit correspondiente (`feat:`, `fix:`, etc.) — eso es lo que después
  hace que `/release` deduzca bien si el próximo release es patch/minor/major.
- Que cuando termine, corra `/finish` (o `/flow` → "Terminar") para mergear a `develop`.

Sé conciso.
```

### `.claude/commands/finish.md`

```markdown
---
description: Terminar el trabajo actual — commitea lo pendiente, mergea la rama a develop, la pushea y opcionalmente la borra y/o lanza el release.
allowed-tools: Bash, Read, Edit, AskUserQuestion
---

Sos el asistente de cierre de trabajo (git-flow: las ramas vuelven a `develop`).

## Paso 1 — Validar contexto

- `git rev-parse --abbrev-ref HEAD` — rama actual. Debe ser una rama de trabajo
  (`feature/…`, `fix/…`, `refactor/…`, etc.). Si estás en `develop` o `main`, **frená**:
  no hay nada que cerrar; sugerí `/start` o `/release`.
- `git status --short` — mirá qué hay sin commitear.

## Paso 2 — Commitear lo pendiente

Si hay cambios sin commitear:
- Resumí qué cambió (`git status --short` y, si ayuda, `git diff --stat`).
- Proponé un mensaje conventional acorde al prefijo de la rama
  (ej. rama `feature/x` → `feat: …`; `fix/x` → `fix: …`), con una descripción clara.
- Mostrá el mensaje y pedí confirmación. Tras OK: `git add -A && git commit -m "<mensaje>"`.
- Si no hay cambios pendientes, seguí.

## Paso 3 — Mergear a develop (con confirmación)

Mostrá el plan (rama → develop) y pedí confirmación. Tras OK, en orden, parando si algo falla:

1. `git checkout develop`
2. `git fetch origin && git pull --ff-only origin develop`
3. `git merge --no-ff <rama-de-trabajo> -m "Merge <rama-de-trabajo> into develop"`
4. `git push origin develop`

## Paso 4 — Limpieza (preguntá)

Preguntá si querés borrar la rama de trabajo ya mergeada:
- Local: `git branch -d <rama>`
- Remota (si existía): `git push origin --delete <rama>`

## Paso 5 — ¿Publicar ahora?

Preguntá si querés lanzar un release ya mismo con estos cambios.
- Si sí → leé `.claude/commands/release.md` y ejecutá ese playbook.
- Si no → recordale que cuando junte varios cambios puede correr `/release` (o `/flow` → "Publicar").

Sé conciso: mostrá comandos y resultados, no narres de más.
```

### `.claude/commands/release.md`

> Reemplazá `<OWNER>/<REPO>` por el repo real (ej. `xvirs/Habiturs`).

```markdown
---
description: Publica una nueva versión — analiza commits, bumpea versión, mueve ramas develop→main, crea el tag y dispara el deploy a las stores.
argument-hint: "[patch|minor|major|X.Y.Z] [--dry-run]"
allowed-tools: Bash, Read, Edit
---

Sos el release manager (Flutter, publicada en App Store y/o Play Store).
Tu trabajo: ejecutar un release completo de forma segura, deduciendo todo lo que puedas y
pidiendo confirmación antes de cualquier acción irreversible.

Argumentos recibidos: `$ARGUMENTS`
- Si incluye `patch`, `minor`, `major` o un `X.Y.Z` explícito → usalo como bump (override).
- Si incluye `--dry-run` → hacé SOLO el análisis y mostrá el plan, sin ejecutar nada.
- Si está vacío → deducí el bump de los commits (ver paso 3).

## Flujo de ramas (respetalo)

`develop` = trabajo. `main` = producción, lleva el tag `vX.Y.Z`.
El release se prepara en develop, se mergea a main, se taggea en main, y se sincroniza develop.
El push del tag `v*.*.*` dispara los workflows de release (Android → Play, iOS → App Store Connect).

## Paso 1 — Estado y precondiciones

- `git status --porcelain` — el working tree debe estar limpio. Si hay cambios, frená y mostralos.
- `git rev-parse --abbrev-ref HEAD` — deberías estar en `develop`. Si no, frená y preguntá.
- `git fetch origin --tags`.
- Verificá que `develop` local y `origin/develop` no divergan; si divergen, avisá.

## Paso 2 — Versión actual y último release

- Leé la versión actual de `pubspec.yaml` (línea `version: X.Y.Z+N`).
- Último tag: `git describe --tags --abbrev=0 --match 'v*'`.
- Commits desde el último tag: `git log <ultimo-tag>..HEAD --pretty=format:'%s'`.

## Paso 3 — Deducir el bump (si no vino por argumento)

Clasificá los commits desde el último tag por su prefijo conventional:
- `BREAKING CHANGE` en el body, o `!` después del tipo (ej. `feat!:`) → **major**.
- Algún `feat:` → **minor**.
- Solo `fix:`, `perf:`, `refactor:`, `chore:`, `docs:`, etc. → **patch**.
Tomá el nivel más alto. Ignorá `chore(release):` y merges al clasificar.

Nueva versión = aplicar el bump al `X.Y.Z` actual. **El build number (+N) SIEMPRE incrementa +1**
(si no, las stores rechazan la subida por build repetido). Nuevo tag = `vX.Y.Z`.

## Paso 4 — Mostrar el plan y CONFIRMAR

Presentá: versión actual → nueva, tipo de bump y por qué, changelog agrupado
(Features / Fixes / Otros), y las acciones git exactas. Recordá que el tag dispara deploy
a **producción** en Android y subida a App Store Connect en iOS.

Si es `--dry-run`: terminá acá.
Si no: pedí confirmación explícita ("¿Ejecuto el release vX.Y.Z? [y/N]"). No sigas sin un sí claro.

## Paso 5 — Ejecutar (solo tras confirmación)

1. Verificá que el tag no exista: `git rev-parse vX.Y.Z` debe fallar. Si existe, frená.
2. Bump en develop: editá `version:` de `pubspec.yaml` a `X.Y.Z+N`;
   `git add pubspec.yaml`; `git commit -m "chore(release): X.Y.Z (build N)"`.
3. Merge a main y tag:
   `git checkout main`; `git merge --no-ff develop -m "Merge develop into main for release vX.Y.Z"`;
   `git tag -a vX.Y.Z -m "Release vX.Y.Z"`.
4. Push de producción (DISPARA los workflows): `git push origin main`; `git push origin vX.Y.Z`.
5. Sincronizar develop: `git checkout develop`; `git merge main`; `git push origin develop`.
6. Confirmá que terminaste en `develop`.

## Paso 6 — Reportar

- Link a workflows: https://github.com/<OWNER>/<REPO>/actions
- **Android**: se publica solo en producción al terminar el workflow (después review de Google).
- **iOS**: el build llega a App Store Connect (TestFlight). Apple **obliga a revisión humana** —
  recordale al usuario entrar a https://appstoreconnect.apple.com, seleccionar el build nuevo
  y enviar la versión a revisión (~1 día). No se puede automatizar ese envío.
- Si un workflow falla por secrets faltantes, remití a `docs/cicd_setup.md`.

Sé conciso en la ejecución.
```

---

## Paso 2 — Workflows de GitHub Actions (`.github/workflows/`)

### `.github/workflows/ci.yml`

Reemplazá `<FLUTTER_VERSION>` y `<JAVA_VERSION>`.

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  FLUTTER_VERSION: "<FLUTTER_VERSION>"
  JAVA_VERSION: "<JAVA_VERSION>"

jobs:
  analyze:
    name: Analyze + format check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos

  test:
    name: Tests
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter test
```

### `.github/workflows/release-android.yml`

Reemplazá `<APP_ID>` por el `applicationId` real (¡crítico!) y `<FLUTTER_VERSION>` / `<JAVA_VERSION>`.

```yaml
name: Release Android (Play Store)

# Secrets requeridos (Settings → Secrets and variables → Actions):
#   PLAY_KEYSTORE_BASE64, PLAY_KEYSTORE_PASSWORD, PLAY_KEY_PASSWORD,
#   PLAY_KEY_ALIAS, PLAY_SERVICE_ACCOUNT_JSON

on:
  workflow_dispatch:
    inputs:
      track:
        description: 'Play Store track'
        required: true
        default: 'internal'
        type: choice
        options: [internal, alpha, beta, production]
  push:
    tags: ['v*.*.*']

env:
  FLUTTER_VERSION: "<FLUTTER_VERSION>"
  JAVA_VERSION: "<JAVA_VERSION>"

jobs:
  build-and-upload:
    name: Build AAB + upload to Play Store
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: ${{ env.JAVA_VERSION }}
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

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
      - name: Verify signed AAB
        run: jarsigner -verify build/app/outputs/bundle/release/app-release.aab

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: <APP_ID>
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          # Tag push → production. Dispatch manual → el track elegido (default internal).
          track: ${{ github.event.inputs.track || 'production' }}
          status: completed

      - name: Upload AAB as artifact (backup)
        uses: actions/upload-artifact@v4
        with:
          name: app-release-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 30
```

### `.github/workflows/release-ios.yml`

Reemplazá `<FLUTTER_VERSION>`. Requiere `ios/ExportOptions.plist` (method `app-store`, tu Team ID).
Omití este archivo si Habiturs es **solo Android**.

```yaml
name: Release iOS (App Store / TestFlight)

# Secrets requeridos:
#   APPLE_ID_CERTIFICATE_BASE64, APPLE_ID_CERTIFICATE_PASSWORD,
#   APPLE_ID_PROVISIONING_PROFILE_BASE64, APP_STORE_CONNECT_API_KEY_ID,
#   APP_STORE_CONNECT_API_ISSUER_ID, APP_STORE_CONNECT_API_KEY_BASE64, KEYCHAIN_PASSWORD

on:
  workflow_dispatch:
  push:
    tags: ['v*.*.*']

env:
  FLUTTER_VERSION: "<FLUTTER_VERSION>"

jobs:
  build-and-upload:
    name: Build IPA + upload to TestFlight
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Setup signing keychain
        env:
          CERTIFICATE_BASE64: ${{ secrets.APPLE_ID_CERTIFICATE_BASE64 }}
          CERTIFICATE_PASSWORD: ${{ secrets.APPLE_ID_CERTIFICATE_PASSWORD }}
          PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_ID_PROVISIONING_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          CERT_PATH=$RUNNER_TEMP/cert.p12
          PROFILE_PATH=$RUNNER_TEMP/profile.mobileprovision
          KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
          echo "$CERTIFICATE_BASE64" | base64 -d > $CERT_PATH
          echo "$PROVISIONING_PROFILE_BASE64" | base64 -d > $PROFILE_PATH
          security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security import $CERT_PATH -P "$CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
          security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security list-keychain -d user -s $KEYCHAIN_PATH
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          cp $PROFILE_PATH ~/Library/MobileDevice/Provisioning\ Profiles/

      - run: flutter pub get
      - run: cd ios && pod install && cd ..
      - name: Build IPA
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

      - name: Upload to App Store Connect via altool
        env:
          API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          API_KEY_BASE64: ${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "$API_KEY_BASE64" | base64 -d > ~/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8
          xcrun altool --upload-app --type ios --file build/ios/ipa/*.ipa \
            --apiKey "$API_KEY_ID" --apiIssuer "$API_ISSUER_ID"

      - name: Cleanup keychain (best effort)
        if: always()
        run: security delete-keychain $RUNNER_TEMP/app-signing.keychain-db || true
```

---

## Paso 3 — Script de terminal (opcional): `tool/release.sh`

Alternativa a `/release` para correr en consola. Reemplazá `<OWNER>/<REPO>`.
`chmod +x tool/release.sh` después de crearlo.

```bash
#!/usr/bin/env bash
# tool/release.sh — release de un comando. Uso: ./tool/release.sh patch|minor|major|X.Y.Z
set -euo pipefail
PUBSPEC="pubspec.yaml"
[[ -f "$PUBSPEC" ]] || { echo "❌ Corré desde la raíz del repo." >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "❌ Working tree sucio." >&2; git status --short >&2; exit 1; }
[[ $# -eq 1 ]] || { echo "Uso: ./tool/release.sh <patch|minor|major|X.Y.Z>" >&2; exit 1; }

current="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/version: //' | tr -d '[:space:]')"
name_part="${current%%+*}"; build_part="${current##*+}"
IFS='.' read -r major minor patch <<< "$name_part"
case "$1" in
  patch) patch=$((patch+1));;
  minor) minor=$((minor+1)); patch=0;;
  major) major=$((major+1)); minor=0; patch=0;;
  *.*.*) IFS='.' read -r major minor patch <<< "$1";;
  *) echo "❌ Argumento inválido: '$1'" >&2; exit 1;;
esac
new_name="${major}.${minor}.${patch}"; new_build=$((build_part+1))
new_version="${new_name}+${new_build}"; tag="v${new_name}"
branch="$(git rev-parse --abbrev-ref HEAD)"
echo "  ${current} → ${new_version}   (tag ${tag}, rama ${branch})"
echo "Esto edita pubspec, commitea, taggea y pushea (DISPARA deploy a producción)."
read -r -p "¿Continuar? [y/N] " c; [[ "$c" == "y" || "$c" == "Y" ]] || { echo "Cancelado."; exit 0; }
git rev-parse "$tag" >/dev/null 2>&1 && { echo "❌ El tag $tag ya existe." >&2; exit 1; }
sed -i '' -E "s/^version:.*/version: ${new_version}/" "$PUBSPEC"   # macOS sed; en Linux usá: sed -i -E
git add "$PUBSPEC"; git commit -m "chore(release): ${new_name} (build ${new_build})"
git tag "$tag"; git push origin "$branch"; git push origin "$tag"
echo "✅ Release ${tag} disparado: https://github.com/<OWNER>/<REPO>/actions"
echo "   iOS: entrá a App Store Connect y enviá la versión a revisión."
```

> Nota: este script taggea la rama actual (no hace git-flow `develop→main`). El comando
> `/release` sí hace el flujo de ramas completo — preferí `/release` para releases reales.

---

## Paso 4 — Cargar los secrets en GitHub (lo hace el usuario, una vez)

En el repo: **Settings → Secrets and variables → Actions → New repository secret**.

**Android:**
| Secret | Cómo |
|---|---|
| `PLAY_KEYSTORE_BASE64` | `base64 -i tu-release.jks \| pbcopy` |
| `PLAY_KEYSTORE_PASSWORD` / `PLAY_KEY_PASSWORD` | passwords del keystore |
| `PLAY_KEY_ALIAS` | alias de la clave |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON del service account de Play Console (API access → grant: release to testing + production) |

**iOS** (omitir si es solo Android):
`APPLE_ID_CERTIFICATE_BASE64` (.p12), `APPLE_ID_CERTIFICATE_PASSWORD`,
`APPLE_ID_PROVISIONING_PROFILE_BASE64` (.mobileprovision), `APP_STORE_CONNECT_API_KEY_ID`,
`APP_STORE_CONNECT_API_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_BASE64` (.p8),
`KEYCHAIN_PASSWORD` (`openssl rand -base64 32`).

Detalle completo de cómo generar cada uno: copiá también el `docs/cicd_setup.md` de Finanzapp.

---

## Paso 5 — Verificar y usar

1. Reiniciá Claude Code para que registre los comandos de `.claude/commands/`.
2. Probá sin riesgo: `/release --dry-run` (muestra el plan, no toca nada).
3. Flujo diario: `/flow` → "Empezar" → trabajás → `/flow` → "Terminar" → `/release`.

**Checklist de que quedó bien:**
- [ ] `packageName` del workflow Android == `applicationId` real.
- [ ] Existe rama `develop` (local y remota).
- [ ] `<FLUTTER_VERSION>` coincide con la que usás localmente.
- [ ] Secrets cargados en GitHub.
- [ ] `ExportOptions.plist` presente si hay iOS.
```
