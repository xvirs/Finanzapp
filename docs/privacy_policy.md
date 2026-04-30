# Política de Privacidad — Finanzapp

**Última actualización:** 29 de abril de 2026

Esta política explica qué datos recolecta la aplicación móvil **Finanzapp** ("la App"), cómo los usamos, con quién los compartimos y qué derechos tenés sobre tus datos.

Al usar Finanzapp aceptás esta política. Si no estás de acuerdo, por favor no uses la App.

---

## 1. Quién es responsable de tus datos

**Responsable del tratamiento:** Xavier Rosales — desarrollador independiente de Finanzapp.
**Contacto:** rosales.xavier.eloy@gmail.com
**Domicilio:** Córdoba, Argentina.

Finanzapp es un proyecto personal sin fines comerciales orientado a usuarios individuales que llevan registro de sus gastos recurrentes.

---

## 2. Qué datos recolectamos

### 2.1. Datos que vos nos das directamente

- **Email** — para crear tu cuenta (vía Magic Link o Google Sign-In).
- **Nombre y foto de perfil** — solo si elegís iniciar sesión con Google. Se reciben desde Google Identity Services y se usan para mostrar tu identidad en la app.
- **Datos financieros que cargás vos**:
  - Cuentas fijas (servicios, suscripciones): nombre, monto estimado, día de vencimiento, categoría, notas.
  - Tarjetas de crédito: nombre, banco emisor, marca (Visa/Mastercard/etc), día de cierre y vencimiento, último resumen.
  - Compras en cuotas: descripción, monto total, número de cuotas, fecha de inicio.
  - Pagos realizados: monto, fecha, cuenta o tarjeta asociada.
- **Configuraciones personales**: tema, idioma, preferencia de notificaciones, lock biométrico habilitado/no.

### 2.2. Datos que se generan automáticamente

- **Identificador único de cuenta (UUID)** asignado por Supabase al registrarte.
- **Fecha de creación y de última modificación** de cada registro.
- **Tokens de sesión** (access token + refresh token) emitidos por nuestro proveedor de autenticación, almacenados de forma cifrada en tu dispositivo.

### 2.3. Datos que NO recolectamos

- No usamos analytics, tracking ni publicidad (no Firebase Analytics, no Google Ads, no Meta SDK, no AppsFlyer).
- No accedemos a tu agenda de contactos, fotos, micrófono, ubicación ni calendarios.
- No leemos tus SMS ni notificaciones de otras apps.
- No recolectamos información de pagos reales — los montos que cargás son estimaciones tuyas, no transacciones procesadas.

---

## 3. Para qué usamos tus datos

| Finalidad | Base legal |
|---|---|
| Crear y mantener tu cuenta | Ejecución del servicio que pediste |
| Mostrar y sincronizar tus gastos en todos tus dispositivos | Ejecución del servicio |
| Enviarte notificaciones locales de vencimientos próximos | Tu consentimiento explícito al activar el permiso |
| Proteger tu cuenta con bloqueo biométrico (opcional) | Tu consentimiento explícito al activarlo |

No usamos tus datos para perfilamiento, publicidad ni venta a terceros.

---

## 4. Con quién compartimos tus datos

Finanzapp depende de los siguientes servicios para funcionar:

### 4.1. Supabase (proveedor de backend)
- **Qué hace:** almacena tu cuenta, datos financieros y gestiona la autenticación.
- **Dónde:** servidores de Supabase en EE.UU. y/o UE.
- **Política de privacidad:** https://supabase.com/privacy

### 4.2. Google Identity Services (autenticación opcional)
- **Qué hace:** valida tu identidad si elegís iniciar sesión con Google.
- **Dónde:** servidores de Google.
- **Política de privacidad:** https://policies.google.com/privacy

### 4.3. Google Play Services (notificaciones y entrega vía Google Play)
- **Qué hace:** infraestructura del sistema operativo Android.
- **Política de privacidad:** https://policies.google.com/privacy

**No vendemos ni cedemos tus datos a anunciantes, brokers ni terceros distintos a los listados arriba.**

---

## 5. Dónde se almacenan tus datos

- **En tu dispositivo:** datos cacheados de la app + tokens de sesión cifrados (Keychain en iOS / EncryptedSharedPreferences en Android). El backup automático del sistema operativo está deshabilitado para esta app, por lo que los tokens no se filtran a Google One ni a iCloud Backup.
- **En la nube (Supabase):** todos tus datos financieros, protegidos por Row Level Security — solo vos podés leer y modificar tus propios registros, validado en cada consulta vía tu UUID y JWT.

---

## 6. Cuánto tiempo conservamos tus datos

- Mientras tu cuenta esté activa, conservamos todos tus datos.
- Si pedís borrar tu cuenta (ver sección 7), eliminamos todos tus datos del backend dentro de los **30 días**.
- Los logs operativos del backend (sin datos personales) se conservan hasta 90 días para diagnóstico.

---

## 7. Tus derechos

Como usuario tenés derecho a:

- **Acceder** a los datos que tenemos sobre vos (la propia app te los muestra todos — no hay "datos ocultos" que no veas).
- **Rectificar** datos incorrectos (lo hacés desde la app misma editando cada registro).
- **Borrar** tu cuenta y todos tus datos.
- **Exportar** tus datos en formato legible (pedilo por email).
- **Retirar el consentimiento** de notificaciones o biometría desde la pantalla Configuración.
- **Oponerte** al tratamiento o presentar un reclamo ante la **Agencia de Acceso a la Información Pública (Argentina)** — https://www.argentina.gob.ar/aaip — o la autoridad equivalente en tu país.

Para ejercer cualquier derecho escribinos a **rosales.xavier.eloy@gmail.com** desde el email asociado a tu cuenta. Respondemos dentro de los 10 días hábiles.

---

## 8. Seguridad

- Todas las comunicaciones entre la app y Supabase usan **HTTPS** (TLS).
- Las contraseñas no se almacenan — usamos Magic Link y Google Sign-In, ambos protocolos sin password.
- El acceso a la base de datos está protegido por **Row Level Security**: cada usuario solo puede ver/modificar sus propios datos.
- Los tokens de sesión en el dispositivo están **cifrados** con la master key del hardware (Keychain iOS / Android Keystore).
- Opcionalmente podés activar **bloqueo biométrico** (Face ID / huella / PIN) que se valida cada vez que la app vuelve del background después de 60 segundos.

Ningún sistema es 100% seguro. Si detectás un problema de seguridad, escribinos a **rosales.xavier.eloy@gmail.com**.

---

## 9. Menores de edad

Finanzapp no está dirigida a menores de **13 años**. No recolectamos a sabiendas datos de menores de esa edad. Si sos padre/madre y creés que tu hijo/a creó una cuenta, escribinos para borrarla.

---

## 10. Cambios a esta política

Si modificamos esta política sustancialmente, te avisamos por email y/o con un aviso visible dentro de la app antes de que el cambio entre en vigor. Los cambios menores (corrección de typos, aclaraciones) se publican directamente.

---

## 11. Legislación aplicable

Esta política se rige por la **Ley 25.326 de Protección de los Datos Personales (Argentina)** y, en lo aplicable a usuarios europeos, por el **Reglamento General de Protección de Datos (RGPD/GDPR)**.

---

## 12. Contacto

Cualquier pregunta sobre esta política o sobre tus datos:

📧 **rosales.xavier.eloy@gmail.com**
