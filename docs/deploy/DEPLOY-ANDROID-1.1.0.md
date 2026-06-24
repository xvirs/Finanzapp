# Deploy Android — Finanzapp v1.1.0

La app está en **fase de prueba** en Google Play (no en producción). "Actualizar" = subir el nuevo AAB al **track de testing** (interna / cerrada) donde están los testers. Es rápido y **no** afecta el estado hacia producción.

| Dato | Valor |
|------|-------|
| Package | `app.finanzapp.client` |
| Cuenta Play Console | `eloy.asdasd@gmail.com` |
| Versión | **1.1.0** · versionCode **4** (en `pubspec.yaml`: `1.1.0+4`) |
| Firma | Play App Signing activo (subís con tu upload key) |

## 0. Pre-flight
- [ ] Build desde **código commiteado/mergeado**.
- [ ] `pubspec.yaml` → `version: 1.1.0+4`. El versionCode `4` **debe ser mayor** al último subido (fue `3`).

## 1. Generar el AAB (desde la raíz del repo)
```bash
flutter clean && flutter pub get
flutter build appbundle --release
```
→ queda en `build/app/outputs/bundle/release/app-release.aab` (versionCode `4`).

## 2. Subir a Play Console (cuenta `eloy.asdasd@gmail.com`)
1. Entrar a la app (paquete `app.finanzapp.client`).
2. **Prueba** → **Prueba interna** (o **Cerrada**, donde tengas los testers).
3. **Crear nueva versión**.
4. Subir el `.aab`.
5. Pegar las **notas de la versión** (abajo).
6. **Revisar versión → Iniciar lanzamiento** a ese track.
7. Los testers reciben la actualización en minutos–horas.

> La prueba interna es casi instantánea; la cerrada puede tener una revisión corta. Subir 1.1.0 a testing **no** mueve el reloj de 14 días / 12 testers para pedir producción (eso es aparte).

## Notas de la versión — 1.1.0 (≤500 caracteres, para Play)
```
Novedades 1.1.0:
• Cargar gastos e ingresos es más simple: elegís la frecuencia y el formulario se adapta. Los montos se formatean con separador de miles mientras escribís.
• Las tarjetas muestran el logo real de cada marca.
• Inicio más claro cuando todavía no cargaste nada, con acceso directo para empezar.
• Animaciones y estados de carga más suaves.
• Correcciones menores y mejoras de estabilidad.
```
