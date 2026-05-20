import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/realtime_service.dart';
import '../../../../data/bills_repository.dart';
import '../../../../data/cards_repository.dart';
import '../../../../data/incomes_repository.dart';
import '../../../../design/tokens.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bills_list_screen.dart';
import '../bloc/bills_list_bloc.dart';
import '../bloc/cards_list_bloc.dart';
import '../bloc/incomes_list_bloc.dart';
import '../cards_list_screen.dart';
import '../incomes_list_screen.dart';

/// Master/detail para Configuración en Fold inner.
/// Master 280 dp con session card + secciones; detail flex con la
/// sección activa embebida (sin push de ruta).
class ConfigExpandedLayout extends StatefulWidget {
  const ConfigExpandedLayout({
    required this.email,
    required this.billsCount,
    required this.cardsCount,
    required this.incomesCount,
    required this.loading,
    required this.error,
    required this.biometricCard,
    required this.logoutButton,
    required this.deleteAccountButton,
    super.key,
  });

  final String? email;
  final int? billsCount;
  final int? cardsCount;
  final int? incomesCount;
  final bool loading;
  final String? error;
  final Widget biometricCard;
  final Widget logoutButton;
  final Widget deleteAccountButton;

  @override
  State<ConfigExpandedLayout> createState() => _ConfigExpandedLayoutState();
}

enum _Section { security, bills, incomes, cards }

class _ConfigExpandedLayoutState extends State<ConfigExpandedLayout> {
  _Section _selected = _Section.security;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: _Master(
            email: widget.email,
            billsCount: widget.billsCount,
            cardsCount: widget.cardsCount,
            incomesCount: widget.incomesCount,
            selected: _selected,
            onSelect: (s) => setState(() => _selected = s),
          ),
        ),
        Expanded(
          child: _Detail(
            section: _selected,
            biometricCard: widget.biometricCard,
            logoutButton: widget.logoutButton,
            deleteAccountButton: widget.deleteAccountButton,
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  MASTER
// ============================================================

class _Master extends StatelessWidget {
  const _Master({
    required this.email,
    required this.billsCount,
    required this.cardsCount,
    required this.incomesCount,
    required this.selected,
    required this.onSelect,
  });

  final String? email;
  final int? billsCount;
  final int? cardsCount;
  final int? incomesCount;
  final _Section selected;
  final ValueChanged<_Section> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: FzColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión',
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.44,
                    color: FzColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'VERSIÓN 2.0',
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 11,
                    color: FzColors.textDim,
                    letterSpacing: 1.1,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 14),
                  _SessionMini(email: email!),
                ],
              ],
            ),
          ),
          // Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              children: [
                const _SectionCap('DATOS'),
                _MasterRow(
                  icon: Icons.savings_outlined,
                  label: 'Ingresos',
                  count: incomesCount,
                  selected: selected == _Section.incomes,
                  onTap: () => onSelect(_Section.incomes),
                ),
                _MasterRow(
                  icon: Icons.description_outlined,
                  label: 'Gastos',
                  count: billsCount,
                  selected: selected == _Section.bills,
                  onTap: () => onSelect(_Section.bills),
                ),
                _MasterRow(
                  icon: Icons.credit_card_outlined,
                  label: 'Tarjetas',
                  count: cardsCount,
                  selected: selected == _Section.cards,
                  onTap: () => onSelect(_Section.cards),
                ),
                const SizedBox(height: 8),
                const _SectionCap('PREFERENCIAS'),
                _MasterRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Seguridad',
                  selected: selected == _Section.security,
                  onTap: () => onSelect(_Section.security),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionMini extends StatelessWidget {
  const _SessionMini({required this.email});
  final String email;

  String get _initial {
    final t = email.trim();
    return t.isEmpty ? '·' : t.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        border: Border.all(color: FzColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FzColors.primarySoft,
              borderRadius: BorderRadius.circular(FzRadius.md),
            ),
            child: Text(
              _initial,
              style: const TextStyle(
                fontFamily: FzType.mono,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: FzColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: FzColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                const Text(
                  'SESIÓN INICIADA',
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 9.5,
                    color: FzColors.textMute,
                    letterSpacing: 0.44,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCap extends StatelessWidget {
  const _SectionCap(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: FzType.mono,
          fontSize: 10,
          letterSpacing: 1.2,
          color: FzColors.textMute,
        ),
      ),
    );
  }
}

class _MasterRow extends StatelessWidget {
  const _MasterRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? FzColors.cardHi : Colors.transparent;
    final border = selected ? FzColors.borderHi : Colors.transparent;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FzColors.card,
                  borderRadius: BorderRadius.circular(FzRadius.md),
                  border: Border.all(color: FzColors.border),
                ),
                child: Icon(icon, size: 15, color: FzColors.textDim),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FzColors.text,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: FzColors.cardHi,
                    borderRadius: BorderRadius.circular(FzRadius.xs),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FzColors.textDim,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  DETAIL
// ============================================================

class _Detail extends StatelessWidget {
  const _Detail({
    required this.section,
    required this.biometricCard,
    required this.logoutButton,
    required this.deleteAccountButton,
  });

  final _Section section;
  final Widget biometricCard;
  final Widget logoutButton;
  final Widget deleteAccountButton;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case _Section.security:
        return _SecurityDetail(
          biometricCard: biometricCard,
          logoutButton: logoutButton,
          deleteAccountButton: deleteAccountButton,
        );
      case _Section.bills:
        return BlocProvider(
          create: (ctx) => BillsListBloc(
            billsRepository: ctx.read<BillsRepository>(),
            cardsRepository: ctx.read<CardsRepository>(),
            realtimeService: ctx.read<RealtimeService>(),
          )..add(const BillsListRequested()),
          child: _SectionFrame(
            eyebrow: 'DATOS',
            title: 'Gastos',
            ctaLabel: '+ Nueva cuenta',
            onCta: () => context.push('/config/bills/new'),
            child: const BillsListScreen(showAppBar: false),
          ),
        );
      case _Section.incomes:
        return BlocProvider(
          create: (ctx) => IncomesListBloc(
            incomesRepository: ctx.read<IncomesRepository>(),
            realtimeService: ctx.read<RealtimeService>(),
          )..add(const IncomesListRequested()),
          child: _SectionFrame(
            eyebrow: 'DATOS',
            title: 'Ingresos',
            ctaLabel: '+ Nuevo ingreso',
            onCta: () => context.push('/config/incomes/new'),
            child: const IncomesListScreen(showAppBar: false),
          ),
        );
      case _Section.cards:
        return BlocProvider(
          create: (ctx) => CardsListBloc(
            cardsRepository: ctx.read<CardsRepository>(),
            realtimeService: ctx.read<RealtimeService>(),
          )..add(const CardsListRequested()),
          child: _SectionFrame(
            eyebrow: 'DATOS',
            title: 'Tarjetas',
            ctaLabel: '+ Nueva tarjeta',
            onCta: () => context.push('/config/cards/new'),
            child: const CardsListScreen(showAppBar: false),
          ),
        );
    }
  }
}

class _SecurityDetail extends StatelessWidget {
  const _SecurityDetail({
    required this.biometricCard,
    required this.logoutButton,
    required this.deleteAccountButton,
  });

  final Widget biometricCard;
  final Widget logoutButton;
  final Widget deleteAccountButton;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthBlocState>(
      builder: (context, authState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'PREFERENCIAS',
                style: TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  letterSpacing: 1.1,
                  color: FzColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Seguridad',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: FzColors.text,
                ),
              ),
              const SizedBox(height: 18),
              biometricCard,
              const SizedBox(height: 20),
              logoutButton,
              const SizedBox(height: 8),
              deleteAccountButton,
            ],
          ),
        );
      },
    );
  }
}

/// Frame común para las secciones embebidas en el detail pane: header
/// con eyebrow + título + CTA, y debajo el [child] (la screen embebida
/// sin su propio AppBar).
class _SectionFrame extends StatelessWidget {
  const _SectionFrame({
    required this.eyebrow,
    required this.title,
    required this.ctaLabel,
    required this.onCta,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String ctaLabel;
  final VoidCallback onCta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        fontFamily: FzType.mono,
                        fontSize: 10.5,
                        letterSpacing: 1.1,
                        color: FzColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.44,
                        color: FzColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: FzColors.primary,
                borderRadius: BorderRadius.circular(FzRadius.md),
                child: InkWell(
                  onTap: onCta,
                  borderRadius: BorderRadius.circular(FzRadius.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FzRadius.md),
                      boxShadow: FzShadow.ctaPrimary,
                    ),
                    child: Text(
                      ctaLabel,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: FzColors.primaryInk,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
