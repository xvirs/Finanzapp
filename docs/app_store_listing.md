# App Store Connect — Listing pre-redactado

Textos listos para copy-paste cuando la app aparezca en TestFlight y vayas a armar el listing público de App Store. Si querés ajustar algo, editalo acá y queda versionado.

---

## 1. App Information

| Campo | Valor |
|---|---|
| **Bundle ID** | `app.finanzapp.client` |
| **App Name** (visible en App Store) | `Mi Finanzapp` |
| **Subtitle** (max 30 chars) | `Tus pagos del mes, ordenados` |
| **Primary Language** | Spanish (Mexico) — `es-MX` |
| **Category — Primary** | Finance |
| **Category — Secondary** (opcional) | Productivity |
| **Content Rights** | Does not contain, show, or access third-party content |
| **Age Rating** | 4+ (no contiene contenido sensible) |

(Apple solo permite Spanish (Mexico) o Spanish (Spain) en Apple Connect — no hay Spanish (Argentina). Mexico es el más usado para mercado LATAM.)

### Subtitle alternativos (29 chars cada uno o menos)

- `Tus pagos del mes, ordenados` (28)
- `Gastos fijos sin sorpresas` (26)
- `Tarjetas y servicios al día` (27)

---

## 2. Description (max 4000 caracteres)

```
Mi Finanzapp es la app para llevar el control de los gastos recurrentes obligatorios — todo lo que pagás cada mes y no podés olvidarte.

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
• Face ID o Touch ID protege tus datos cuando dejás el celu desbloqueado.
• Se activa automáticamente si la app estuvo en segundo plano más de 1 minuto.

Privacidad y seguridad
• Sin publicidad ni tracking de terceros para perfilamiento.
• Tus datos están protegidos con Row Level Security en el backend — solo vos podés leerlos.
• Tokens de sesión cifrados en Keychain con la master key del hardware del dispositivo.

¿QUÉ NO ES MI FINANZAPP?

• No es una billetera virtual ni una app bancaria.
• No procesa pagos reales — solo registra los que vos cargás.
• No te conecta con tu banco ni lee tus consumos automáticamente.
• No te pide la tarjeta de crédito para usarla.

DATOS QUE GUARDA

Solo lo que vos cargás manualmente: nombres de tus servicios, montos estimados, fechas de vencimiento, marcas de tarjetas y notas tuyas. Todo eso se sincroniza con tu cuenta para que esté disponible en cualquier dispositivo donde inicies sesión.

LOGIN

• Continuar con Apple — un toque y listo, respeta tu privacidad.
• Continuar con Google (opcional) — login social.
• Magic Link al email — sin password.

Política de Privacidad: https://xvirs.github.io/Finanzapp/

¿Comentarios o problemas? Escribinos a rosales.xavier.eloy@gmail.com.
```

(2389 caracteres — entra cómodo en los 4000 max.)

---

## 3. Keywords (max 100 chars TOTAL, comma-separated)

```
gastos,finanzas,presupuesto,tarjetas,cuotas,vencimientos,recordatorio,servicios,suscripciones
```

(94 chars — entra justo. Si querés agregar más palabras, sacá alguna de las menos relevantes para vos.)

**Tips Apple Search:**
- NO incluir el nombre de la app (Apple lo agrega automático).
- NO incluir nombres de competidores (es contra TOS).
- Singular > plural si tenés que elegir.
- Si una keyword es 2 palabras, separar con espacio: `mi finanzas` (raro, pero si querés).

### Keywords alternativas si querés iterar después

```
gastos,finanzas,bills,tarjetas,credito,cuotas,vencimiento,recordatorio,facturas,suscripcion
```

---

## 4. Promotional Text (max 170 chars — se puede cambiar sin re-review)

```
Llevá el control de tus gastos fijos: servicios, tarjetas y cuotas. Recordatorios automáticos, biométrico opcional, sin publicidad.
```

(133 chars — usá el resto si después querés agregar promo de fin de año, etc.)

---

## 5. URLs

| Campo | URL |
|---|---|
| **Privacy Policy URL** ⚠️ obligatorio | `https://xvirs.github.io/Finanzapp/` |
| **Support URL** ⚠️ obligatorio | `mailto:rosales.xavier.eloy@gmail.com` o `https://github.com/xvirs/Finanzapp/issues` |
| **Marketing URL** (opcional) | `https://xvirs.github.io/Finanzapp/` (la misma de privacy si no tenés landing) |
| **Copyright** | `© 2026 Xavier Rosales` |
| **Trade Representative Contact Information** | (para Korea — no aplica, dejar vacío) |

---

## 6. App Privacy form (Apple data privacy)

Apple usa un formulario distinto al Data Safety de Google pero pide info similar. Los datos:

### Data Types Collected

#### Contact Info
- ✅ **Email Address**
  - Linked to user's identity: **Yes**
  - Used for tracking: **No**
  - Purposes: **App Functionality** + **Account Management**

- ✅ **Name** (solo si Apple Sign-In o Google con scope `name`)
  - Linked: Yes
  - Tracking: No
  - Purposes: App Functionality + Account Management

#### Financial Info
- ✅ **Other Financial Info** (los datos que el user carga: cuentas, montos, tarjetas)
  - Linked: Yes
  - Tracking: No
  - Purposes: App Functionality

#### Identifiers
- ✅ **User ID** (UUID asignado por Supabase)
  - Linked: Yes
  - Tracking: No
  - Purposes: Account Management + App Functionality

- ✅ **Device ID** (Firebase instance ID, IDFA si el user lo permite)
  - Linked: No (no se asocia a la identidad del user para nuestro analytics)
  - Tracking: No
  - Purposes: Analytics

#### Usage Data
- ✅ **Product Interaction** (eventos: bill_created, bill_paid, etc.)
  - Linked: Yes (vía user_id)
  - Tracking: No
  - Purposes: Analytics + App Functionality

#### Diagnostics
- ✅ **Crash Data** (Firebase Crashlytics)
  - Linked: No
  - Tracking: No
  - Purposes: App Functionality

- ✅ **Performance Data** (versión OS, modelo device, versión app)
  - Linked: No
  - Tracking: No
  - Purposes: Analytics

#### NO collected
- ❌ Health & Fitness
- ❌ Location
- ❌ Sensitive Info
- ❌ Contacts
- ❌ User Content (no fotos, no audio, etc.)
- ❌ Browsing History
- ❌ Search History
- ❌ Purchases
- ❌ Other Data

### Tracking
**Important**: Apple tiene una pregunta específica sobre "Tracking" que es DISTINTA a "Data Collection". Tracking = compartir data con third parties para perfilamiento o targeting de ads cross-app.

→ **Respuesta: NO tracking** (no hacemos tracking en este sentido).

→ **App Tracking Transparency dialog**: NO necesario porque no hacemos tracking.

---

## 7. Notes for Reviewer ⚠️ IMPORTANTE

Apple Review es estricto. Como la app requiere login y los flujos de Magic Link / Google / Apple Sign-In pueden confundir al reviewer, hay que dejarle instrucciones claras. Texto recomendado:

```
Hi Apple Review team,

Mi Finanzapp is a personal finance tracking app for recurring monthly expenses (bills, credit card statements, installments). It does not process real payments — users only log their own estimated amounts manually.

LOGIN INSTRUCTIONS:

The app supports three authentication methods. Easiest for review:

1. "Continuar con Apple" — Sign in with Apple. Use your existing Apple ID.

2. "Continuar con Google" — Google Sign-In. Any Google account works.

3. "Enviarme el link" — Magic Link. Enter any valid email address (e.g., your reviewer email) and you will receive a magic link via email. No password needed. No demo credentials are required because anyone can create an account in seconds.

WHAT TO TEST:

- Login (any of the 3 methods).
- Add a "Cuenta fija" (recurring bill) from Configuración → Cuentas fijas.
- Add a credit card from Configuración → Tarjetas.
- Mark a bill as paid from the home screen ("Mes").
- Toggle Face ID lock from Configuración (optional).

PRIVACY:

- Privacy Policy: https://xvirs.github.io/Finanzapp/
- We do not collect financial data automatically — users input their own estimates manually.
- We use Firebase Crashlytics + Analytics with anonymous identifiers (no PII tracking).
- Sign in with Apple is offered alongside other social logins, per Guideline 4.8.

If you need anything else, contact us at rosales.xavier.eloy@gmail.com.

Thanks!
```

---

## 8. Pricing & Availability

| Campo | Valor |
|---|---|
| **Price Tier** | Free |
| **Availability** | All countries (o solo Argentina + Spanish-speaking si querés empezar acotado) |
| **Pre-order** | No |
| **In-App Purchases** | None |

**Recomendación**: empezar con `All countries` para máximo alcance. Los users no-hispanohablantes capaz no la descargan, pero no pierde nada.

---

## 9. Age Rating questionnaire

| Pregunta Apple | Respuesta |
|---|---|
| Cartoon/Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic/Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content or Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Contests | None |
| Unrestricted Web Access | No |
| Gambling | No |

**Resultado esperado: 4+** (apta para todos).

---

## 10. Screenshots (separado en `docs/app_store_screenshots.md` cuando los hagas)

Apple exige mínimo 3 screenshots, máximo 10, en resolución **6.7" o 6.9"** (1290×2796 o 1320×2868). El simulador iPhone 17 Pro genera 1290×2796 por default — perfecto.

Pantallas a capturar (ver checklist completo abajo en sección 11).

---

## 11. Checklist de screenshots (👤 vos hacés)

### Setup previo (5 min)

1. Abrí el simulador con la app (`flutter run`).
2. Logueate con cuenta de prueba (Magic Link a tu email funciona).
3. Cargá datos demo realistas:
   - **3 cuentas fijas**: ej `Edesur (luz)` $25.000, `Personal (celular)` $18.500, `Netflix` $12.000.
   - **1 tarjeta**: ej `Galicia Eminent` Visa, cierre día 15, vencimiento día 25.
   - **1 compra en cuotas**: ej `Heladera Whirlpool` 12 cuotas de $48.000, primera en mes actual.
   - **Marcá UNA cuenta como pagada** (para mostrar estados mixtos).

### Capturar (10 min)

| # | Pantalla | Cmd para capturar |
|---|---|---|
| 1 | **Mes** con cuentas mixtas (1 pagada, 1 pendiente, 1 atrasada) | Cmd+S en simulador |
| 2 | **Detalle de tarjeta** mostrando la cuota activa de la heladera | Cmd+S |
| 3 | **Form de nueva cuenta fija** abierto (con selector de categoría) | Cmd+S |
| 4 | **Configuración** con sección "Seguridad" visible (lock biométrico) | Cmd+S |
| 5 (opcional) | **Login** con halo verde (queda lindo de imagen 1) | Cmd+S |
| 6 (opcional) | **Tarjetas** lista con la tarjeta cargada y el total del mes | Cmd+S |

### Después

1. Los archivos se guardan al Desktop con nombre tipo `Simulator Screenshot - iPhone 17 Pro - 2026-XX-XX at HH.MM.SS.png`.
2. Renombralos en orden: `01-mes.png`, `02-tarjeta.png`, etc.
3. Movelos a `assets/store/screenshots/` del repo.
4. Cuando subas a App Store Connect, usás el ORDEN que querés que aparezcan.

**Tip**: el primer screenshot es el más importante (es el que se ve en la búsqueda). Mi sugerencia: **Mes** con datos cargados — muestra el valor central de la app.

---

## 12. Submit for Review

Una vez que tengas:
- ✅ Build en TestFlight (Internal Testing OK)
- ✅ Description, keywords, screenshots, App Privacy form llenos
- ✅ Notes for Reviewer pegado
- ✅ Privacy Policy URL working

→ Click **"Submit for Review"** en App Store Connect.

Apple revisa **24-48h típico** (puede ser 12h o hasta 7 días).

Si aprueban: click **"Release this version"** (manual) o auto-release.

App live en App Store en ~2h después del release.

---

**Última actualización:** 2026-05-10
