// lib/design/widgets.dart
//
// Kit de widgets reutilizables del sistema de diseño A · Banco premium.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens.dart';

/// Card con borde por defecto, sin sombra.
class FzCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? bg;
  final Color? border;
  final VoidCallback? onTap;

  const FzCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = FzRadius.xxl,
    this.bg,
    this.border,
    this.onTap,
  });

  factory FzCard.paid({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) => FzCard(
    key: key,
    padding: padding ?? const EdgeInsets.all(16),
    bg: FzColors.cardPaid,
    border: FzColors.borderPaid,
    child: child,
  );

  factory FzCard.late_({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) => FzCard(
    key: key,
    padding: padding ?? const EdgeInsets.all(16),
    bg: FzColors.cardLate,
    border: FzColors.borderLate,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? FzColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? FzColors.border, width: 1),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: box,
      ),
    );
  }
}

/// Botón primario con sombra del primary.
class FzPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool loading;

  const FzPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final btn = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FzRadius.lg),
        boxShadow: disabled ? null : FzShadow.ctaPrimary,
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(FzColors.primaryInk),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 16),
            if (!loading && (icon != null)) const SizedBox(width: 8),
            if (!loading) Text(label),
          ],
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Botón "danger" con borde rojo.
class FzDangerButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const FzDangerButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: FzColors.lateColor,
          side: const BorderSide(color: FzColors.borderLate),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: FzColors.lateColor),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Badge mono uppercase (ej. ATRASADA, VARIABLE, PAGADO).
class FzBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const FzBadge({
    super.key,
    required this.label,
    this.bg = FzColors.cardHi,
    this.fg = FzColors.textDim,
  });

  factory FzBadge.late_(String label) =>
      FzBadge(label: label, bg: FzColors.lateSoft, fg: FzColors.lateInk);
  factory FzBadge.paid(String label) =>
      FzBadge(label: label, bg: FzColors.primarySoft, fg: FzColors.primary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
          color: fg,
        ),
      ),
    );
  }
}

/// Caplabel mono uppercase (sub-headers de sección).
class FzCaplabel extends StatelessWidget {
  final String text;
  final Color? color;
  const FzCaplabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: FzType.mono,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
        color: color ?? FzColors.textMute,
      ),
    );
  }
}

/// Logo de marca: cuadrado verde con $ blanco bold.
class FzLogo extends StatelessWidget {
  final double size;
  final Color bg;
  final Color fg;
  final bool shadow;
  const FzLogo({
    super.key,
    this.size = 56,
    this.bg = FzColors.primary,
    this.fg = FzColors.primaryInk,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: shadow ? FzShadow.hero : null,
      ),
      alignment: Alignment.center,
      child: Text(
        r'$',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.55,
          fontFamily: FzType.sans,
          height: 1,
        ),
      ),
    );
  }
}

/// Items de navegación, fuente única para bottom nav y rail.
const List<(String, IconData)> kFzNavItems = [
  ('Inicio', Icons.home_rounded),
  ('Tarjetas', Icons.credit_card_rounded),
  ('Gestión', Icons.tune_rounded),
];

/// Clearance inferior para scrollables/contenido dentro del shell, para que
/// el último ítem suba por encima de la bottom nav flotante (píldora).
///
/// Con `extendBody: true` el body se extiende por detrás de la nav y Flutter
/// suma su alto a `MediaQuery.padding.bottom`; le agregamos un respiro extra.
/// En pantallas full-screen (sin píldora) devuelve solo el safe-area + respiro,
/// así que es seguro usarlo en cualquier scrollable. Fuente única de verdad:
/// si cambia la altura de la nav, se ajusta acá y no pantalla por pantalla.
double fzBottomNavClearance(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 12;

/// Bottom nav flotante en forma de píldora (estilo apps modernas).
///
/// La barra flota sobre el fondo con margen lateral y sombra ([FzShadow.nav]),
/// con esquinas totalmente redondeadas ([FzRadius.pill]). El tab activo se
/// expande mostrando ícono + label con fondo verde suave; los inactivos
/// muestran solo el ícono. Las transiciones son implícitas
/// ([AnimatedContainer]/[AnimatedSize]) para mantenerse fluidas y baratas.
///
/// Se renderiza en el slot `bottomNavigationBar` del Scaffold, así que reserva
/// su propio alto y nunca tapa el contenido scrolleable de las pantallas.
class FzBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  const FzBottomNav({super.key, required this.index, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FzSpace.x6,
        FzSpace.x2,
        FzSpace.x6,
        FzSpace.x3,
      ),
      // Row (no Center) para centrar horizontalmente sin expandir el alto:
      // Center se estiraría a todo el alto del slot bottomNavigationBar y
      // empujaría el body a 0. El Row ajusta su alto al de la píldora.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: FzColors.cardHi,
              borderRadius: BorderRadius.circular(FzRadius.pill),
              border: Border.all(color: FzColors.borderHi),
              boxShadow: FzShadow.nav,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < kFzNavItems.length; i++)
                  _PillNavItem(
                    label: kFzNavItems[i].$1,
                    icon: kFzNavItems[i].$2,
                    selected: i == index,
                    // Siempre notificamos, incluso al tocar la pestaña ya
                    // activa: eso permite volver a la página principal de la
                    // sección (initialLocation) cuando hay un sub-flujo abierto.
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChange(i);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un tab de [FzBottomNav]. Activo: píldora verde con ícono + label.
/// Inactivo: solo ícono. El label aparece/desaparece con [AnimatedSize].
class _PillNavItem extends StatelessWidget {
  const _PillNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? FzColors.primary : FzColors.textMute;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: FzMotion.normal,
        curve: FzMotion.easing,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? FzColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(FzRadius.pill),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(FzRadius.pill),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: selected ? FzSpace.x4 : FzSpace.x3,
                vertical: FzSpace.x3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: fg),
                  AnimatedSize(
                    duration: FzMotion.normal,
                    curve: FzMotion.easing,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: FzSpace.x2),
                            child: Text(
                              label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontFamily: FzType.sans,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: FzColors.primary,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rail de navegación vertical (3 tabs: Inicio / Tarjetas / Gestión) para
/// layouts `expanded` y `desktop`. Espejo de [FzBottomNav]: misma data,
/// misma estética (pill verde para activo), mismo color de marca.
///
/// Por defecto mide 88 dp de ancho (Fold inner / tablet vertical). En
/// desktop se puede pasar [extended] = true para que crezca a ~220 dp
/// con labels más prominentes.
class FzNavRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  final bool extended;
  const FzNavRail({
    super.key,
    required this.index,
    required this.onChange,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    const items = kFzNavItems;

    return Container(
      width: extended ? 220 : 88,
      decoration: const BoxDecoration(
        color: FzColors.bg,
        border: Border(right: BorderSide(color: FzColors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RailItem(
                    label: items[i].$1,
                    icon: items[i].$2,
                    selected: i == index,
                    extended: extended,
                    onTap: () => onChange(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? FzColors.primary : FzColors.textMute;
    return Material(
      color: selected ? FzColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: Padding(
          padding: extended
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: extended
              ? Row(
                  children: [
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// AppBar con back button + título.
class FzAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;
  const FzAppBar({super.key, required this.title, this.trailing, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: FzColors.border),
              borderRadius: BorderRadius.circular(FzRadius.md),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back,
                size: 18,
                color: FzColors.text,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.17,
                color: FzColors.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Chip pequeño para marca de tarjeta (VISA / MC / MP).
class FzBrandChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const FzBrandChip({
    super.key,
    required this.label,
    required this.bg,
    this.fg = Colors.white,
  });

  factory FzBrandChip.visa() =>
      const FzBrandChip(label: 'VISA', bg: FzColors.visaBg);
  factory FzBrandChip.mc() =>
      const FzBrandChip(label: 'Mastercard', bg: FzColors.mastercardBg);
  factory FzBrandChip.mp() =>
      const FzBrandChip(label: 'MercadoPago', bg: FzColors.mpBg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FzType.sans,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
          color: fg,
        ),
      ),
    );
  }
}
