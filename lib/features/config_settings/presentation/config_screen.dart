import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adaptive_scaffold.dart';
import '../../../core/analytics_service.dart';
import '../../../core/biometric_service.dart';
import '../../../data/bills_repository.dart';
import '../../../data/cards_repository.dart';
import '../../../data/incomes_repository.dart';
import '../../../design/tokens.dart';
import '../../../widgets/shimmer_box.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import 'widgets/config_expanded_layout.dart';

/// Pantalla 8 — Configuración.
/// Port del JSX `AConfig` (handoff/screens-a-config.jsx).
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int? _billsCount;
  int? _cardsCount;
  int? _incomesCount;
  bool _loadingCounts = false;
  String? _countsError;

  @override
  void initState() {
    super.initState();
    _loadCounts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsService>().screenView('config');
    });
  }

  Future<void> _loadCounts() async {
    setState(() {
      _loadingCounts = true;
      _countsError = null;
    });
    try {
      final billsRepo = context.read<BillsRepository>();
      final cardsRepo = context.read<CardsRepository>();
      final incomesRepo = context.read<IncomesRepository>();
      final billsFuture = billsRepo.fetchAllActive();
      final cardsFuture = cardsRepo.fetchAllActive();
      final incomesFuture = incomesRepo.fetchAllActive();
      final bills = await billsFuture;
      final cards = await cardsFuture;
      final incomes = await incomesFuture;
      if (!mounted) return;
      setState(() {
        _billsCount = bills.length;
        _cardsCount = cards.length;
        _incomesCount = incomes.length;
        _loadingCounts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _countsError = e.toString();
        _loadingCounts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: BlocBuilder<AuthBloc, AuthBlocState>(
        builder: (context, authState) {
          return AdaptiveScaffold(
            compact: (_) => SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: FzColors.primary,
                backgroundColor: FzColors.card,
                onRefresh: _loadCounts,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const _Header(),
                    if (authState.email != null)
                      _SessionCard(email: authState.email!),
                    const SizedBox(height: 18),
                    const _SectionCaplabel('DATOS'),
                    const SizedBox(height: 8),
                    _DataRows(
                      billsCount: _billsCount,
                      cardsCount: _cardsCount,
                      incomesCount: _incomesCount,
                      loading:
                          _loadingCounts &&
                          _billsCount == null &&
                          _cardsCount == null &&
                          _incomesCount == null,
                      error: _countsError,
                    ),
                    const SizedBox(height: 18),
                    const _SectionCaplabel('SEGURIDAD'),
                    const SizedBox(height: 8),
                    const _BiometricCard(),
                    const SizedBox(height: 24),
                    const _LogoutButton(),
                    const SizedBox(height: 20),
                    const _Footer(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            expanded: (_) => SafeArea(
              bottom: false,
              child: ConfigExpandedLayout(
                email: authState.email,
                billsCount: _billsCount,
                cardsCount: _cardsCount,
                incomesCount: _incomesCount,
                loading: _loadingCounts,
                error: _countsError,
                biometricCard: const _BiometricCard(),
                logoutButton: const _LogoutButton(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Text(
        'Gestión',
        style: TextStyle(
          fontFamily: FzType.sans,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.65,
          color: FzColors.text,
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.email});
  final String email;

  String get _initial {
    final t = email.trim();
    return t.isEmpty ? '·' : t.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: FzColors.card,
          borderRadius: BorderRadius.circular(FzRadius.xl),
          border: Border.all(color: FzColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: FzColors.primarySoft,
                borderRadius: BorderRadius.circular(FzRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(
                _initial,
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FzColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SESIÓN INICIADA COMO',
                    style: TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.63,
                      color: FzColors.textMute,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: FzColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _SectionCaplabel extends StatelessWidget {
  const _SectionCaplabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: FzType.mono,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.1,
          color: FzColors.textMute,
        ),
      ),
    );
  }
}

class _DataRows extends StatelessWidget {
  const _DataRows({
    required this.billsCount,
    required this.cardsCount,
    required this.incomesCount,
    required this.loading,
    required this.error,
  });

  final int? billsCount;
  final int? cardsCount;
  final int? incomesCount;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _DataRow(
            icon: Icons.savings_outlined,
            label: 'Ingresos',
            count: incomesCount,
            loading: loading,
            error: error != null,
            onOpenList: () => context.push('/config/incomes'),
            onCreate: () => context.push('/config/incomes/new'),
          ),
          const SizedBox(height: 8),
          _DataRow(
            icon: Icons.description_outlined,
            label: 'Gastos',
            count: billsCount,
            loading: loading,
            error: error != null,
            onOpenList: () => context.push('/config/bills'),
            onCreate: () => context.push('/config/bills/new'),
          ),
          const SizedBox(height: 8),
          _DataRow(
            icon: Icons.credit_card_outlined,
            label: 'Tarjetas',
            count: cardsCount,
            loading: loading,
            error: error != null,
            onOpenList: () => context.push('/config/cards'),
            onCreate: () => context.push('/config/cards/new'),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.loading,
    required this.error,
    required this.onOpenList,
    required this.onCreate,
  });

  final IconData icon;
  final String label;
  final int? count;
  final bool loading;
  final bool error;
  final VoidCallback onOpenList;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.xl),
      child: InkWell(
        onTap: onOpenList,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: FzColors.card,
            borderRadius: BorderRadius.circular(FzRadius.xl),
            border: Border.all(color: FzColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FzColors.cardHi,
                  borderRadius: BorderRadius.circular(FzRadius.md),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: FzColors.textDim),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: FzColors.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: ShimmerBox(width: 60, height: 11, radius: 2),
                      )
                    else if (error)
                      const Text(
                        '— activas',
                        style: TextStyle(
                          fontFamily: FzType.mono,
                          fontSize: 11,
                          color: FzColors.textMute,
                          letterSpacing: 0.44,
                        ),
                      )
                    else
                      Text(
                        '${count ?? 0} ${(count ?? 0) == 1 ? "activa" : "activas"}',
                        style: const TextStyle(
                          fontFamily: FzType.mono,
                          fontSize: 11,
                          color: FzColors.textMute,
                          letterSpacing: 0.44,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AddSquareButton(onPressed: onCreate),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: FzColors.textMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSquareButton extends StatelessWidget {
  const _AddSquareButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FzColors.primarySoft,
      borderRadius: BorderRadius.circular(FzRadius.sm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FzRadius.sm),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: FzColors.borderPaid),
            borderRadius: BorderRadius.circular(FzRadius.sm),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add_rounded,
            size: 14,
            color: FzColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Card de bloqueo biométrico — replica el patrón del JSX (icono +
/// title + sub + Switch) usando el BiometricService real.
class _BiometricCard extends StatefulWidget {
  const _BiometricCard();

  @override
  State<_BiometricCard> createState() => _BiometricCardState();
}

class _BiometricCardState extends State<_BiometricCard> {
  late final BiometricService _service;
  late bool _enabled;
  bool? _supported;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service = context.read<BiometricService>();
    _enabled = _service.enabledCached;
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final ok = await _service.isAvailable();
    if (!mounted) return;
    setState(() => _supported = ok);
  }

  Future<void> _toggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);
    final analytics = context.read<AnalyticsService>();
    if (!value) {
      await _service.setEnabled(false);
      unawaited(analytics.biometricToggled(enabled: false));
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _busy = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Bloqueo biométrico desactivado.')),
      );
      return;
    }

    try {
      final ok = await _service.authenticate(
        reason: 'Verificá tu identidad para activar el bloqueo',
      );
      if (!mounted) return;
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Verificación cancelada.')),
        );
        setState(() => _busy = false);
        return;
      }
      await _service.setEnabled(true);
      unawaited(analytics.biometricToggled(enabled: true));
      if (!mounted) return;
      setState(() {
        _enabled = true;
        _busy = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Bloqueo biométrico activado.')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Biométrico [${e.code}]: ${e.message ?? "sin mensaje"}',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canToggle = _supported == true && !_busy;
    final subtitle = switch (_supported) {
      null => 'Verificando…',
      false => 'Tu dispositivo no tiene biometría configurada',
      true => 'Pedir Face ID / huella al abrir o volver a la app',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: FzColors.card,
          borderRadius: BorderRadius.circular(FzRadius.xl),
          border: Border.all(color: FzColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FzColors.cardHi,
                borderRadius: BorderRadius.circular(FzRadius.md),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 18,
                color: FzColors.textDim,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bloqueo biométrico',
                    style: TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FzColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 11.5,
                      color: FzColors.textMute,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(value: _enabled, onChanged: canToggle ? _toggle : null),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: FzColors.lateColor,
            side: const BorderSide(color: FzColors.borderLate),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FzRadius.lg),
            ),
          ),
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthSignOutRequested()),
          icon: const Icon(
            Icons.logout_rounded,
            size: 15,
            color: FzColors.lateColor,
          ),
          label: const Text(
            'Cerrar sesión',
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'FINANZAPP · v1.0.0',
        style: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 10,
          color: FzColors.textMute,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
