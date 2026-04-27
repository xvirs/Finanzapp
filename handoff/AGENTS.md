# AGENTS.md — Finanzapp (handoff para agentes IA)

> Este archivo es para que un agente IA (Claude Code, Cursor, etc.) entienda el proyecto y empiece a implementarlo en Flutter sin ambigüedad.

## Qué es Finanzapp

App mobile (Flutter, Android + iOS) para que el usuario lleve registro mensual de:
- **Cuentas fijas**: servicios (luz, agua, gas, internet), impuestos, alquiler, expensas, suscripciones (Netflix, Spotify), etc.
- **Tarjetas de crédito**: resumen mensual, compras en cuotas, débitos automáticos.

El **objetivo principal** del usuario es cada mes: ver qué falta pagar, marcar lo pagado, no olvidarse de vencimientos. No es contabilidad — es checklist mensual financiero.

## Stack

- **Flutter** (Dart 3+, Material 3).
- **Backend**: Supabase (auth + Postgres + Storage). Magic link + Google.
- **Routing**: `go_router`.
- **State**: `riverpod` (sugerido).
- **Tema**: `lib/design/theme.dart` aplica los tokens.

## Estructura sugerida

```
lib/
  design/                  ← copiar tal cual desde handoff/flutter/lib/design/
    tokens.dart
    theme.dart
    widgets.dart
  features/
    auth/         (1, 12)
    month/        (2, 3, 13, 14) ← home con bottom nav 0
    cards/        (4, 5, 6, 7)   ← bottom nav 1
    config/       (8)             ← bottom nav 2
    fixed_accounts/ (9, 10, 11)
  router.dart
  main.dart
```

## Cómo trabajar

1. **Leé `design-system.md`** primero — tokens y reglas.
2. **Leé `screens-spec.md`** — spec pantalla por pantalla.
3. Para fidelidad píxel-perfect, **abrí los archivos `screens-a*.jsx`** en `handoff/` — son la fuente de verdad. Los valores numéricos (paddings, font-sizes, radios, colores) están explícitos ahí.
4. Para verlas en vivo: abrir `handoff/_grid.html` en browser.
5. Reusá `FzCard`, `FzPrimaryButton`, `FzBadge`, etc. de `widgets.dart` — no rehagas estilos inline.
6. **Tipografías**: cargá Geist + Geist Mono (Google Fonts). Si no podés, fallback a `Inter` + `JetBrains Mono`.
7. **Iconos**: los de `material_symbols_icons` (outlined) cubren el 90%. Para luz/agua/gas/impuesto/etc. (cuentas fijas), reproducí los SVG del componente `CCTypeIcon` en `screens-a-config.jsx`.

## Reglas no-negociables

- **No emojis en UI** (sí en notas del usuario).
- **Tabular nums** en TODOS los montos y fechas mono.
- **No gradientes** salvo el halo radial sutil de la pantalla de login y el hero card del detalle de tarjeta.
- **No cambiar la paleta** sin pasar por `tokens.dart` primero.
- **Default es modo oscuro**. Light se soporta pero no es prioridad inicial.

## Datos (modelo conceptual)

```
User { id, email }
Card {
  id, userId, name, brand: 'visa'|'mc'|'mp'|'amex', issuer,
  closeDay, dueDay, payLink, active
}
InstallmentPurchase {
  id, cardId, description, monthlyAmount, totalInstallments,
  firstChargeMonth, notes
}
FixedAccount {
  id, userId, name,
  type: 'electricity'|'water'|'gas'|'tax'|'subscription'|'health'|'rent'|'other',
  estimatedAmount?,        // null = variable
  dayOfMonth, autoDebitCardId?, refCode, payLink, notes, active
}
MonthRecord {
  id, userId, yearMonth, accountId|cardId, kind: 'card'|'account',
  amount?, paid, paidAt
}
```

`MonthRecord` se materializa por mes — al avanzar de mes, la app crea filas para todos los items activos. Items con `autoDebitCardId` no generan record propio (se cobran en la tarjeta).

## Empezar por

1. `flutter create finanzapp` + dependencias (`supabase_flutter`, `go_router`, `riverpod`).
2. Copiar `lib/design/` desde el handoff.
3. Aplicar `FzTheme.dark()` en `MaterialApp`.
4. Implementar **pantalla 2 (Mes)** con datos mockeados — es el corazón de la app.
5. Iterar: tarjetas, config, etc. en orden del spec.
