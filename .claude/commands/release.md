---
description: Publica una nueva versión — analiza commits, bumpea versión, mueve ramas develop→main, crea el tag y dispara el deploy a las stores.
argument-hint: "[patch|minor|major|X.Y.Z] [--dry-run]"
allowed-tools: Bash, Read, Edit
---

Sos el release manager de Finanzapp (Flutter + Supabase, publicada en App Store y Play Store).
Tu trabajo: ejecutar un release completo de forma segura, deduciendo todo lo que puedas y
pidiendo confirmación antes de cualquier acción irreversible.

Argumentos recibidos: `$ARGUMENTS`
- Si incluye `patch`, `minor`, `major` o un `X.Y.Z` explícito → usalo como bump (override).
- Si incluye `--dry-run` → hacé SOLO el análisis y mostrá el plan, sin ejecutar nada.
- Si está vacío → deducí el bump de los commits (ver paso 3).

## Flujo de ramas de este repo (respetalo)

`develop` = rama de trabajo. `main` = producción, lleva el tag `vX.Y.Z`.
El release se prepara en develop, se mergea a main, se taggea en main, y se sincroniza develop.
El push del tag `v*.*.*` dispara `release-android.yml` (→ Play producción) y
`release-ios.yml` (→ App Store Connect/TestFlight).

## Paso 1 — Estado y precondiciones

Corré y analizá:
- `git status --porcelain` — el working tree debe estar limpio. Si hay cambios, **frená** y
  mostráselos al usuario; preguntá si commitea/descarta antes de seguir. (Nota: `ios/Podfile.lock`
  y `.claude/settings.local.json` suelen aparecer modificados — si son los únicos, avisá pero
  podés ofrecer seguir.)
- `git rev-parse --abbrev-ref HEAD` — deberías estar en `develop`. Si no, frená y preguntá.
- `git fetch origin --tags` — sincronizá tags y refs remotos.
- Verificá que `develop` local no esté detrás de `origin/develop` (`git log origin/develop..develop`
  y viceversa). Si divergen, avisá antes de seguir.

## Paso 2 — Versión actual y último release

- Leé la versión actual de `pubspec.yaml` (línea `version: X.Y.Z+N`).
- Último tag: `git describe --tags --abbrev=0 --match 'v*'`.
- Commits desde el último tag: `git log <ultimo-tag>..HEAD --pretty=format:'%s'`.
  - Si el último tag es viejo y `main` quedó desincronizado de releases previos (caso conocido:
    `v1.1.0` nunca se taggeó), mencionalo — este release va a poner todo al día.

## Paso 3 — Deducir el bump (si no vino por argumento)

Clasificá los commits desde el último tag por su prefijo conventional:
- Algún `BREAKING CHANGE` en el body, o `!` después del tipo (ej. `feat!:`) → **major**.
- Algún `feat:` / `feat(scope):` → **minor**.
- Solo `fix:`, `perf:`, `refactor:`, `chore:`, `docs:`, etc. → **patch**.
Tomá el nivel más alto presente. Ignorá los commits `chore(release):` y merges al clasificar.

Nueva versión = aplicar el bump al `X.Y.Z` actual. **El build number (+N) SIEMPRE incrementa +1**
(si no, las stores rechazan la subida por build repetido). Nuevo tag = `vX.Y.Z`.

## Paso 4 — Mostrar el plan y CONFIRMAR

Presentá al usuario, claro y en español:
- Versión actual → nueva versión (con build number).
- Tipo de bump y por qué (qué commits lo justifican).
- **Changelog agrupado** en Features / Fixes / Otros, a partir de los commits.
- Las acciones git exactas que vas a ejecutar (bump, commit, merge a main, tag, pushes).
- Recordatorio: el tag dispara deploy a **producción** en Android y subida a App Store Connect en iOS.

Si es `--dry-run`: terminá acá. No ejecutes nada más.
Si no: **pedí confirmación explícita** ("¿Ejecuto el release vX.Y.Z? [y/N]"). No sigas sin un sí claro.

## Paso 5 — Ejecutar (solo tras confirmación)

En orden, parando y reportando si algún comando falla:

1. Verificá que el tag no exista: `git rev-parse vX.Y.Z` debe fallar. Si existe, frená.
2. Bump en develop:
   - Editá la línea `version:` de `pubspec.yaml` a `X.Y.Z+N`.
   - `git add pubspec.yaml`
   - `git commit -m "chore(release): X.Y.Z (build N)"`
3. Merge a main y tag:
   - `git checkout main`
   - `git merge --no-ff develop -m "Merge develop into main for release vX.Y.Z"`
   - `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
4. Push de producción (esto DISPARA los workflows):
   - `git push origin main`
   - `git push origin vX.Y.Z`
5. Sincronizar develop con main y volver:
   - `git checkout develop`
   - `git merge main`  (debería ser fast-forward)
   - `git push origin develop`
6. Confirmá que terminaste en `develop` con `git rev-parse --abbrev-ref HEAD`.

## Paso 6 — Reportar

- Link a los workflows: https://github.com/xvirs/Finanzapp/actions
- **Android**: se publica solo en producción cuando termine el workflow (después review de Google).
- **iOS**: el build llega a App Store Connect (TestFlight). Apple **obliga a revisión humana** —
  recordale al usuario entrar a https://appstoreconnect.apple.com, seleccionar el build nuevo
  y enviar la versión a revisión (~1 día). No hay forma de automatizar ese envío a producción.
- Si algún workflow falla por secrets faltantes, remití a `docs/cicd_setup.md`.

Sé conciso en la ejecución: mostrá los comandos y sus resultados, no narres de más.
