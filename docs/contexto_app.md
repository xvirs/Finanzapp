# Finanzapp — Contexto del Producto

> Documento pensado para usar como **contexto en otras conversaciones**: descripciones de App Store/Play Store, textos de marketing, posts, presentaciones, soporte, etc. No incluye detalles técnicos.

---

## Qué es Finanzapp

Finanzapp es un **sistema personal de control de gastos recurrentes y compras en cuotas** disponible en **tres plataformas**:

- **Web** → https://finanzas-xavier.vercel.app/
- **iOS** (iPhone / iPad)
- **Android**

Las tres versiones son **el mismo producto**: comparten cuenta de usuario, base de datos y funcionalidad central. Lo que el usuario carga desde el celular lo ve al instante en la web (y al revés). Es decir, podés revisar tus pagos del mes desde la compu en el trabajo y marcarlos como pagados desde el celular en la calle, sin perder sincronía.

**Frase corta:** "Tu mes, claro. Sabés cuánto debés, qué pagaste y qué te falta — desde tu compu o tu celular."

**Para quién:** usuarios en Argentina que pagan facturas mensuales (luz, gas, agua, internet, alquiler, expensas, suscripciones) y/o tienen compras en cuotas con tarjetas de crédito, y necesitan una vista mensual ordenada en cualquier dispositivo.

**Idioma:** Español (Argentina).
**Moneda:** Pesos argentinos (ARS).

---

## Una sola cuenta, tres plataformas

| | **Web** | **iOS** | **Android** |
|---|---|---|---|
| Acceso desde cualquier navegador | ✅ | — | — |
| App nativa instalable | ✅ (PWA) | ✅ | ✅ |
| Funciona offline (consulta) | ✅ | ✅ | ✅ |
| Bloqueo con Face ID / huella | — | ✅ | ✅ |
| Notificaciones de vencimientos | — | ✅ | ✅ |
| Mismo usuario y mismos datos | ✅ | ✅ | ✅ |

El usuario inicia sesión una vez en cada dispositivo y todo aparece sincronizado en tiempo real.

---

## Cómo está organizada la app

La app —en cualquiera de sus tres versiones— gira alrededor de **una vista mensual** desde la cual el usuario navega al detalle de tarjetas, configuración y gestión de gastos. La estructura de pantallas es la misma en web, iOS y Android; cambia solo la presentación (en web hay sidebar en pantallas grandes; en móvil hay navegación por pestañas).

### Pantallas y qué se hace en cada una

**1. Login / Acceso**
Punto de entrada. El usuario ingresa con:
- Email (mediante un enlace mágico que le llega al correo, sin contraseña)
- Cuenta de Google
- Apple ID *(en iOS)*

**2. Mes (pantalla principal)**
Es el corazón de la app. Muestra:
- El total estimado del mes y cuánto ya está pagado.
- Una barra de progreso de los pagos.
- Las deudas del mes agrupadas por tipo (alquiler, servicios, suscripciones, tarjetas, etc.).
- Filtros para ver solo pendientes, solo atrasadas o todo.
- Navegación a meses anteriores o futuros (ver historial o anticipar).

Desde acá el usuario marca cosas como pagadas, ve detalle de cada deuda y entiende rápido cómo viene su mes.

**3. Tarjetas**
Lista de todas sus tarjetas de crédito con el saldo total estimado del mes para cada una. De un toque entra al detalle.

**4. Detalle de una tarjeta**
Dentro de cada tarjeta el usuario ve:
- Datos de la tarjeta (banco, marca, día de cierre y vencimiento).
- Las **compras en cuotas** activas (qué compró, en cuántas cuotas, cuánto le queda).
- Los **débitos automáticos** asociados.
- Acciones para crear, editar o eliminar.

**5. Nueva tarjeta / Editar tarjeta**
Formulario simple para registrar una tarjeta: nombre, banco, marca (Visa, Mastercard, Amex, etc.), día de cierre y día de vencimiento.

**6. Nueva cuota / Editar cuota**
Para registrar una compra en cuotas: qué se compró, monto total, cuántas cuotas y desde qué mes empieza.

**7. Configuración**
Hub de ajustes desde donde se accede a:
- Datos de la cuenta del usuario.
- Listado de gastos recurrentes (facturas).
- Listado de tarjetas.
- Activar/desactivar bloqueo con huella o Face ID *(solo móvil)*.
- Cerrar sesión.

**8. Gastos recurrentes (facturas)**
Listado y gestión de las cosas fijas que se pagan todos los meses: alquiler, expensas, luz, agua, gas, internet, suscripciones, salud, impuestos, etc. Cada gasto puede tener:
- Nombre, monto (si es fijo) y día del mes en que vence.
- Tipo (categoría).
- Notas y un link (para entrar a pagar, ej. la web del servicio).
- Marca de débito automático.

**9. Bloqueo de seguridad** *(solo móvil)*
Pantalla que aparece al abrir la app si el usuario activó la autenticación biométrica. Pide huella o Face ID para entrar. Tiene una salida de emergencia para cerrar sesión si hay problemas con el sensor.

---

## Qué puede hacer el usuario (resumen funcional)

- **Registrar sus gastos fijos** del mes una sola vez y verlos repetir automáticamente cada mes.
- **Cargar tarjetas de crédito** y llevar el control de qué tiene en cuotas en cada una.
- **Anotar compras en cuotas** y ver mes a mes lo que va a pagar.
- **Marcar pagos** y ver cuánto le queda por pagar del mes.
- **Recibir recordatorios** antes del vencimiento de cada cosa *(en móvil)*.
- **Navegar entre meses** para ver lo que pagó en meses anteriores o anticipar lo que viene.
- **Acceder rápido y seguro** con huella o Face ID *(en móvil)*.
- **Trabajar desde cualquier dispositivo**: empezás algo en la web y lo seguís en el celular sin pasos extra.

---

## Diferencias entre versiones (para escribir textos honestos)

**Lo que la versión web ofrece y la móvil no (todavía):**
- Pantalla amplia con vistas más cómodas para gestionar muchas tarjetas o gastos a la vez.
- Acceso instantáneo desde cualquier compu sin instalar nada.

**Lo que la versión móvil ofrece y la web no:**
- Notificaciones de vencimientos al teléfono.
- Bloqueo con Face ID o huella digital.
- Acceso de un toque desde el ícono del celular sin abrir el navegador.

**Lo que tienen igual:**
- La cuenta, los datos, los meses, las tarjetas, las cuotas y los gastos recurrentes son exactamente los mismos.

---

## Identidad y tono

- **Nombre del producto:** Finanzapp (en stores y apps móviles). La versión web vive en la URL `finanzas-xavier.vercel.app`.
- **Estilo visual:** minimalista, tema oscuro por defecto, tarjetas con sombras suaves, animaciones discretas. La identidad visual es la **misma** en web y móvil.
- **Colores principales:**
  - Verde (color de marca y acciones).
  - Fondo oscuro (modo nocturno).
  - Rojo solo para alertas de atraso/deuda.
- **Tipografía:** moderna, sans-serif (Geist) y monoespaciada (Geist Mono) para los números.
- **Tono de comunicación:** claro, directo, en español rioplatense, sin jerga financiera.

---

## Lo que **no** es Finanzapp

Para evitar confusiones cuando se escriben textos:
- **No es un home banking** ni se conecta a la cuenta del banco del usuario.
- **No descuenta plata** ni hace pagos por el usuario.
- **No es una app de inversiones** ni de criptomonedas.
- **No es un libro contable** ni una herramienta para empresas.
- **No es presupuesto/budgeting al estilo "envelope method"**: el foco es **deudas y vencimientos**, no clasificar todos los gastos diarios.

Es, simplemente, una **agenda inteligente de gastos fijos y cuotas**, multi-dispositivo.

---

## Datos prácticos

- Disponible en **Web, iOS y Android**.
- Funciona en **español argentino**, montos en **pesos argentinos**.
- Requiere conexión a internet para iniciar sesión y sincronizar; la consulta funciona también con datos cacheados.
- Acceso opcional con biometría (huella / Face ID) en móvil.
- Notificaciones locales en móvil para avisar de vencimientos.
- La sesión se guarda de forma segura y cifrada en el dispositivo.

---

## Versión actual

- **Versión web:** publicada y operativa en https://finanzas-xavier.vercel.app/
- **Versión móvil (iOS y Android):** versión 1.0.0, primer release público, en preparación para App Store y Google Play.
- **Origen:** la versión web fue el punto de partida del producto. La app móvil nació como su versión nativa para dispositivos, manteniendo cuenta y datos compartidos.

---

## Cómo usar este documento

Pegá este archivo (o partes) como contexto cuando pidas en otro chat cosas como:
- "Escribime la descripción larga para Google Play."
- "Hacé un texto de 80 caracteres para el subtítulo de App Store."
- "Redactá un posteo de Instagram anunciando el lanzamiento."
- "Armame un guion de 30 segundos para un video demo."
- "Hacé las preguntas frecuentes para una landing."
- "Hacé un texto que explique las ventajas de tener web + móvil sincronizados."

Con este contexto, cualquier asistente puede generar textos consistentes con el producto sin necesidad de explicar todo de cero.
