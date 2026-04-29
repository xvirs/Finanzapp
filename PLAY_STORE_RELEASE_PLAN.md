# Plan de Release — Finanzapp v1.0.0 (Play Store)

Roadmap para el primer upload a Google Play. Las etapas están ordenadas
por prioridad: P0 = bloqueante (sin esto el upload se rechaza),
P1 = alto (riesgo real si no se hace), P2 = recomendado.

**Leyenda de responsable:**
- 👤 **Vos** → requiere credenciales, decisiones de cuenta o acceso a consolas externas (Supabase, Play Console, Google Cloud).
- 🤖 **Yo** → cambios de código/config en el repo.
- 🤝 **Mixto** → yo armo el cambio, vos ejecutás la parte que requiere acceso externo.

---

## Etapa 1 — Seguridad backend (P0, ANTES de cualquier otra cosa) — ✅ COMPLETA

| # | Tarea | Responsable | Estado |
|---|---|---|---|
| 1.1 | Auditar RLS en Supabase | 👤 Vos | ✅ Las 4 tablas con `rowsecurity=true` y policy `ALL` con `auth.uid() = user_id` en USING + WITH CHECK |
| 1.2 | SQL de policies si faltan | 🤝 | ✅ N/A — ya estaban correctas |
| 1.3 | Probar con anonKey desde curl | 🤖 Yo | ✅ SELECT/INSERT/UPDATE/DELETE sin auth bloqueados (401 + filas vacías) |

**Validado el 2026-04-29.** El `anonKey` en el APK no representa riesgo: sin JWT válido la API no devuelve datos ni acepta escrituras.

---

## Etapa 2 — Firma release (P0) — ✅ COMPLETA

| # | Tarea | Responsable | Estado |
|---|---|---|---|
| 2.1 | Generar keystore | 👤 Vos | ✅ `~/.keys/finanzapp/finanzapp-release.jks` |
| 2.2 | Backup del keystore | 👤 Vos | ⚠️ **Pendiente: subir el .jks + passwords a 1Password / cloud privado.** Sin backup, si se pierde no se puede actualizar la app nunca más. |
| 2.3 | `android/key.properties` | 👤 Vos | ✅ Creado, gitignoreado |
| 2.4 | `build.gradle.kts` lee el keystore | 🤖 Yo | ✅ Lee key.properties + signing real |
| 2.5 | Verificar AAB firmado | 🤖 Yo | ✅ `jar verified.` con cert `CN=Xavier Rosales, O=Finanzapp, AR` |

---

## Etapa 3 — Hardening Android (P0/P1) — ✅ COMPLETA (smoke test pendiente)

| # | Tarea | Prioridad | Responsable | Estado |
|---|---|---|---|---|
| 3.1 | `android:allowBackup="false"` + `dataExtractionRules.xml` | **P0** | 🤖 Yo | ✅ |
| 3.2 | `targetSdk = 36` explícito en `build.gradle.kts` | **P0** | 🤖 Yo | ✅ |
| 3.3 | ProGuard/R8 release: minify + shrinkResources + `proguard-rules.pro` con keeps para Flutter/Supabase/local_notifications/google_sign_in/biometric | P1 | 🤖 Yo | ✅ |
| 3.4 | `flutter_secure_storage` para session Supabase (Keychain iOS / EncryptedSharedPreferences Android) — bloquea filtración del refresh token | P1 | 🤖 Yo | ✅ |
| 3.5 | Build `flutter build appbundle --release` firmado | P0 | 🤖 Yo | ✅ AAB 47.7 MB, `jar verified.` |
| 3.6 | **Smoke test E2E en device real** (login Google, magic link, crear bill, notificaciones, biometric, signout, restore session) — R8 puede romper plugins en runtime aunque el build pase | **P0** | 👤 Vos | ⏳ |

---

## Etapa 4 — Privacy Policy + Legal (P0)

| # | Tarea | Responsable | Detalle |
|---|---|---|---|
| 4.1 | Redactar Privacy Policy | 🤖 Yo | Plantilla en `docs/privacy_policy.md` cubriendo: email, datos financieros (montos/tarjetas/categorías), Google Sign-In, Supabase como backend, retención y derecho de borrado. |
| 4.2 | Publicar como URL pública | 👤 Vos | Opción más simple: GitHub Pages del repo (gratis). Alternativa: Notion público, Vercel, dominio propio. |
| 4.3 | Decidir Términos de Uso (opcional) | 👤 Vos | Play Store no los exige, pero sí es buena práctica. |

---

## Etapa 5 — Play Console setup (P0)

| # | Tarea | Responsable | Detalle |
|---|---|---|---|
| 5.1 | Crear cuenta Play Console | 👤 Vos | USD 25 one-time. Verificación de identidad puede tardar días. **Empezar ya en paralelo.** |
| 5.2 | Crear app + ficha de tienda | 👤 Vos | Título, descripción corta (80c), descripción larga (4000c), íconos, feature graphic 1024×500, screenshots phone (mínimo 2). |
| 5.3 | Textos de la ficha | 🤝 Yo te paso draft en español, vos ajustás tono y subís. |
| 5.4 | Screenshots | 👤 Vos | Capturas reales de la app (Mes, Tarjetas, Config). Recomendado 9:16 portrait, 1080×1920 o similar. |
| 5.5 | Data Safety form | 🤝 Yo te paso el checklist (qué declarar: email, financial data, auth, Supabase como third-party), vos seleccionás opciones en la consola. |
| 5.6 | Content Rating questionnaire | 👤 Vos | Cuestionario de IARC. Para finanzas suele dar "Apta para todos". |
| 5.7 | Permission Declarations | 👤 Vos | Justificar `SCHEDULE_EXACT_ALARM` ("notificaciones de vencimiento de cuentas en hora exacta"). |
| 5.8 | Target audience | 👤 Vos | Seleccionar 18+ por ser app financiera. |

---

## Etapa 6 — Versión + listing assets (P1)

| # | Tarea | Responsable |
|---|---|---|
| 6.1 | Bump `version: 1.0.0+1` → revisar si querés algo más expresivo en `pubspec.yaml` | 🤝 |
| 6.2 | Generar feature graphic 1024×500 | 👤 Vos (tenés el design system) o 🤖 Yo te lo armo con PIL similar al icon |
| 6.3 | Texto promocional (mantener fresh para updates) | 🤝 |

---

## Etapa 7 — Pre-flight checks (P1)

| # | Tarea | Responsable |
|---|---|---|
| 7.1 | `flutter analyze` clean | 🤖 Yo |
| 7.2 | Probar el `appbundle` con `bundletool` localmente o en Internal Testing track | 🤝 Yo configuro, vos instalás en device real |
| 7.3 | Verificar que el AAB pasa Play App Signing (Internal Testing primero) | 👤 Vos |
| 7.4 | Smoke test del flujo completo en release build (login Google + magic link + crear bill + notificación + biometric + signout) | 👤 Vos |

---

## Etapa 8 — Release (P0 final)

| # | Tarea | Responsable |
|---|---|---|
| 8.1 | Subir a **Internal Testing** primero (10–20 testers, sin review formal) | 👤 Vos |
| 8.2 | Si todo OK → promover a **Closed/Open Testing** o directo a **Production** | 👤 Vos |
| 8.3 | Esperar review (3–7 días la primera vez) | 👤 Vos |

---

## iOS / App Store (futuro, no en este plan)

Cuando quieras encarar iOS: cuenta Apple Developer (USD 99/año), App Store Connect, certificados, TestFlight. Es un plan aparte — el código ya está preparado (Face ID, deep links, NSFaceIDUsageDescription).

---

## Orden sugerido de ejecución

```
HOY:           1.1 + 1.2 + 1.3   (RLS — es el riesgo crítico real)
HOY:           5.1               (creás cuenta Play Console, tarda en verificarse)
ESTA SEMANA:   2.x + 3.x         (firma + hardening — yo te ayudo en paralelo)
ESTA SEMANA:   4.x               (privacy policy)
PRÓXIMA:       5.2-5.8           (listing en Play Console)
PRÓXIMA:       6.x + 7.x         (assets + pre-flight)
PRÓXIMA:       8.x               (Internal Testing → Production)
```

Tiempo realista hasta production: **2–3 semanas**, asumiendo que la
verificación de cuenta Play Console no se traba.
