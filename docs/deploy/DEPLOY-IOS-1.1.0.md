# Deploy iOS — Finanzapp v1.1.0

La app **ya está publicada** en la App Store → subir `1.1.0` es una **actualización que pasa por revisión** de Apple.

| Dato | Valor |
|------|-------|
| App Store Connect App ID | `6767990905` |
| Bundle ID | `app.finanzapp.client` |
| Versión | **1.1.0** · build **4** (en `pubspec.yaml`: `1.1.0+4`) |
| Firma | manual local — keychain `finanzapp-build` + profile "Finanzapp App Store", ya configurados en este Mac |

> ⚠️ Los secrets de firma (passwords, .p12) NO están en este archivo. Si la firma local se rompió o venció, está documentada en las notas del proyecto. Cert y profile vencen 2027-05-15.

## 0. Pre-flight
- [ ] Build desde **código commiteado/mergeado** (no working tree sucio).
- [ ] `pubspec.yaml` → `version: 1.1.0+4`. El build `4` **debe ser mayor** al último subido (fue `2`).

## 1. Generar el `.ipa` (desde la raíz del repo)
```bash
flutter clean && flutter pub get

rm -rf build/ios/archive
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release \
  -archivePath build/ios/archive/Runner.xcarchive \
  -destination "generic/platform=iOS" \
  OTHER_CODE_SIGN_FLAGS="--keychain finanzapp-build.keychain" \
  archive

rm -rf build/ios/ipa
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist
```
→ el `.ipa` queda en `build/ios/ipa/Mi Finanzapp.ipa`

## 2. Subir
1. Abrir **Transporter** (Mac).
2. Arrastrar el `.ipa` → **Deliver**.
3. Esperar ~10–30 min a que App Store Connect procese el build.

## 3. App Store Connect
1. Entrar a la app (ID `6767990905`) → tocar **“+ Version or Platform”** → crear versión **1.1.0**.
2. Pegar el **“What's New”** (abajo).
3. En **Build**, seleccionar `1.1.0 (4)` ya procesado.
4. Screenshots / descripción: solo si cambiaron (si no, se reusan).
5. **Add for Review → Submit**. Elegir publicación automática o manual.
6. Revisión de updates: ~1–2 días.

## “What's New” — 1.1.0 (pegar en App Store Connect)
```
Mejoras para que cargar tus cuentas sea más rápido y claro:

• Cargar gastos e ingresos es más simple: elegís la frecuencia (mes a mes o una sola vez) y el formulario se adapta a lo que necesitás.
• Los montos se formatean con separador de miles a medida que escribís.
• Las tarjetas ahora muestran el logo real de cada marca.
• La pantalla de inicio es más clara cuando todavía no cargaste nada, con un acceso directo para registrar tu primer gasto.
• Animaciones y estados de carga más suaves.
• Correcciones menores y mejoras de estabilidad.
```
