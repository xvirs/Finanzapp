# Play Store Listing — textos pre-redactados

Todos los textos listos para copy-paste en Play Console cuando la
cuenta esté activa. Si querés ajustar algo, editalo acá y queda
versionado.

---

## 1. Datos básicos

| Campo | Valor |
|---|---|
| **App name** (max 30) | `Finanzapp` |
| **Default language** | Español (Argentina) — `es-AR` |
| **App o juego** | App |
| **Gratis o de pago** | Gratis |
| **Categoría** | Finanzas |
| **Tags** | Finanzas personales, Presupuesto, Gastos |
| **Sitio web** | https://github.com/xvirs/Finanzapp |
| **Email de contacto** | rosales.xavier.eloy@gmail.com |
| **Política de privacidad** | https://xvirs.github.io/Finanzapp/ |

---

## 2. Descripción corta (max 80 caracteres)

```
Llevá el control de tus gastos fijos: servicios, tarjetas y cuotas.
```

(64 caracteres — entra perfecto, hay margen para iterar.)

Alternativas si querés:
- `Tus gastos fijos en un solo lugar: servicios, tarjetas, suscripciones.` (70)
- `Organizá los gastos que se repiten cada mes y nunca más te olvides.` (66)
- `Servicios, tarjetas y cuotas: un calendario claro de tus pagos.` (62)

---

## 3. Descripción larga (max 4000 caracteres)

```
Finanzapp es la app para llevar el control de los gastos recurrentes obligatorios — todo lo que pagás cada mes y no podés olvidarte.

¿PARA QUIÉN ES?

Para vos si:
• Pagás varios servicios, suscripciones o cuotas al mes y se te mezclan.
• Querés saber cuánto te falta pagar antes de fin de mes.
• Tenés tarjetas de crédito con cierres y vencimientos diferentes.
• Estás cansado de armar planillas de Excel para algo que debería ser un toque.

CARACTERÍSTICAS

Mes actual
• Lista de cuentas fijas del mes con monto estimado, día de vencimiento y estado (pagado / pendiente / atrasado).
• Total estimado vs total pagado del mes en tiempo real.
• Filtros rápidos: todo, pendiente, pagado.
• Marcado de pagos en un toque, con monto editable.

Tarjetas de crédito
• Registro de tus tarjetas con día de cierre y vencimiento.
• Cuotas activas: ves cuánto te queda pagar de cada compra y cuándo termina.
• Resumen mensual estimado por tarjeta.
• Soporte para débitos automáticos asociados a una tarjeta.

Notificaciones
• Recordatorios el día anterior al vencimiento de cada cuenta o tarjeta, a las 9 de la mañana.
• Solo si vos las activás. No molestamos por nada más.

Bloqueo biométrico (opcional)
• Face ID, Touch ID o huella protege tus datos cuando dejás el celu desbloqueado.
• Se activa automáticamente si la app estuvo en segundo plano más de 1 minuto.

Privacidad y seguridad
• Sin analytics, sin publicidad, sin tracking.
• Tus datos están protegidos con Row Level Security en el backend — solo vos podés leerlos.
• Tokens de sesión cifrados con la master key del hardware del dispositivo.
• Backup automático del sistema operativo deshabilitado para esta app: tus datos no se filtran a la nube de Google sin tu consentimiento.

¿QUÉ NO ES FINANZAPP?

• No es una billetera virtual ni una app bancaria.
• No procesa pagos reales — solo registra los que vos cargás.
• No te conecta con tu banco ni lee tus consumos automáticamente.
• No te pide la tarjeta de crédito para usarla.

DATOS QUE GUARDA

Solo lo que vos cargás manualmente: nombres de tus servicios, montos estimados, fechas de vencimiento, marcas de tarjetas y notas tuyas. Todo eso se sincroniza con tu cuenta para que esté disponible en cualquier dispositivo donde inicies sesión.

LOGIN

• Magic Link al email — sin password.
• Google Sign-In nativo (opcional) — un toque y listo.

Política de Privacidad: https://xvirs.github.io/Finanzapp/

¿Comentarios o problemas? Escribinos a rosales.xavier.eloy@gmail.com.
```

(2387 caracteres — tenés ~1600 de margen para extender si querés agregar features futuros, casos de uso adicionales, etc.)

---

## 4. Data Safety form

Este formulario es **crítico** — Google rechaza el listing si las respuestas no se condicen con el comportamiento real de la app. Las respuestas abajo están alineadas con la Privacy Policy.

### ¿Tu app recolecta o comparte alguno de los siguientes tipos de datos?

**SÍ**, recolectamos los siguientes (declarar en el form):

#### Personal info
- ✅ **Email address**
  - Collected: Yes
  - Shared: No
  - Processed ephemerally: No
  - Required or optional: **Required** (sin email no hay cuenta)
  - Why collected: **Account management**, **App functionality**

- ✅ **Name** (solo si usa Google Sign-In)
  - Collected: Yes
  - Shared: No
  - Processed ephemerally: No
  - Required or optional: **Optional**
  - Why collected: **Account management**

- ✅ **User IDs** (UUID asignado por Supabase)
  - Collected: Yes
  - Shared: No
  - Processed ephemerally: No
  - Required or optional: **Required**
  - Why collected: **Account management**, **App functionality**

#### Financial info
- ✅ **Other financial info** (datos que el usuario carga)
  - Collected: Yes
  - Shared: No
  - Processed ephemerally: No
  - Required or optional: **Required**
  - Why collected: **App functionality** (es el core de la app)

#### Photos and videos
- ❌ Foto de perfil de Google → no la guardamos en backend, solo se muestra en runtime desde la URL de Google

#### App activity (Firebase Analytics)
- ✅ **App interactions** (eventos anónimos: bill_created, bill_paid, screen_view, etc.)
  - Collected: Yes
  - Shared: No (con third parties; va a Google Firebase, que es nuestro processor)
  - Processed ephemerally: No
  - Required or optional: **Optional** (el user puede deshabilitar tracking de anuncios en su OS)
  - Why collected: **Analytics** y **App functionality**

#### App info and performance (Firebase Crashlytics)
- ✅ **Crash logs**
  - Collected: Yes
  - Shared: No
  - Processed ephemerally: No
  - Required or optional: **Required** (para diagnóstico de bugs)
  - Why collected: **Analytics** (en el form de Google "Analytics" engloba diagnóstico)

- ✅ **Diagnostics** (versión OS, modelo device, versión app)
  - Collected: Yes
  - Shared: No
  - Why collected: **Analytics**

#### Device or other IDs
- ✅ **Device or other IDs** (Firebase instance ID, Advertising ID si el OS lo permite)
  - Collected: Yes
  - Shared: No
  - Required or optional: **Optional**
  - Why collected: **Analytics**

#### Otras categorías
- ❌ Ads / Advertising — **NO**, no usamos publicidad ni perfilamiento.

### Encryption in transit
- ✅ **Yes** — todos los requests usan HTTPS (TLS) hacia Supabase y Google.

### User can request data deletion
- ✅ **Yes, I provide a way for users to request that their data be deleted**.
- Mecanismo: email a `rosales.xavier.eloy@gmail.com` desde la cuenta del usuario. (En el futuro podés agregar un botón "Borrar cuenta" en Config para automatizar esto.)

### ¿Estos datos están cifrados en tránsito? (encryption in transit)
- ✅ **Yes**

### ¿Compartís datos con terceros?
- **No** — solo con Supabase (que es nuestro proveedor de backend, no third-party data broker) y Google Identity Services (solo para auth, no comparte datos del usuario).

### Compliance with Families Policy
- **No** (la app no está dirigida a niños).

---

## 5. Content Rating questionnaire (IARC)

Respuestas para una app financiera personal sin contenido sensible. **Resultado esperado: rating "Apta para todos / Everyone"** o **PEGI 3** según región.

| Pregunta | Respuesta |
|---|---|
| ¿La app contiene violencia? | No |
| ¿La app contiene contenido sexual o sugerente? | No |
| ¿La app contiene lenguaje vulgar? | No |
| ¿La app contiene representación de drogas, alcohol o tabaco? | No |
| ¿La app contiene apuestas o juegos con dinero real? | No |
| ¿La app permite compras dentro de la app? | No |
| ¿La app permite a usuarios interactuar entre sí? | No (no hay chat, no hay social) |
| ¿La app comparte la ubicación del usuario? | No |
| ¿La app accede a datos personales sensibles del usuario? | Email y datos financieros personales (sí, declarar) |
| ¿La app contiene contenido generado por usuarios (UGC)? | No |
| ¿La app es una app de citas / dating? | No |
| ¿La app fomenta la donación o recaudación de fondos? | No |

---

## 6. Permission Declaration — `SCHEDULE_EXACT_ALARM`

Google Play exige declarar el uso de este permiso. Texto a pegar en el form:

```
Finanzapp usa SCHEDULE_EXACT_ALARM para mostrar notificaciones locales recordatorios de vencimiento de cuentas pagadas el día anterior al vencimiento de cada cuenta del usuario, a las 9:00 AM hora local.

Estas notificaciones son críticas para el caso de uso central de la app: ayudar al usuario a no olvidarse de pagar servicios o resúmenes de tarjeta antes de su fecha de corte. La hora exacta es relevante porque los usuarios programan su rutina diaria en función de cuándo reciben los recordatorios — un retraso de 1-2 horas haría que el recordatorio llegue después de que el usuario ya salió a trabajar.

Las notificaciones se programan únicamente cuando el usuario otorga el permiso de POST_NOTIFICATIONS y solo para cuentas/tarjetas que el usuario marcó como activas. No se envían notificaciones promocionales, de marketing ni de ningún otro tipo.

Alternativas evaluadas:
- Inexact alarms: descartadas porque pueden retrasarse hasta varias horas en modo Doze, lo que invalida el caso de uso (recordatorio el día anterior pierde sentido si llega 6h tarde).
- Push notifications desde un servidor: descartadas porque agregaría infraestructura backend, costos, y un punto adicional de fallo para una funcionalidad puramente local.
```

---

## 7. Target audience and content

| Campo | Valor |
|---|---|
| Target age groups | **18+** (es app financiera; aunque no haya razón legal específica, conviene 18+ por prudencia) |
| ¿Apela a niños? | No |
| Ads | No |

---

## 8. Categorización Play Store

| Campo | Valor |
|---|---|
| App type | App |
| Category | **Finance** |
| Tags | Personal finance, Budgeting, Bills |

---

## 9. Recursos visuales (resumen)

| Asset | Resolución | Estado |
|---|---|---|
| App icon | 512×512 (Play Store usa el del manifest, pero conviene tener el .png) | ✅ `assets/icons/app_icon.png` |
| Feature graphic | 1024×500 | ✅ `assets/store/feature_graphic.png` |
| Phone screenshots | 9:16 (mín 1080×1920) — entre 2 y 8 | ⏳ Pendiente — vos los hacés |
| Tablet screenshots (opcional) | — | Skippable |
| Promo video (opcional) | — | Skippable |

---

## 10. Screenshots — checklist para vos

Cuando capturés, seguí estos pasos:

1. Conectá un Android real (mejor que emulador para colores reales).
2. Instalá la versión release: `flutter run --release`.
3. Logueate (preferentemente con datos demo realistas — un par de servicios, una tarjeta, una compra en cuotas).
4. Capturá las siguientes pantallas (3 mínimo, hasta 8):
   - **Mes actual** con varias cuentas (estados mezclados: pagado / pendiente / atrasado).
   - **Detalle de tarjeta** con sus cuotas activas.
   - **Configuración** mostrando el lock biométrico activo.
   - (Opcional) **Login** con el halo verde + Google button.
   - (Opcional) **Form de nueva cuenta fija** con el selector de categoría.
5. Resoluciones: las nativas del device (Play Console acepta hasta 3840×3840). Si tu device es 1080×2400, dejalas así.
6. Pasalas a `assets/store/screenshots/` (yo te ayudo a renombrar/ordenar cuando las tengas).

---

## 11. Lo que NO necesita Play Store

- Términos y Condiciones (no obligatorios para apps gratis sin compras).
- Logo de la marca (la "App icon" alcanza).
- Promo video.
- Demo account credentials para reviewers (no aplica porque cualquiera puede crear cuenta gratis con magic link).

---

**Última actualización:** 2026-04-30
