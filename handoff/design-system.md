# Finanzapp — Sistema de Diseño

> Tokens visuales para la dirección elegida (**A · Banco premium**, modo oscuro como default).
> Esta es la **fuente de verdad** para colores, tipografía, espaciados, radios y sombras.
> Todo lo que está acá debe traducirse 1:1 a Flutter (`ThemeData` + extensiones).

---

## 1. Identidad

- **Nombre**: Finanzapp
- **Logo**: cuadrado redondeado verde (radius ≈ 26% del lado) con `$` blanco bold centrado.
  - El `$` es un símbolo de pesos clásico, sans-serif, peso ≈ 700, con la barra vertical atravesando una "S" gruesa de cantos redondeados.
  - Versión SVG en `screens/fz-logo.svg`.
- **Tagline**: "Tus pagos del mes, ordenados."

## 2. Paleta — Modo oscuro (default)

| Token              | Hex        | Uso |
|--------------------|------------|-----|
| `bg`               | `#0B0F0D`  | Fondo de pantalla |
| `card`             | `#141B18`  | Fondo de cards, inputs, botones secundarios |
| `cardHi`           | `#192521`  | Fondo de cards activas o iconos contenedores |
| `cardPaid`         | `#0E2018`  | Fondo de card cuando ítem está pagado |
| `cardLate`         | `#23120F`  | Fondo de card cuando ítem está atrasado |
| `border`           | `#1F2A26`  | Borde por defecto de cards/inputs |
| `borderHi`         | `#2A3833`  | Borde hover/focus |
| `borderPaid`       | `#1B3A2A`  | Borde de card pagada |
| `borderLate`       | `#3A1813`  | Borde de card atrasada |
| `text`             | `#E8EDEA`  | Texto principal |
| `textDim`          | `#8A9590`  | Texto secundario |
| `textMute`         | `#5C6661`  | Caplabels, hints, placeholders |
| **`primary`**      | `#1FB87A`  | Color de marca, "pagado", CTAs |
| `primaryHi`        | `#2DD891`  | Hover/highlight del primary, números pagados |
| `primarySoft`      | `#0E2A1E`  | Tinte verde para fondos sutiles |
| `primaryInk`       | `#04130C`  | Texto sobre primary (verde sobre verde inverso) |
| `late`             | `#E5604A`  | Estado "atrasado" |
| `lateSoft`         | `#3A1813`  | Tinte rojo para fondos sutiles |
| `lateInk`          | `#FF8B72`  | Texto sobre late |

### Marcas de tarjetas (chips)
| Marca       | Bg         | Fg        |
|-------------|------------|-----------|
| VISA        | `#1A1F71`  | `#FFFFFF` |
| Mastercard  | `#EB001B`  | `#FFFFFF` |
| MercadoPago | `#009EE3`  | `#FFFFFF` |

## 3. Paleta — Modo claro

| Token        | Hex        |
|--------------|------------|
| `bg`         | `#F6F5F1`  |
| `card`       | `#FFFFFF`  |
| `cardHi`     | `#F0EEE7`  |
| `cardPaid`   | `#E8F5EE`  |
| `cardLate`   | `#FCEBE6`  |
| `border`     | `#E6E2D8`  |
| `text`       | `#1A1F1C`  |
| `textDim`    | `#5C6661`  |
| `textMute`   | `#8A9590`  |
| `primary`    | `#0E9F62`  |
| `primarySoft`| `#D7F0E2`  |
| `late`       | `#C73A22`  |

## 4. Tipografía

- **Familia principal (sans)**: `Geist` — fallback `Inter`, `system-ui`.
  - Pesos: 400 (regular), 500 (medium), 600 (semibold), 700 (bold).
- **Familia mono**: `Geist Mono` — fallback `JetBrains Mono`, `ui-monospace`.
  - Pesos: 400, 500, 600.
- **Numerales**: siempre `font-feature-settings: 'tnum'` (tabular nums) para que las columnas de montos se alineen.

### Escala (mobile)

| Rol                         | Tamaño  | Peso | Tracking      | Familia |
|-----------------------------|---------|------|---------------|---------|
| `display` (hero monto)      | 36 px   | 600  | -0.03em       | Geist   |
| `h1` (título de pantalla)   | 26 px   | 600  | -0.025em      | Geist   |
| `h2` (sección dentro card)  | 20 px   | 600  | -0.02em       | Geist   |
| `bodyL` (monto card)        | 24 px   | 600  | -0.02em       | Geist   |
| `body` (texto general)      | 14 px   | 400-500 | normal     | Geist   |
| `bodyS`                     | 13 px   | 400  | normal        | Geist   |
| `caption`                   | 11–12 px| 400  | normal        | Geist o Mono |
| `mono` (números, fechas)    | 11–14 px| 500  | 0.04em        | Geist Mono |
| `caplabel` (sección, all-caps)| 11 px | 500  | 0.06em–0.1em  | Geist Mono, uppercase |

## 5. Espaciado

Sistema base **4 px**, con escala **4, 6, 8, 10, 12, 14, 16, 20, 24, 32, 44, 78**.

- **Padding lateral de pantalla**: 16 px (cards), 20 px (texto/headers).
- **Gap vertical entre cards**: 6–10 px.
- **Padding interno de card**: 14 px (compacta), 16 px (estándar), 20 px (hero).
- **Bottom padding por bottom-nav**: 78 px.

## 6. Radios

| Token  | Px  | Uso                            |
|--------|-----|--------------------------------|
| `xs`   | 4   | Chips de marca, badges         |
| `sm`   | 8   | Iconos chicos, tags            |
| `md`   | 10  | Botones de toolbar, contenedores de ícono 32–38 px |
| `lg`   | 12  | Inputs, botones primarios      |
| `xl`   | 14  | Cards estándar                 |
| `2xl`  | 16  | Cards grandes                  |
| `3xl`  | 18–24 | Hero card, tarjeta de logo  |
| `pill` | 999 | Toggles                        |

## 7. Sombras

- **Elevación 0** (default cards): solo borde de 1 px, sin sombra.
- **Elevación 1** (CTAs): `0 4px 16px primary33` (33 = 20% alpha).
- **Elevación 2** (logo, hero): `0 8px 30px primary55, inset 0 1px 0 primaryHi`.
- **Glow ambiental** (hero card pagado): `radial-gradient(circle at 90% 0%, primary 24, transparent 70%)` como capa decorativa.

## 8. Iconografía

- **Stroke 1.6 px** por defecto (1.5 en denso, 2.0–2.4 en bold/CTAs).
- `strokeLinecap: round`, `strokeLinejoin: round`.
- ViewBox 24×24.
- Sin emojis en producción — los reemplazamos por glifos custom SVG por categoría (luz, agua, gas, impuesto, suscripción, salud, otro).
- Lista de iconos definidos en `screens-a-config.jsx > CCTypeIcon` y `screens-a.jsx > AIcon`.

## 9. Componentes (alto nivel)

- **`Card`** — `bg.card`, `border.border` 1 px, radius 14–16.
- **`StatusCard`** — Card con tinte según estado: `cardPaid`/`cardLate` y borde acorde.
- **`Button.primary`** — fill `primary`, texto `primaryInk`, radius 12, padding 14×14.
- **`Button.secondary`** — bg transparente, borde `border`, texto `text`.
- **`Button.danger`** — bg transparente, borde `borderLate`, texto `late`.
- **`Input`** — bg `card`, border `border`, radius 12, padding 12×14.
- **`Badge`** — radius 4, padding 2×6, font 9 px mono uppercase, letter-spacing 0.04em.
- **`Tab`** (segmented) — Bg `card`, indicador activo `primarySoft` con borde `borderPaid`.
- **`BottomNav`** — 3 tabs (Mes / Tarjetas / Config), íconos 20 px, label 10.5 px. Tab activo: pill `primarySoft` con icono y label `primary`.

## 10. Estados

- **Pagado** — borde `borderPaid`, fondo `cardPaid`, monto en `primaryHi`, label "PAGADO" en `primary` mono uppercase.
- **Atrasado** — borde `borderLate`, fondo `cardLate`, monto en `text`, badge "ATRASADA" mono uppercase con fondo `lateSoft` y texto `lateInk`.
- **Vacío / Sin cargos** — borde `border`, monto en `textDim`, label "VENCE DÍA X" o "Sin cargos".
- **Variable** (cuentas fijas) — chip "VARIABLE" en mono uppercase con bg `cardHi` y texto `textDim`.

## 11. Voz / copy

- **Conciso, neutral, en español rioplatense.**
- Estados en mayúsculas mono cuando son labels: `PAGADO`, `ATRASADA`, `VARIABLE`, `VENCE DÍA 15`.
- Hints en cursiva debajo de inputs.
- Montos siempre con `$` y separador de miles `.` (ARS): `$1.629.560`.
- Sin emojis en UI de producción (sí en el cuerpo de notas si el usuario los tipea).
