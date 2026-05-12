import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/period.dart';
import '../../../../domain/urgency.dart';
import '../../../../models/enums.dart';
import '../../../../widgets/animated_amount.dart';
import '../../../../widgets/animated_progress_bar.dart';
import '../../../../widgets/fz_snackbar.dart';
import '../../domain/month_item.dart';
import '../bloc/month_bloc.dart';

/// Layout master/detail para Mes en Fold inner / tablet (≥600 dp).
///
/// Estructura: MASTER (320 dp, lista plana de items con tabs Todas/
/// Pagado/Pendiente) + DETAIL (flex, 24 padding: 3 stat cards arriba +
/// hero del item seleccionado + histórico).
///
/// Tap en master row actualiza el detail SIN push de ruta.
class MonthExpandedLayout extends StatelessWidget {
  const MonthExpandedLayout({
    required this.state,
    required this.selectedKey,
    required this.onSelect,
    super.key,
  });

  final MonthBlocState state;
  final String? selectedKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: _MasterPane(
            state: state,
            selectedKey: selectedKey,
            onSelect: onSelect,
          ),
        ),
        Expanded(
          child: _DetailPane(state: state, selectedKey: selectedKey),
        ),
      ],
    );
  }
}

// ============================================================
//  MASTER
// ============================================================

class _MasterPane extends StatelessWidget {
  const _MasterPane({
    required this.state,
    required this.selectedKey,
    required this.onSelect,
  });

  final MonthBlocState state;
  final String? selectedKey;
  final ValueChanged<String> onSelect;

  bool _passesFilter(MonthItem item) {
    switch (state.filter) {
      case MonthFilter.all:
        return true;
      case MonthFilter.pending:
        return item.payment?.status != PaymentStatus.paid;
      case MonthFilter.overdue:
        if (item.payment?.status == PaymentStatus.paid) return false;
        if (item.estimatedAmount == null || item.estimatedAmount! <= 0) {
          return false;
        }
        final urgency = getUrgency(
          dayOfMonth: item.dayOfMonth,
          paid: false,
          period: state.period,
        );
        return urgency is UrgencyOverdue;
    }
  }

  /// Aplana los grupos del mes en una lista mixta `[header, item, item,
  /// header, item, ...]`, respetando el filter activo. Si tras filtrar
  /// un grupo no tiene items visibles, su header se omite.
  List<_MasterEntry> _buildEntries() {
    final entries = <_MasterEntry>[];
    for (final group in state.groups) {
      final visibleItems = group.items.where(_passesFilter).toList();
      if (visibleItems.isEmpty) continue;

      final hasVariable = visibleItems.any((i) => i.estimatedAmount == null);
      final total = hasVariable
          ? null
          : visibleItems.fold<double>(
              0,
              (acc, i) => acc + (i.estimatedAmount ?? 0),
            );

      entries.add(
        _MasterHeaderEntry(
          groupKey: group.key,
          title: group.title,
          count: visibleItems.length,
          totalLabel: hasVariable ? '—' : formatCurrency(total),
        ),
      );
      for (final item in visibleItems) {
        entries.add(_MasterItemEntry(item));
      }
    }
    return entries;
  }

  int _visibleItemCount(List<_MasterEntry> entries) =>
      entries.whereType<_MasterItemEntry>().length;

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final itemCount = _visibleItemCount(entries);
    final overdueCount = state.summary?.overdueCount ?? 0;

    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: FzColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con navegación de mes
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fila navegación: < MAYO 2026 >
                Row(
                  children: [
                    _NavArrow(
                      icon: Icons.chevron_left_rounded,
                      enabled: state.canGoPrevious,
                      onTap: () => context.read<MonthBloc>().add(
                        MonthRequested(state.period.previous()),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatMonth(state.period),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FzType.mono,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: FzColors.textMute,
                          letterSpacing: 1.32,
                        ),
                      ),
                    ),
                    _NavArrow(
                      icon: Icons.chevron_right_rounded,
                      enabled: state.canGoNext,
                      onTap: () => context.read<MonthBloc>().add(
                        MonthRequested(state.period.next()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isCurrentPeriod
                            ? 'Mes actual'
                            : state.isPastPeriod
                            ? 'Mes pasado'
                            : 'Mes futuro',
                        style: const TextStyle(
                          fontFamily: FzType.sans,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.44,
                          color: FzColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        overdueCount > 0
                            ? '${pluralizeCount(itemCount, "cuenta", "cuentas")} · '
                                  '${pluralizeCount(overdueCount, "atrasada", "atrasadas")}'
                            : pluralizeCount(itemCount, 'cuenta', 'cuentas'),
                        style: const TextStyle(
                          fontFamily: FzType.mono,
                          fontSize: 11,
                          color: FzColors.textDim,
                          letterSpacing: 0.44,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabs filter
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Row(
              children: [
                _MasterTab(
                  label: 'TODAS',
                  active: state.filter == MonthFilter.all,
                  onTap: () => context.read<MonthBloc>().add(
                    const MonthFilterChanged(MonthFilter.all),
                  ),
                ),
                const SizedBox(width: 6),
                _MasterTab(
                  label: 'PENDIENTE',
                  active: state.filter == MonthFilter.pending,
                  onTap: () => context.read<MonthBloc>().add(
                    const MonthFilterChanged(MonthFilter.pending),
                  ),
                ),
                const SizedBox(width: 6),
                _MasterTab(
                  label: 'ATRASO',
                  active: state.filter == MonthFilter.overdue,
                  onTap: () => context.read<MonthBloc>().add(
                    const MonthFilterChanged(MonthFilter.overdue),
                  ),
                ),
              ],
            ),
          ),
          // Lista agrupada por categoría — headers + items intercalados,
          // espejo de `MonthGroupSection` del compact. Categorías sin
          // items visibles (por el filter) se omiten.
          Expanded(
            child: entries.isEmpty
                ? const _MasterEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    itemCount: entries.length,
                    itemBuilder: (ctx, i) {
                      final entry = entries[i];
                      switch (entry) {
                        case _MasterHeaderEntry header:
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              4,
                              i == 0 ? 0 : 12,
                              4,
                              6,
                            ),
                            child: _MasterCategoryHeader(
                              icon: _categoryIcon(header.groupKey),
                              title: header.title,
                              count: header.count,
                              totalLabel: header.totalLabel,
                            ),
                          );
                        case _MasterItemEntry itemEntry:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _MasterRow(
                              item: itemEntry.item,
                              period: state.period,
                              selected: itemEntry.item.key == selectedKey,
                              onTap: () => onSelect(itemEntry.item.key),
                            ),
                          );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// "Mayo 2026" — formato sin "de" intermedio, igual que en el header
/// del compact mode. Se usa en el navegador del master.
String _formatMonth(PeriodKey p) {
  final long = p.formatLong();
  return long.replaceFirst(' de ', ' ');
}

/// Botón flecha del navegador de mes en el header del master.
/// Se deshabilita visualmente cuando [enabled] es false (en los bordes
/// del rango navegable según los datos del usuario).
class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(
          icon,
          color: enabled ? FzColors.textDim : FzColors.textMute,
        ),
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

class _MasterTab extends StatelessWidget {
  const _MasterTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? FzColors.cardHi : Colors.transparent,
            borderRadius: BorderRadius.circular(FzRadius.sm),
            border: Border.all(
              color: active ? FzColors.borderHi : FzColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 10.5,
              letterSpacing: 0.44,
              color: active ? FzColors.text : FzColors.textMute,
            ),
          ),
        ),
      ),
    );
  }
}

class _MasterRow extends StatelessWidget {
  const _MasterRow({
    required this.item,
    required this.period,
    required this.selected,
    required this.onTap,
  });

  final MonthItem item;
  final PeriodKey period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paid = item.payment?.status == PaymentStatus.paid;
    final hasAmount = item.estimatedAmount != null && item.estimatedAmount! > 0;
    final urgency = hasAmount
        ? getUrgency(dayOfMonth: item.dayOfMonth, paid: paid, period: period)
        : const Urgency.normal();
    final isOverdue = urgency is UrgencyOverdue;

    final Color bg;
    final Color border;
    if (selected) {
      bg = FzColors.cardHi;
      border = FzColors.borderHi;
    } else if (paid) {
      bg = FzColors.cardPaid;
      border = FzColors.borderPaid;
    } else if (isOverdue) {
      bg = FzColors.cardLate;
      border = FzColors.borderLate;
    } else {
      bg = FzColors.card;
      border = FzColors.border;
    }

    final dotColor = paid
        ? FzColors.primary
        : isOverdue
        ? FzColors.lateColor
        : FzColors.textMute;
    final amountColor = paid
        ? FzColors.primaryHi
        : item.estimatedAmount == null
        ? FzColors.textMute
        : FzColors.text;
    final subtitle = _subtitle(item);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontFamily: FzType.sans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: FzColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: FzType.mono,
                          fontSize: 10.5,
                          letterSpacing: 0.44,
                          color: FzColors.textMute,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.estimatedAmount == null
                    ? '—'
                    : formatCurrency(
                        item.payment?.amountReal ?? item.estimatedAmount,
                      ),
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: FzType.tabularNums,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _subtitle(MonthItem item) {
    final bill = item.bill;
    if (bill != null) {
      final kind = kBillKindShortLabels[bill.kind] ?? '—';
      if (item.dayOfMonth != null) {
        return '$kind · DÍA ${item.dayOfMonth}';
      }
      return kind;
    }
    if (item.kind == MonthItemKind.cardTotal) {
      return item.dayOfMonth != null
          ? 'TARJETA · DÍA ${item.dayOfMonth}'
          : 'TARJETA';
    }
    return null;
  }
}

class _MasterEmpty extends StatelessWidget {
  const _MasterEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Sin items en este mes',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: FzType.sans,
            fontSize: 13,
            color: FzColors.textDim,
          ),
        ),
      ),
    );
  }
}

/// Entradas que componen el master cuando los items se agrupan por
/// categoría: o bien el header de la categoría, o bien una fila de item.
sealed class _MasterEntry {
  const _MasterEntry();
}

class _MasterHeaderEntry extends _MasterEntry {
  const _MasterHeaderEntry({
    required this.groupKey,
    required this.title,
    required this.count,
    required this.totalLabel,
  });

  final String groupKey;
  final String title;
  final int count;
  final String totalLabel;
}

class _MasterItemEntry extends _MasterEntry {
  const _MasterItemEntry(this.item);
  final MonthItem item;
}

/// Header compacto de categoría dentro del master expanded. Versión
/// reducida del `_CategoryHeader` del compact: icono + título mono +
/// count, con el total alineado a la derecha.
class _MasterCategoryHeader extends StatelessWidget {
  const _MasterCategoryHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.totalLabel,
  });

  final IconData icon;
  final String title;
  final int count;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: FzColors.textDim),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.05,
              color: FzColors.textDim,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '· $count',
          style: const TextStyle(
            fontFamily: FzType.mono,
            fontSize: 10.5,
            color: FzColors.textMute,
          ),
        ),
        const Spacer(),
        Text(
          totalLabel,
          style: const TextStyle(
            fontFamily: FzType.mono,
            fontSize: 11,
            color: FzColors.textMute,
            fontFeatures: FzType.tabularNums,
          ),
        ),
      ],
    );
  }
}

/// Icono Material para cada macrocategoría — espejo del `_categoryIcon`
/// usado en `MonthGroupSection` (compact).
IconData _categoryIcon(String macroKey) {
  switch (macroKey) {
    case 'cards':
      return Icons.credit_card_outlined;
    case 'housing':
      return Icons.home_outlined;
    case 'services':
      return Icons.bolt_outlined;
    case 'internet':
      return Icons.wifi;
    case 'health':
      return Icons.local_hospital_outlined;
    case 'tax':
      return Icons.account_balance_outlined;
    case 'subscription':
      return Icons.subscriptions_outlined;
    case 'other':
    default:
      return Icons.label_outline;
  }
}

// ============================================================
//  DETAIL
// ============================================================

class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.state, required this.selectedKey});

  final MonthBlocState state;
  final String? selectedKey;

  MonthItem? _findItem() {
    if (selectedKey == null) return null;
    for (final g in state.groups) {
      for (final item in g.items) {
        if (item.key == selectedKey) return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final item = _findItem();
    final summary = state.summary;

    final estimated = summary?.estimatedTotal ?? 0;
    final paid = summary?.paidTotal ?? 0;
    final paidPct = estimated == 0 ? 0 : ((paid / estimated) * 100).round();
    final overdueAmount = summary?.overdueTotal ?? 0;
    final overdueCount = summary?.overdueCount ?? 0;
    final income = summary?.incomeTotal ?? 0;
    // Saldo = ingreso − pagado (no − estimado): lo que queda disponible
    // hoy. Lo estimado todavía no salió de la cuenta. Ver nota en
    // `month_header_section.dart`.
    final balance = income - paid;
    final hasIncome = income > 0;

    final hasGroups = state.groups.isNotEmpty;
    final upcoming = _upcomingItems();
    final distributionRows = _distributionRows();
    final totalCount = summary?.totalCount ?? 0;
    final progressRatio = totalCount == 0
        ? 0.0
        : (summary!.paidCount / totalCount).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TotalCard(
            estimated: estimated,
            paidCount: summary?.paidCount ?? 0,
            pendingCount: summary?.pendingCount ?? 0,
            progress: progressRatio,
          ),
          const SizedBox(height: 10),
          // PAGADO + ATRASADO. Sin IntrinsicHeight: con AnimatedCurrency
          // adentro generaba un loop de re-layout que disparaba el assert
          // `_debugRelayoutBoundaryAlreadyMarkedNeedsLayout`.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _StatCard(
                  label: 'PAGADO',
                  tone: _StatTone.paid,
                  amount: paid,
                  sub: '$paidPct% del mes',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'ATRASADO',
                  tone: _StatTone.late,
                  amount: overdueAmount,
                  sub: overdueCount == 0
                      ? 'sin atrasos'
                      : pluralizeCount(overdueCount, 'cuenta', 'cuentas'),
                ),
              ),
            ],
          ),
          if (hasIncome) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'INGRESOS',
                    tone: _StatTone.paid,
                    amount: income,
                    sub: 'del mes',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'SALDO',
                    tone: balance >= 0 ? _StatTone.paid : _StatTone.late,
                    amount: balance,
                    sub: balance >= 0 ? 'a favor' : 'déficit',
                  ),
                ),
              ],
            ),
          ],
          // RepaintBoundary aísla el hero del resto del scroll: un cambio
          // dentro del hero (input, spinner, monto re-marcado) no propaga
          // re-layouts a los panels de arriba/abajo.
          if (item != null) ...[
            const SizedBox(height: 14),
            RepaintBoundary(
              child: _ItemHero(
                item: item,
                period: state.period,
                isMutating: state.mutatingItemKey == item.key,
              ),
            ),
          ],
          if (!hasGroups && item == null) ...[
            const SizedBox(height: 14),
            const _DetailEmpty(),
          ],
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 14),
            _UpcomingPanel(items: upcoming, period: state.period),
          ],
          if (distributionRows.isNotEmpty) ...[
            const SizedBox(height: 14),
            _DistributionPanel(
              rows: distributionRows,
              estimatedTotal: estimated,
            ),
          ],
        ],
      ),
    );
  }

  /// Items pendientes ordenados por día de vencimiento (más próximos
  /// primero). Limita a 5 para no llenar la pantalla.
  List<MonthItem> _upcomingItems() {
    final pending = <MonthItem>[];
    for (final g in state.groups) {
      for (final i in g.items) {
        if (i.payment?.status == PaymentStatus.paid) continue;
        pending.add(i);
      }
    }
    pending.sort((a, b) {
      final da = a.dayOfMonth ?? 99;
      final db = b.dayOfMonth ?? 99;
      if (da != db) return da - db;
      return a.label.compareTo(b.label);
    });
    return pending.take(5).toList();
  }

  /// Filas para el panel de distribución: una por grupo con monto > 0,
  /// ordenadas de mayor a menor.
  List<({String key, String title, String emoji, double amount})>
  _distributionRows() {
    final rows =
        <({String key, String title, String emoji, double amount})>[];
    for (final g in state.groups) {
      if (g.estimatedTotal <= 0) continue;
      rows.add((
        key: g.key,
        title: g.title,
        emoji: g.emoji,
        amount: g.estimatedTotal,
      ));
    }
    rows.sort((a, b) => b.amount.compareTo(a.amount));
    return rows;
  }
}

enum _StatTone { neutral, paid, late }

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    this.sub,
    this.tone = _StatTone.neutral,
  });

  final String label;
  final double amount;
  final String? sub;
  final _StatTone tone;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      _StatTone.neutral => FzColors.card,
      _StatTone.paid => FzColors.cardPaid,
      _StatTone.late => FzColors.cardLate,
    };
    final border = switch (tone) {
      _StatTone.neutral => FzColors.border,
      _StatTone.paid => FzColors.borderPaid,
      _StatTone.late => FzColors.borderLate,
    };
    final labelColor = switch (tone) {
      _StatTone.neutral => FzColors.textMute,
      _StatTone.paid => FzColors.primary,
      _StatTone.late => FzColors.lateInk,
    };
    final valueColor = switch (tone) {
      _StatTone.neutral => FzColors.text,
      _StatTone.paid => FzColors.primaryHi,
      _StatTone.late => FzColors.text,
    };
    final subColor = switch (tone) {
      _StatTone.neutral => FzColors.textDim,
      _StatTone.paid => FzColors.primary,
      _StatTone.late => FzColors.lateInk,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.84,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedCurrency(
              value: amount,
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                fontFeatures: FzType.tabularNums,
                color: valueColor,
              ),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(
              sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 9.5,
                color: subColor,
                letterSpacing: 0.44,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card grande "TOTAL DEL MES" con monto + barra de progreso pagado/total.
/// Reemplaza el `_StatCard(big: true)` para aprovechar mejor el ancho.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.estimated,
    required this.paidCount,
    required this.pendingCount,
    required this.progress,
  });

  final double estimated;
  final int paidCount;
  final int pendingCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL DEL MES',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.84,
                    color: FzColors.textMute,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 11,
                  color: FzColors.textDim,
                  letterSpacing: 0.44,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedCurrency(
              value: estimated,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.55,
                fontFeatures: FzType.tabularNums,
                color: FzColors.text,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedProgressBar(value: progress),
          const SizedBox(height: 6),
          Text(
            '${pluralizeCount(paidCount, "pagado", "pagados")} · '
            '${pluralizeCount(pendingCount, "pendiente", "pendientes")}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 10.5,
              color: FzColors.textDim,
              letterSpacing: 0.44,
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel "Próximos vencimientos": lista compacta de hasta 5 items
/// pendientes ordenados por día. Usa el mismo lenguaje visual de los
/// master rows pero sin estado de selección.
class _UpcomingPanel extends StatelessWidget {
  const _UpcomingPanel({required this.items, required this.period});

  final List<MonthItem> items;
  final PeriodKey period;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_outlined,
                size: 14,
                color: FzColors.textDim,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PRÓXIMOS VENCIMIENTOS',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.05,
                    color: FzColors.textDim,
                  ),
                ),
              ),
              Text(
                '${items.length}',
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 10.5,
                  color: FzColors.textMute,
                  letterSpacing: 0.44,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++) ...[
            _UpcomingRow(item: items[i], period: period),
            if (i < items.length - 1)
              const Divider(
                height: 12,
                thickness: 0.5,
                color: FzColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.item, required this.period});

  final MonthItem item;
  final PeriodKey period;

  @override
  Widget build(BuildContext context) {
    final hasAmount = item.estimatedAmount != null && item.estimatedAmount! > 0;
    final urgency = hasAmount
        ? getUrgency(dayOfMonth: item.dayOfMonth, paid: false, period: period)
        : const Urgency.normal();
    final isOverdue = urgency is UrgencyOverdue;

    final dayBg = isOverdue ? FzColors.lateSoft : FzColors.cardHi;
    final dayFg = isOverdue ? FzColors.lateInk : FzColors.textDim;

    return Row(
      children: [
        Container(
          width: 38,
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dayBg,
            borderRadius: BorderRadius.circular(FzRadius.sm),
            border: Border.all(
              color: isOverdue ? FzColors.borderLate : FzColors.border,
            ),
          ),
          child: Text(
            item.dayOfMonth?.toString() ?? '—',
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: FzType.tabularNums,
              color: dayFg,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: FzColors.text,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item.estimatedAmount == null ? '—' : formatCurrency(item.estimatedAmount),
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontFamily: FzType.sans,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            fontFeatures: FzType.tabularNums,
            color: isOverdue ? FzColors.lateInk : FzColors.text,
          ),
        ),
      ],
    );
  }
}

/// Panel "Distribución por categoría": para cada grupo activo, una fila
/// con emoji + nombre + barra horizontal proporcional + monto/%.
class _DistributionPanel extends StatelessWidget {
  const _DistributionPanel({
    required this.rows,
    required this.estimatedTotal,
  });

  final List<({String key, String title, String emoji, double amount})> rows;
  final double estimatedTotal;

  @override
  Widget build(BuildContext context) {
    // El máximo dentro del panel se usa como referencia para escalar
    // las barras (la categoría más grande ocupa el 100% del ancho).
    final maxAmount = rows.fold<double>(0, (m, r) => r.amount > m ? r.amount : m);

    return Container(
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 14,
                color: FzColors.textDim,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DISTRIBUCIÓN POR CATEGORÍA',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.05,
                    color: FzColors.textDim,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            _DistributionBar(
              row: rows[i],
              maxAmount: maxAmount,
              total: estimatedTotal,
            ),
            if (i < rows.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({
    required this.row,
    required this.maxAmount,
    required this.total,
  });

  final ({String key, String title, String emoji, double amount}) row;
  final double maxAmount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount == 0 ? 0.0 : (row.amount / maxAmount).clamp(0.0, 1.0);
    final pct = total == 0 ? 0 : ((row.amount / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(row.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                row.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: FzColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedCurrency(
              value: row.amount,
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                fontFeatures: FzType.tabularNums,
                color: FzColors.text,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 32,
              child: Text(
                '$pct%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 10.5,
                  color: FzColors.textMute,
                  letterSpacing: 0.44,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        AnimatedProgressBar(value: ratio),
      ],
    );
  }
}

// ============================================================
//  ITEM HERO (selected item)
// ============================================================

class _ItemHero extends StatefulWidget {
  const _ItemHero({
    required this.item,
    required this.period,
    required this.isMutating,
  });

  final MonthItem item;
  final PeriodKey period;
  final bool isMutating;

  @override
  State<_ItemHero> createState() => _ItemHeroState();
}

class _ItemHeroState extends State<_ItemHero> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _initialAmountText());
  }

  @override
  void didUpdateWidget(covariant _ItemHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el item (selección distinta) o el monto pagado se actualizó
    // por otro flujo (otro device, ediciones), repoblamos el field.
    final itemChanged = oldWidget.item.key != widget.item.key;
    final amountChanged = oldWidget.item.payment?.amountReal !=
        widget.item.payment?.amountReal;
    if (itemChanged || amountChanged) {
      _amountController.text = _initialAmountText();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Texto inicial del input: pagado real > estimado > promedio reciente
  /// > vacío. Sin decimales (los pesos argentinos van enteros en la UI).
  String _initialAmountText() {
    final paid = widget.item.payment?.amountReal;
    if (paid != null) return paid.toStringAsFixed(0);
    final estimated = widget.item.estimatedAmount;
    if (estimated != null) return estimated.toStringAsFixed(0);
    final avg = widget.item.recentAverage;
    if (avg != null) return avg.roundToDouble().toStringAsFixed(0);
    return '';
  }

  void _snack(String message, {FzSnackKind kind = FzSnackKind.info}) {
    if (!mounted) return;
    showFzSnack(context, message, kind: kind);
  }

  void _submitPaid() {
    if (widget.isMutating) return;
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      _snack('Ingresá un monto válido.', kind: FzSnackKind.error);
      return;
    }
    context.read<MonthBloc>().add(
      MonthMarkPaidRequested(item: widget.item, amount: value),
    );
  }

  void _submitPending() {
    if (widget.isMutating) return;
    context.read<MonthBloc>().add(
      MonthMarkPendingRequested(item: widget.item),
    );
  }

  Future<void> _openPayUrl() async {
    final url = widget.item.bill?.url;
    if (url == null) return;
    final code = widget.item.bill?.providerCode;
    if (code != null && code.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: code));
      if (mounted) {
        _snack('Código $code copiado', kind: FzSnackKind.success);
      }
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('El link no es válido.', kind: FzSnackKind.error);
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _snack('No se pudo abrir el link.', kind: FzSnackKind.error);
    } catch (_) {
      _snack('No se pudo abrir el link.', kind: FzSnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final paid = item.payment?.status == PaymentStatus.paid;
    final hasAmount = item.estimatedAmount != null && item.estimatedAmount! > 0;
    final urgency = hasAmount
        ? getUrgency(
            dayOfMonth: item.dayOfMonth,
            paid: paid,
            period: widget.period,
          )
        : const Urgency.normal();
    final isOverdue = urgency is UrgencyOverdue;

    final bg = paid
        ? FzColors.cardPaid
        : isOverdue
        ? FzColors.cardLate
        : FzColors.card;
    final border = paid
        ? FzColors.borderPaid
        : isOverdue
        ? FzColors.borderLate
        : FzColors.border;
    final accent = paid
        ? FzColors.primaryHi
        : isOverdue
        ? FzColors.lateInk
        : FzColors.textDim;
    final chipBg = paid
        ? FzColors.primarySoft
        : isOverdue
        ? FzColors.lateSoft
        : FzColors.cardHi;
    final chipFg = paid
        ? FzColors.primary
        : isOverdue
        ? FzColors.lateInk
        : FzColors.textDim;

    final chipLabel = paid
        ? 'PAGADA'
        : isOverdue
        ? 'ATRASADA'
        : 'PENDIENTE';

    final bill = item.bill;
    final providerCode = bill?.providerCode;
    final url = bill?.url;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FzRadius.xxl),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chip de estado arriba a la izquierda.
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(FzRadius.xs),
              ),
              child: Text(
                chipLabel,
                style: TextStyle(
                  fontFamily: FzType.mono,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.76,
                  color: chipFg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Título — full width, 1 línea con ellipsis.
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.55,
              color: FzColors.text,
            ),
          ),
          if (_subtitleHero(item) != null) ...[
            const SizedBox(height: 2),
            Text(
              _subtitleHero(item)!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 11,
                letterSpacing: 0.44,
                color: accent,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Input editable de monto a pagar / pagado.
          _AmountInput(controller: _amountController),
          const SizedBox(height: 12),
          // Action buttons PRIMERO. Si el item tiene cells (código/link),
          // van debajo — así las acciones quedan siempre inmediatamente
          // visibles después del input de monto, no se "pierden" abajo.
          //
          // Dos estados, siempre en una sola fila:
          //
          // PAGADO  → "Marcar pendiente" (full width).
          // NO PAGADO → "Marcar pagado" + (si hay url) "Ir a pagar".
          //
          // Si no hay url y el item está pendiente, solo se muestra
          // "Marcar pagado" ocupando toda la fila.
          Row(
            children: paid
                ? [
                    Expanded(
                      child: _HeroAction(
                        label: 'Marcar pendiente',
                        icon: Icons.undo_rounded,
                        loading: widget.isMutating,
                        onTap: _submitPending,
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: _HeroAction(
                        label: 'Marcar pagado',
                        primary: true,
                        icon: Icons.check_rounded,
                        loading: widget.isMutating,
                        onTap: _submitPaid,
                      ),
                    ),
                    if (url != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HeroAction(
                          label: 'Ir a pagar',
                          icon: Icons.open_in_new_rounded,
                          onTap: _openPayUrl,
                        ),
                      ),
                    ],
                  ],
          ),
          // Cells de código de pago + link al portal del proveedor —
          // van al final porque son info secundaria.
          //
          // Stack vertical (no Row+Expanded+stretch) para evitar el bug
          // de Flutter `_debugRelayoutBoundaryAlreadyMarkedNeedsLayout`
          // que se disparaba al insertar este bloque (con anchos iguales
          // forzados) en items que SÍ tienen providerCode/url. El stack
          // vertical no fuerza alturas cruzadas y elimina el cascade.
          if (providerCode != null) ...[
            const SizedBox(height: 12),
            _HeroCell(label: 'CÓDIGO', value: providerCode),
          ],
          if (url != null) ...[
            SizedBox(height: providerCode != null ? 6 : 12),
            _HeroCell(label: 'LINK', value: url, dim: true),
          ],
        ],
      ),
    );
  }

  String? _subtitleHero(MonthItem item) {
    final bill = item.bill;
    if (bill != null) {
      final kind = kBillKindShortLabels[bill.kind] ?? '—';
      if (item.dayOfMonth != null) {
        return '$kind · DÍA ${item.dayOfMonth}';
      }
      return kind;
    }
    if (item.kind == MonthItemKind.cardTotal) {
      return item.dayOfMonth != null
          ? 'TARJETA · DÍA ${item.dayOfMonth}'
          : 'TARJETA';
    }
    return null;
  }
}

/// Input numérico mono con prefijo "$" y label arriba. Reusa el patrón
/// del [`_AmountField`] del compact mode.
class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MONTO PAGADO (ARS)',
          style: TextStyle(
            fontFamily: FzType.mono,
            fontSize: 10,
            color: FzColors.textMute,
            letterSpacing: 0.66,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: FzColors.bg,
            borderRadius: BorderRadius.circular(FzRadius.lg),
            border: Border.all(color: FzColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FzColors.text,
              fontFeatures: FzType.tabularNums,
            ),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
              hintText: '0',
              hintStyle: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FzColors.textDim,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCell extends StatelessWidget {
  const _HeroCell({required this.label, required this.value, this.dim = false});

  final String label;
  final String value;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    // Color SÓLIDO. Antes usaba `Colors.black.withValues(alpha: 0.25)`
    // pero ese semi-transparente sobre un parent con cardLate/cardPaid
    // genera crashes nativos en Impeller (Vulkan) en algunos devices
    // Samsung Fold. Las celdas solo se renderizan cuando un bill tiene
    // providerCode o url (típico en servicios e impuestos), por eso
    // el crash era selectivo.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: FzColors.bg,
        borderRadius: BorderRadius.circular(FzRadius.md),
        border: Border.all(color: FzColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: const TextStyle(
              fontFamily: FzType.mono,
              fontSize: 9.5,
              letterSpacing: 0.66,
              color: FzColors.textMute,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontFamily: FzType.mono,
              fontSize: 12,
              fontWeight: dim ? FontWeight.w400 : FontWeight.w500,
              color: dim ? FzColors.textDim : FzColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  /// Cuando es true, el botón muestra un spinner en lugar del icono y
  /// queda deshabilitado. Reflejamos `state.mutatingItemKey == item.key`
  /// del bloc para evitar doble tap durante la mutación.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // Colores SÓLIDOS, sin alpha. Previo evitamos Opacity envolvente
    // porque `Opacity > Material > InkWell > Container(boxShadow)`
    // crashea en Impeller (Vulkan) en algunos Samsung Fold. El feedback
    // de "loading" lo damos solo con el spinner que reemplaza al icono;
    // no cambiamos colores semi-transparentes ya que también crashean
    // sobre fondos cardLate/cardPaid en esos devices.
    final bg = primary ? FzColors.primary : Colors.transparent;
    final fg = primary ? FzColors.primaryInk : FzColors.text;
    final border = primary ? FzColors.primary : FzColors.borderHi;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
          child: Row(
            // mainAxisAlignment: center → cuando este botón se usa
            // dentro de un `Expanded`, el contenido (icono+label) queda
            // centrado horizontalmente. Si lo usás suelto, el padding
            // del Container ya lo deja con el tamaño justo.
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              else
                Icon(icon, size: 13, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 12.5,
                    fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
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

class _DetailEmpty extends StatelessWidget {
  const _DetailEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.xxl),
        border: Border.all(color: FzColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.touch_app_outlined,
              size: 36,
              color: FzColors.textMute,
            ),
            SizedBox(height: 10),
            Text(
              'Seleccioná una cuenta',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FzColors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tocá un ítem en la lista para ver su detalle.',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 12,
                color: FzColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
