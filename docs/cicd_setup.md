# Guía CI/CD — GitHub Actions

Tres workflows configurados en `.github/workflows/`:

| Workflow | Cuándo corre | Necesita secrets | Estado |
|---|---|---|---|
| `ci.yml` | En cada push y PR a `main` | ❌ No | ✅ Activable ahora |
| `release-android.yml` | Manual / push tag `v*.*.*` | ✅ Sí (Play) | ⏳ Esperando cuenta Play activa |
| `release-ios.yml` | Manual / push tag `v*.*.*` | ✅ Sí (Apple) | ⏳ Esperando cuenta Apple activa |

---

## Workflow 1 — `ci.yml` (sin secrets, podés activarlo YA)

Hace en cada push/PR:
- ✅ `dart format --set-exit-if-changed` (verifica que el código esté formateado).
- ✅ `flutter analyze --fatal-infos`.
- ✅ `flutter test`.
- ✅ Build APK debug (verifica que compile).

**Activación**: solo hace falta hacer push del workflow. GitHub Actions detecta el archivo y arranca automáticamente. Sin secrets necesarios.

Próximas mejoras posibles (no críticas):
- `build-ios-debug` job en macOS runner (más caro en minutos pero verifica compile iOS).
- Coverage report con `lcov`.

---

## Workflow 2 — `release-android.yml`

### Disparadores

```bash
# Manual (con elección de track):
# Settings → Actions → Release Android → Run workflow → elegir track

# Auto al pushear tag:
git tag v1.0.1
git push origin v1.0.1
```

### Secrets a cargar

En el repo: **Settings → Secrets and variables → Actions → New repository secret**.

| Secret | Cómo obtenerlo |
|---|---|
| `PLAY_KEYSTORE_BASE64` | `base64 -i ~/.keys/finanzapp/finanzapp-release.jks \| pbcopy` y pegás. |
| `PLAY_KEYSTORE_PASSWORD` | El storePassword del `.jks` (lo tenés en `android/key.properties` y en 1Password). |
| `PLAY_KEY_PASSWORD` | El keyPassword del alias. |
| `PLAY_KEY_ALIAS` | `finanzapp` |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON completo del service account de Play (ver paso siguiente). |

### Crear el Service Account de Play Console

1. Play Console → **Setup → API access**.
2. Si es la primera vez: **Create a new Google Cloud Project** o linkea uno existente.
3. **Service accounts** → **Create new service account** → te lleva a Google Cloud Console.
4. En Cloud Console: nombre `finanzapp-play-uploader` → Create.
5. Role: **Service Account User**.
6. Después de crearlo: click en el SA → **Keys** tab → **Add Key → JSON** → descargás el JSON.
7. Volvés a Play Console → API access → tu SA aparece pendiente. Click **Grant access**:
   - Permissions: **Releases → Release to testing tracks** + **Release to production**.
   - Apps: tu app `Finanzapp`.
8. Save.
9. Copiás el contenido completo del JSON descargado → secret `PLAY_SERVICE_ACCOUNT_JSON`.

### Probar

1. Ir a **Actions → Release Android → Run workflow** → elegir `internal` track.
2. Esperá ~10 min.
3. Verificá en Play Console → tu app → Internal Testing → debería aparecer el build nuevo.

---

## Workflow 3 — `release-ios.yml`

### Pre-requisitos

- Apple Developer activo con tu cuenta.
- App registrada en App Store Connect con Bundle ID `com.xavier.finanzapp`.
- Cert de distribution + provisioning profile generados en Xcode (la primera vez es manual desde Xcode con tu Apple ID logueado).

### Secrets a cargar

| Secret | Cómo obtenerlo |
|---|---|
| `APPLE_ID_TEAM_ID` | https://developer.apple.com/account → Membership → Team ID (10 chars alfanuméricos). |
| `APPLE_ID_CERTIFICATE_BASE64` | Exportar tu cert "Apple Distribution" desde Xcode → Settings → Accounts → Manage Certificates → click derecho → Export. Da un `.p12` con password. Después: `base64 -i cert.p12 \| pbcopy`. |
| `APPLE_ID_CERTIFICATE_PASSWORD` | La password que pusiste al exportar el `.p12`. |
| `APPLE_ID_PROVISIONING_PROFILE_BASE64` | https://developer.apple.com/account → Profiles → seleccionar tu profile App Store → download `.mobileprovision` → `base64 -i profile.mobileprovision \| pbcopy`. |
| `APP_STORE_CONNECT_API_KEY_ID` | https://appstoreconnect.apple.com/access/api → click en tu key → Key ID (10 chars). |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Misma página, arriba de la lista de keys. |
| `APP_STORE_CONNECT_API_KEY_BASE64` | El `.p8` que descargaste al crear la API key (se descarga UNA SOLA VEZ). `base64 -i AuthKey_XXX.p8 \| pbcopy`. |
| `KEYCHAIN_PASSWORD` | Password temporal random para el keychain del runner. `openssl rand -base64 32 \| pbcopy`. |

### Crear API key de App Store Connect

1. https://appstoreconnect.apple.com/access/api
2. Tab **Keys** → **+** (botón).
3. Name: `finanzapp-ci`. Access: **App Manager** (suficiente para upload, no permite borrar app).
4. Generate. **Descargás el `.p8` AHORA** — Apple no te lo deja descargar dos veces.

### Crear ExportOptions.plist (necesario para `flutter build ipa`)

Cuando el workflow corra `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist`, necesita ese archivo. Tenemos dos opciones:

- **A**: lo creás vos una sola vez localmente (con tu Team ID hardcodeado) y lo commitás. Más simple.
- **B**: el workflow lo genera dinámicamente desde `APPLE_ID_TEAM_ID`. Más seguro pero más yaml.

**Recomendación: opción A.** Te paso el archivo plantilla cuando tengas el Team ID:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>TU_TEAM_ID_AQUI</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

Reemplazás `TU_TEAM_ID_AQUI` y lo guardás como `ios/ExportOptions.plist`.

### Probar

1. Actions → Release iOS → Run workflow.
2. ~20 min (iOS builds son lentos).
3. App Store Connect → tu app → TestFlight → ves el build aparecer en "Processing" → "Ready to Test".

---

## Coreografía de un release completo (cuando todo esté armado)

```bash
# 1. Bump version en pubspec.yaml
# version: 1.0.1+2

# 2. Commit + tag
git add pubspec.yaml
git commit -m "chore: bump version 1.0.1"
git tag v1.0.1
git push origin main
git push origin v1.0.1

# 3. Los workflows release-android.yml y release-ios.yml se disparan
#    automáticamente por el tag push. En ~30 min:
#    - Play Store Internal Testing tiene el build nuevo
#    - App Store Connect TestFlight tiene el build nuevo

# 4. Después de smoke test en ambas:
#    - Play Console → promoter de Internal a Production (UI manual o
#      pre-configurado como `track: production` en el workflow input).
#    - App Store Connect → submit for review.
```

---

## Costos

| Item | Costo mensual |
|---|---|
| GitHub Actions free tier | 2000 min/mes en runners Linux + 500 min en macOS |
| macOS runner | 10x el costo de Linux (cada minuto cuenta x10). Un build iOS típico = 15 min ≈ 150 min cobrados. |
| Linux runner | Build Android ~10 min ≈ 10 min cobrados. |

**Estimación realista** para un release/semana: ~700 min/mes equivalentes. **Free tier alcanza** para repos personales.

---

## Próximos pasos sugeridos

1. **Hoy**: hacer push de los workflows. El `ci.yml` empieza a correr y verifica cada PR/push.
2. **Cuando Play Console esté activa**: cargar los 5 secrets de Play y probar `release-android.yml` manual.
3. **Cuando Apple Developer esté activo**: cargar los 7 secrets de Apple, crear `ExportOptions.plist`, probar `release-ios.yml` manual.
4. **Producción**: empezás a usar tags `v*.*.*` y los releases se automatizan.

---

**Última actualización:** 2026-04-30
