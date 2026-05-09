# Feature: Responsive / Fold — Análisis e integración

> Plan estructural para soportar Galaxy Z Fold 7 y otros tamaños grandes en Finanzapp Flutter, **sin reescribir la app móvil actual**, y garantizando que al desplegar el dispositivo la app no se reinicie ni se estire.

---

## 1. Qué define el handoff

`handoff-fold/` es un set de specs maduras y bien pensadas. En síntesis:

- **3 form factors** definidos por ancho lógico:
  - `compact` (<600 dp): celular estándar / Fold cerrado.
  - `expanded` (600–1023 dp): Fold inner desplegado / tablet vertical.
  - `desktop` (≥1024 dp): tablet horizontal / web Flutter / ChromeOS.
- **Premisa central**: NO reescribir la pantalla mobile. Se la envuelve en un `AdaptiveScaffold` que delega a 3 builders (compact, expanded, desktop). El layout `compact` queda intacto.
- **Reuso de widgets atómicos**: `MonthItemCard`, `BillTile`, `CardItem`, etc. se reusan idénticos en los 3 layouts. Lo único que cambia es el contenedor (lista vs grilla 2 col vs grilla 3 col + sidebar/aside).
- **Helpers ya escritos**: `handoff-fold/flutter/responsive.dart` y `adaptive_scaffold.dart` están listos para copiar a `lib/core/`.
- **Spec por pantalla**: Login / Mes / Tarjetas / Config tienen su variante `expanded` y `desktop` documentada, incluyendo el bloque "Ingresos / Saldo" (ya implementado en compact).

---

## 2. Estado actual de la app

| Pieza | Estado |
|-------|--------|
| Shell de navegación | `StatefulShellRoute.indexedStack` con 3 ramas (Mes / Tarjetas / Config) y `BottomNavigationBar` (`FzBottomNav`) en `app_shell.dart` |
| State management | `flutter_bloc` con BLoCs por pantalla. `HydratedBloc` para persistencia |
| Modelos atómicos | `MonthItemCard`, `BillTile` (en bills_list_screen), etc. ya existen como widgets reusables |
| Tema | `FzTheme.dark()` con tokens en `lib/design/tokens.dart` |
| **Android Manifest** | **Ya tiene** `android:configChanges="orientation\|keyboardHidden\|keyboard\|screenSize\|smallestScreenSize\|locale\|layoutDirection\|fontScale\|screenLayout\|density\|uiMode"` ✓ |
| iOS | Por defecto soporta cambios de size class sin recrear |

**Buena noticia**: la base ya está armada para que los cambios sean aditivos y de bajo riesgo.

---

## 3. Lo que el usuario pide y cómo lo garantizamos

### "No quiero que se reinicie la app"

Hay dos formas de "reiniciarse" cuando se despliega un Fold:

- **Recreación del Activity** (Android) → ya está prevenida por el `configChanges` actual del manifest.
- **Pérdida de estado del BLoC** → mitigado por `HydratedBloc` que ya está activo. Además, los blocs viven dentro del `StatefulShellRoute`, que mantiene el estado de cada rama durante toda la sesión.

**Verificación**: hay que probar en Fold real que los blocs no se reseteen. Si veo algún caso, se agrega persistencia hidratada al bloc puntual.

### "No quiero que se estire"

Hoy en pantalla ancha la app aplica el layout `compact` con todo en una sola columna que queda visualmente "estirada". Solución:

- Usar `LayoutBuilder` (no `MediaQuery.size`) para que respete **multi-window y splitscreen** del Fold (cuando el usuario abre 2 apps en pantalla partida).
- En `expanded` y `desktop`, las grillas de cards usan 2/3 columnas en vez de 1, y los `Container` de items tienen `maxWidth` razonable.

### "Que se adapte cuando abro el celular"

El `LayoutBuilder` reacciona a cualquier cambio de tamaño en tiempo real. Cuando el Fold se despliega de 5.6" a 7.6":
1. El sistema notifica un cambio de constraints.
2. `LayoutBuilder` recibe nuevos `BoxConstraints`.
3. Si pasa el umbral 600 dp, se renderiza `_ExpandedLayout` en lugar de `_CompactLayout`.
4. **No hay rebuild de toda la app** — solo del subárbol que está dentro del `LayoutBuilder`.
5. Los BLoCs y su estado siguen vivos arriba del shell.

### Riesgo del hinge / fold físico

El Fold 7 tiene una bisagra que puede cortar contenido visual. Hay que detectar `MediaQuery.of(context).displayFeatures` para evitar grillas que partan al medio. El helper `responsive.dart` ya incluye esta detección (`isFoldInner`).

---

## 4. Plan de integración (5 fases incrementales)

Cada fase deja la app **compilando y funcionando en celular estándar igual que hoy**. Si una fase rompe algo, las anteriores siguen valiendo.

---

### Fase 0 — Infraestructura responsive (sin cambios visibles)

**Objetivo**: copiar los helpers y dejar la base lista, sin tocar pantallas.

**Archivos a crear**:
- `lib/core/responsive.dart` — copia de `handoff-fold/flutter/responsive.dart` (con ajustes de import al estilo del proyecto).
- `lib/core/adaptive_scaffold.dart` — copia de `handoff-fold/flutter/adaptive_scaffold.dart` adaptado al theme de Finanzapp (usar `FzColors`, `FzType`).

**Archivos a modificar**:
- `android/app/src/main/AndroidManifest.xml` — agregar `android:resizeableActivity="true"` explícito en `<activity>` (default es true en API 24+, pero es buena práctica documentarlo). Esto autoriza splitscreen/multi-window en algunos OEM.

**Verificación**: `flutter analyze` limpio; la app compila e ignora los nuevos archivos.

---

### Fase 1 — AppShell adaptativo (la pieza crítica)

**Objetivo**: que el shell muestre `BottomNavigationBar` en compact y `NavigationRail` en expanded/desktop. La navegación entre pestañas sigue intacta.

**Archivo a tocar**: `lib/shell/app_shell.dart`.

**Lógica**:
- En `compact` (<600 dp): layout actual sin cambios.
- En `expanded` (600–1023 dp): `Row` con `NavigationRail` a la izquierda + `Expanded(navigationShell)` a la derecha. Sin bottom nav.
- En `desktop` (≥1024 dp): mismo patrón pero con un sidebar más ancho (220-240 dp) que muestra labels grandes. Bottom nav oculto.

**Crítico**: `navigationShell` se mantiene igual — `StatefulShellRoute.indexedStack` preserva el estado de cada rama. Lo único que cambia es el "chrome" alrededor.

**Riesgo**: `FzBottomNav` tiene 3 destinos (Mes / Tarjetas / Config). El `NavigationRail` debe usar los mismos labels e íconos para coherencia visual.

**Verificación**: en celular sigue viéndose idéntico; en simulador resizable, al pasar de 599 a 600 dp aparece el rail sin reload.

---

### Fase 2 — Login adaptativo

**Objetivo**: en expanded/desktop, split brand panel + form panel (50/50 → form fijo 480 en desktop).

**Archivo a tocar**: `lib/features/auth/presentation/login_screen.dart`.

**Lógica**:
- Mover el contenido actual a un `_CompactLogin` (sin cambios).
- Crear `_SplitLogin` con dos paneles. Reutilizar los widgets existentes (botón Google, magic-link CTA, divider) sin duplicar.
- Wrap final con `AdaptiveScaffold(compact: _CompactLogin, expanded: _SplitLogin, desktop: _SplitLogin con paddings/widths más generosos)`.

**No tocar**: la lógica de `AuthBloc`, los handlers de Google/Apple sign-in. Solo es composición visual.

---

### Fase 3 — Mes adaptativo (la pantalla más importante para este usuario)

**Objetivo**: en expanded, header con stats grid 4 col (Estimado / Pagado / Ingresos / Saldo) + categorías en grilla 2 col. En desktop, sumar aside de "Atención inmediata".

**Archivos a tocar**:
- `lib/features/month/presentation/month_screen.dart` — wrap en `AdaptiveScaffold`.
- `lib/features/month/presentation/widgets/month_header_section.dart` — variante de header para 4 cards en una fila cuando hay espacio.
- `lib/features/month/presentation/widgets/month_group_section.dart` — soportar `gridColumns` (1 / 2 / 3) en el item layout.

**Lógica**:
- `_CompactMonth` = lo que hay hoy.
- `_ExpandedMonth`: header con 4 stat cards en una sola fila; lista de categorías que renderiza sus ítems en `Wrap` 2 col cuando aplica.
- `_DesktopMonth`: sidebar (delegado al shell), main con grid 3 col, aside derecha con próximos vencimientos / distribución del mes.

**No tocar**: `MonthBloc`, `MonthBuilder`, queries. Es trabajo puramente de layout.

**MonthItemCard**: ya existe y se reusa idéntico. Si en algún caso hace falta una variante "dense" para grillas, se agrega un `bool dense` opcional sin romper el constructor actual.

---

### Fase 4 — Tarjetas adaptativo

**Objetivo**: en expanded, master/detail (lista de tarjetas a la izq + detalle de la seleccionada a la der). En desktop, sumar grilla 3 col + aside.

**Archivos a tocar**:
- `lib/features/cards/presentation/cards_screen.dart` (la lista).
- `lib/features/cards/presentation/card_detail_screen.dart` (el detalle).

**Riesgo**: hoy la navegación a detalle es por `push` (`/cards/:id`). En expanded, el detalle vive en la misma pantalla. Hay que decidir si:
- (a) En expanded mantenemos el `push` y solo agrandamos la grilla de cards, sin master/detail. **Más simple, menos riesgo.**
- (b) En expanded sí cambiamos a master/detail dentro de la misma ruta, y el `push` solo aplica en compact.

**Recomendación**: empezar con (a) y dejar (b) para una iteración posterior. Cumple "no se estira" y no requiere reescribir el flujo de selección.

---

### Fase 5 — Config adaptativo

**Objetivo**: en expanded, master (secciones) + detail (sub-pantalla). En desktop, sumar sidebar dual + aside editor.

**Archivos a tocar**:
- `lib/features/config_settings/presentation/config_screen.dart` (lista de secciones).
- Los screens hijos (bills_list, incomes_list, etc.) reusables como detail.

**Misma decisión que en tarjetas**: empezar con grilla amplia en expanded sin master/detail interno, dejar el patrón completo para iteración 2. Cumple el objetivo principal de "no estirado" sin reescribir flujo.

---

## 5. Detalles técnicos no negociables

1. **Usar `LayoutBuilder`, no `MediaQuery.size`**, en el `AdaptiveScaffold`. Razón: `LayoutBuilder` respeta splitscreen/multi-window. Si el usuario tiene otra app abierta al lado, el ancho efectivo puede ser <600 incluso con el Fold abierto.

2. **DisplayFeatures (hinge)**: para el caso del Fold 7 con bisagra, usar `MediaQuery.of(context).displayFeatures` para evitar partir contenido crítico. El helper `isFoldInner` lo encapsula.

3. **Sin librerías externas**: `flutter_adaptive_scaffold` existe como package oficial pero el handoff propuso código propio. Lo respetamos: menos dependencias, control total.

4. **Test del despliegue real**:
   - **Simulador**: el simulador resizable de Flutter (`flutter run -d <chrome|macos>` con DevTools) o el iPhone simulator iPad permite ver el cambio.
   - **Hardware**: probar en el Fold real es la prueba final. El usuario tiene uno (mencionado).

5. **Animaciones de transición**: cuando el ancho cruza un breakpoint, podemos envolver el `AdaptiveScaffold` en `AnimatedSwitcher` para una transición suave en vez de un swap brusco. Lo dejaría como polish para una segunda iteración.

---

## 6. Orden recomendado y commits

| Fase | Commit | Riesgo | Tiempo estimado |
|------|--------|--------|-----------------|
| 0 | Infraestructura responsive (helpers + manifest) | Muy bajo | 15 min |
| 1 | AppShell adaptativo con NavigationRail | Medio (afecta a todas las pantallas) | 30-45 min |
| 2 | Login split | Bajo | 30 min |
| 3 | Mes adaptativo (la pantalla principal) | Medio | 45-60 min |
| 4 | Tarjetas grilla expanded/desktop | Bajo (sin master/detail por ahora) | 30 min |
| 5 | Config grilla expanded/desktop | Bajo | 30 min |

Cada commit deja la app **compilando y funcionando idéntica en celular**. Se pueden mergear de a uno.

---

## 7. Lo que dejo afuera de esta primera tanda

- **Master/detail completo en Tarjetas y Config** (con detalle dentro de la misma pantalla en expanded). Va en una iteración 2.
- **Aside con "atención inmediata"** en desktop (próximos 7 días, distribución del mes). Es una feature nueva, no una adaptación. Va en otra historia.
- **Tema claro / dark switch**: el handoff lo lista como pendiente en Config → Apariencia. Fuera de scope.

---

## 8. Riesgos identificados

| Riesgo | Probabilidad | Mitigación |
|--------|--------------|------------|
| Bloc se resetea al desplegar Fold | Baja | `configChanges` ya configurado + `HydratedBloc` ya activo |
| Navegación pierde la rama activa al cambiar shell | Baja | `StatefulShellRoute.indexedStack` preserva ramas; sólo se cambia el chrome |
| Hinge corta una grilla justo a la mitad | Media | Detectar `displayFeatures` en el `LayoutBuilder` y dejar gutter |
| `AnimatedCurrency` u otros widgets con `TweenAnimationBuilder` reanimen al cruzar breakpoint | Media | Mantener `key` estable en widgets que tienen animaciones internas para que no rebooteen |
| Splitscreen reporta ancho `<600` aunque el Fold esté abierto | Alta (esperable) | Justamente por eso usamos `LayoutBuilder`: aplicamos compact correctamente y el usuario no nota nada raro |

---

## 9. Cómo empezamos

Mi recomendación: hacemos las **Fases 0 y 1** primero, porque son la base y validan que todo el resto funcione sin reinicios. Una vez confirmado en tu Fold, seguimos con Mes (Fase 3) que es la pantalla que más usás.

¿Avanzo con Fase 0 + 1 ahora? Son los cambios de menor riesgo y el preview en tu Fold ya te dejaría ver el `NavigationRail` lateral en lugar del bottom bar.
