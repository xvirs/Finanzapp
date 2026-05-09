# Finanzapp · Handoff Fold 7 (responsive)

> **Para**: Claude Code en el repo Flutter móvil.
> **Objetivo**: Hacer que la app móvil se adapte correctamente al **Galaxy Z Fold 7** y a tablets/desktops, manteniendo el lenguaje visual ya implementado en mobile (la captura del SM N980F que ya funciona).

## Qué es esto

La app ya corre bien en celulares estándar. Lo que falta es que **aproveche el ancho extra** cuando el dispositivo se despliega (Fold 7 inner ~6.5–7.9", tablet, ChromeOS). Hoy en pantallas anchas se ve estirada con todo en una sola columna.

Este handoff define:
1. **Breakpoints** y `LayoutBuilder` strategy
2. **3 layouts adaptativos** por pantalla: `compact` (móvil), `expanded` (Fold inner / tablet), `desktop` (web)
3. Spec por pantalla (Login, Mes, Tarjetas, Configuración) en cada formato
4. Token de **ingresos** (nuevo concepto) y cómo se debe ver en cada formato

## Estructura

```
handoff-fold/
├── README.md                  ← este archivo
├── AGENTS.md                  ← onboarding para Claude Code Flutter
├── breakpoints.md             ← reglas de breakpoints + helpers
├── ingresos-spec.md           ← cómo dibujar el bloque "Ingresos / Saldo"
├── screens/
│   ├── login.md
│   ├── mes.md
│   ├── tarjetas.md
│   └── config.md
└── flutter/
    ├── responsive.dart        ← LayoutBuilder + breakpoints helpers
    └── adaptive_scaffold.dart ← scaffold que cambia de layout según ancho
```

## Premisa central

> **No reescribir** la pantalla mobile. Envolverla en un `AdaptiveScaffold` que:
> - <600 dp → `compact` (la pantalla móvil actual, sin cambios)
> - 600–1023 dp → `expanded` (Fold inner: rail nav + master/detail)
> - ≥1024 dp → `desktop` (sidebar 240 + main + aside)

El widget de cada item (CardItem, AccountTile, etc.) **se reusa** en los 3 layouts. Lo que cambia es la grilla/columna que los contiene.

## Cómo lo usa el agente

Leer `AGENTS.md` → `breakpoints.md` → spec de la pantalla en `screens/` → implementar.
