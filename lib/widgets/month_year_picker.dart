import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../domain/period.dart';
import 'form_widgets.dart';

/// Selector mes/año reusable. Muestra el mes seleccionado dentro de un
/// [FormFieldShell] y al tocarlo abre un bottom sheet con grilla de
/// meses + selector de año.
class MonthYearPicker extends StatelessWidget {
  const MonthYearPicker({
    required this.value,
    required this.onChanged,
    this.minPeriod,
    this.maxPeriod,
    this.placeholder = 'Elegir mes',
    this.allowClear = false,
    super.key,
  });

  final PeriodKey? value;
  final ValueChanged<PeriodKey?> onChanged;
  final PeriodKey? minPeriod;
  final PeriodKey? maxPeriod;
  final String placeholder;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    return FormFieldShell(
      onTap: () async {
        // Cerrar teclado antes de abrir el sheet: si un campo de texto
        // tenía foco, al cerrarse el sheet el teclado reaparecía.
        FocusManager.instance.primaryFocus?.unfocus();
        final picked = await showModalBottomSheet<_PickResult>(
          context: context,
          backgroundColor: FzColors.card,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _PickerSheet(
            initial: value ?? PeriodKey.current(),
            min: minPeriod,
            max: maxPeriod,
            allowClear: allowClear,
          ),
        );
        if (picked == null) return;
        if (picked.cleared) {
          onChanged(null);
        } else {
          onChanged(picked.period);
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              value == null ? placeholder : value!.formatLong(),
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 14,
                color: value == null ? FzColors.textMute : FzColors.text,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: FzColors.textDim,
          ),
        ],
      ),
    );
  }
}

class _PickResult {
  const _PickResult({this.period, this.cleared = false});
  final PeriodKey? period;
  final bool cleared;
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.initial,
    required this.min,
    required this.max,
    required this.allowClear,
  });

  final PeriodKey initial;
  final PeriodKey? min;
  final PeriodKey? max;
  final bool allowClear;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
  }

  bool _isMonthAllowed(int monthZero) {
    final candidate = PeriodKey(year: _year, month: monthZero);
    if (widget.min != null && candidate.compareTo(widget.min!) < 0) return false;
    if (widget.max != null && candidate.compareTo(widget.max!) > 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabels = const [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FzColors.borderHi,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => _year -= 1),
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: FzColors.text,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _year.toString(),
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: FzColors.text,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _year += 1),
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: FzColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Months grid (4x3)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: List.generate(12, (i) {
                final allowed = _isMonthAllowed(i);
                final isSelected = widget.initial.year == _year &&
                    widget.initial.month == i;
                return _MonthChip(
                  label: monthLabels[i],
                  enabled: allowed,
                  selected: isSelected,
                  onTap: () {
                    Navigator.of(context).pop(
                      _PickResult(
                        period: PeriodKey(year: _year, month: i),
                      ),
                    );
                  },
                );
              }),
            ),
            if (widget.allowClear) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(
                  const _PickResult(cleared: true),
                ),
                child: const Text('Limpiar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? FzColors.primary
        : enabled
            ? FzColors.cardHi
            : FzColors.card;
    final fg = selected
        ? FzColors.primaryInk
        : enabled
            ? FzColors.text
            : FzColors.textMute;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(FzRadius.md),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? FzColors.primary : FzColors.border,
            ),
            borderRadius: BorderRadius.circular(FzRadius.md),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
