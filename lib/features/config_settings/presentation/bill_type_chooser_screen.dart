import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/tokens.dart';
import '../../../design/widgets.dart';

/// Pantalla 0 del alta de gasto — bifurca entre puntual y mes a mes.
///
/// Cada tarjeta abre el formulario de su rama (`new/oneshot` / `new/recurring`)
/// y re-propaga el resultado con `pop(result)` para que la lista de Gastos
/// refresque al volver.
class BillTypeChooserScreen extends StatefulWidget {
  const BillTypeChooserScreen({super.key});

  @override
  State<BillTypeChooserScreen> createState() => _BillTypeChooserScreenState();
}

class _BillTypeChooserScreenState extends State<BillTypeChooserScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FzMotion.slow,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Abre el formulario de la rama elegida. Al guardar, el form navega al
  // home (go('/')) y este chooser se descarta solo; no hay que propagar
  // ningún resultado.
  void _pick(String route) => context.push(route);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FzAppBar(title: 'Nuevo gasto'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 18),
                    child: Text(
                      '¿Qué tipo de gasto querés registrar?',
                      style: TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: FzColors.textDim,
                        height: 1.4,
                      ),
                    ),
                  ),
                  _Staggered(
                    controller: _controller,
                    index: 0,
                    child: _TypeCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Puntual',
                      subtitle: 'Una compra única, como un sillón al contado.',
                      onTap: () => _pick('/config/bills/new/oneshot'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Staggered(
                    controller: _controller,
                    index: 1,
                    child: _TypeCard(
                      icon: Icons.autorenew_rounded,
                      title: 'Mes a mes',
                      subtitle:
                          'Un servicio o cuenta fija recurrente, como Netflix o la luz.',
                      onTap: () => _pick('/config/bills/new/recurring'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Envuelve un hijo con un fade + slide-up escalonado según [index].
class _Staggered extends StatelessWidget {
  const _Staggered({
    required this.controller,
    required this.index,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.12).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1.0, curve: FzMotion.easing),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.xxl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.xxl),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FzColors.card,
            borderRadius: BorderRadius.circular(FzRadius.xxl),
            border: Border.all(color: FzColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: FzColors.primarySoft,
                  borderRadius: BorderRadius.circular(FzRadius.lg),
                  border: Border.all(color: FzColors.borderPaid),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: FzColors.primaryHi),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FzColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 12.5,
                        color: FzColors.textDim,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: FzColors.textMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
