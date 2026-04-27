# Finanzapp — Handoff package

App mobile en Flutter para llevar registro mensual de cuentas fijas y tarjetas de crédito.

## Qué hay acá

```
handoff/
├── README.md              ← este archivo
├── AGENTS.md              ← cómo arrancar (para humanos o IA)
├── design-system.md       ← tokens visuales (colores, type, spacing, radios)
├── screens-spec.md        ← especificación pantalla por pantalla (14 pantallas)
├── flutter/
│   └── lib/design/
│       ├── tokens.dart    ← paleta + escalas + typography roles
│       ├── theme.dart     ← ThemeData completo (FzTheme.dark/light)
│       └── widgets.dart   ← FzCard, FzPrimaryButton, FzBadge, FzBottomNav, etc.
├── screens-a.jsx          ← Login + Home + Item expandido (oscuro)
├── screens-a-light.jsx    ← Login + Home + Expandido (claro)
├── screens-a-cards.jsx    ← Tarjetas, detalle MP, nueva compra, editar
├── screens-a-config.jsx   ← Config, cuentas fijas, nueva, editar
├── fz-logo.jsx            ← logo
├── _grid.html             ← abrir en browser para ver las 14 pantallas en grilla
├── _single.html           ← abrir una pantalla aislada (?s=login etc.)
└── canvas.html            ← canvas explorable (drag/zoom) con todas las direcciones
```

## Cómo usar (ruta corta para un dev/IA)

1. Leer `AGENTS.md` para entender stack y prioridades.
2. Leer `design-system.md` para los tokens.
3. Copiar `flutter/lib/design/` al proyecto Flutter nuevo.
4. Tomar `screens-spec.md` + `screens/*.jsx` y construir cada pantalla en orden.

## Direcciones visuales exploradas

Se exploraron 4 direcciones en el canvas (ver `canvas.html`). La elegida es **A · "Banco premium"**: oscuro, verde primario `#1FB87A`, tipografía Geist + Geist Mono, cards con bordes finos, números tabulares, estética sobria tipo banca digital moderna.

## Próximos pasos sugeridos

- Cargar fuentes Geist y GeistMono (Google Fonts) en `pubspec.yaml`.
- Bootstrappear Supabase y schema según `AGENTS.md`.
- Implementar primero la pantalla **Mes (Home)** — es el corazón del producto.
