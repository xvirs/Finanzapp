// lib/design/widgets.dart
//
// Kit de widgets reutilizables del sistema de diseño A · Banco premium.

import 'package:flutter/material.dart';
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
  }) =>
      FzCard(
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
  }) =>
      FzCard(
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

/// Bottom nav de 3 tabs (Mes / Tarjetas / Config). Tab activo: pill verde.
class FzBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  const FzBottomNav({super.key, required this.index, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Mes', Icons.calendar_today_outlined),
      ('Tarjetas', Icons.credit_card_outlined),
      ('Config', Icons.settings_outlined),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: FzColors.bg,
        border: Border(top: BorderSide(color: FzColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChange(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: i == index
                            ? FzColors.primarySoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(FzRadius.md),
                      ),
                      child: Icon(
                        items[i].$2,
                        size: 20,
                        color: i == index
                            ? FzColors.primary
                            : FzColors.textMute,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: i == index
                            ? FzColors.primary
                            : FzColors.textMute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
              icon: const Icon(Icons.arrow_back,
                  size: 18, color: FzColors.text),
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
