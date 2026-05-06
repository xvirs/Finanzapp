import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../data/incomes_repository.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../domain/period.dart';
import '../../../models/enums.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/form_widgets.dart';
import '../../../widgets/month_year_picker.dart';

/// Crear/editar un ingreso. Espejo simétrico de [BillFormScreen].
class IncomeFormScreen extends StatefulWidget {
  const IncomeFormScreen({this.incomeId, super.key});

  final String? incomeId;

  bool get isEditing => incomeId != null;

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();
  final _notesController = TextEditingController();

  IncomeKind _kind = IncomeKind.salary;
  bool _active = true;
  String _startPeriod = PeriodKey.current().toIso();
  String? _endPeriod;

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool get _isOneShot => _endPeriod != null && _endPeriod == _startPeriod;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      if (!widget.isEditing) {
        setState(() => _loading = false);
        return;
      }
      final repo = context.read<IncomesRepository>();
      final income = await repo.fetchById(widget.incomeId!);
      if (income == null) {
        setState(() {
          _loadError = 'No se encontró el ingreso.';
          _loading = false;
        });
        return;
      }
      _nameController.text = income.name;
      _amountController.text = income.defaultAmount?.toStringAsFixed(0) ?? '';
      _dayController.text = income.dayOfMonth?.toString() ?? '';
      _notesController.text = income.notes ?? '';
      _kind = income.kind;
      _active = income.active;
      _startPeriod = income.startPeriod;
      _endPeriod = income.endPeriod;
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final repo = context.read<IncomesRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final amountRaw = _amountController.text.trim().replaceAll(',', '.');
      final defaultAmount = amountRaw.isEmpty
          ? null
          : double.tryParse(amountRaw);

      await repo.saveIncome(
        existingId: widget.incomeId,
        name: _nameController.text.trim(),
        kind: _kind,
        defaultAmount: defaultAmount,
        dayOfMonth: int.tryParse(_dayController.text.trim()),
        active: _active,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        startPeriod: _startPeriod,
        endPeriod: _endPeriod,
      );

      if (!mounted) return;
      router.pop(true);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Eliminar ingreso',
      message: 'Esta acción no se puede deshacer.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<IncomesRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.softDeleteOrDelete(widget.incomeId!);
      if (!mounted) return;
      router.pop(true);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $error')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FzAppBar(
              title: widget.isEditing ? 'Editar ingreso' : 'Nuevo ingreso',
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                  ? _ErrorView(message: _loadError!, onRetry: _load)
                  : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return AbsorbPointer(
      absorbing: _saving,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            FormFieldWrap(
              label: 'Nombre',
              required: true,
              child: FormTextField(
                controller: _nameController,
                hint: 'Ej. Sueldo, Cliente X, Alquiler depto',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresá un nombre'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Tipo',
              required: true,
              child: _KindSelector(
                value: _kind,
                onChanged: (v) => setState(() => _kind = v),
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Monto estimado',
              hint: 'Vacío = monto variable',
              child: FormTextField(
                controller: _amountController,
                hint: '0',
                prefix: '\$ ',
                mono: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final raw = (v ?? '').trim().replaceAll(',', '.');
                  if (raw.isEmpty) return null;
                  final n = double.tryParse(raw);
                  if (n == null || n <= 0) return 'Inválido';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Día del mes',
              hint: '1 a 31 — opcional',
              child: FormTextField(
                controller: _dayController,
                hint: '—',
                mono: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final raw = (v ?? '').trim();
                  if (raw.isEmpty) return null;
                  final n = int.tryParse(raw);
                  if (n == null || n < 1 || n > 31) return '1 a 31';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Desde',
              hint: 'Primer mes en que aplica este ingreso.',
              required: true,
              child: MonthYearPicker(
                value: PeriodKey.fromIso(_startPeriod),
                onChanged: (p) {
                  if (p == null) return;
                  setState(() {
                    _startPeriod = p.toIso();
                    if (_isOneShot) {
                      _endPeriod = _startPeriod;
                    } else if (_endPeriod != null &&
                        PeriodKey.fromIso(_endPeriod!).compareTo(p) < 0) {
                      _endPeriod = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Solo este mes',
              hint: _isOneShot
                  ? 'Aparece únicamente en el mes "Desde".'
                  : 'Activá si es un ingreso puntual (ej: aguinaldo, venta, bonus).',
              child: FormFieldShell(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () => setState(() {
                  if (_isOneShot) {
                    _endPeriod = null;
                  } else {
                    _endPeriod = _startPeriod;
                  }
                }),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ingreso puntual',
                        style: TextStyle(
                          fontFamily: FzType.sans,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FzColors.text,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isOneShot,
                      onChanged: (v) => setState(() {
                        _endPeriod = v ? _startPeriod : null;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            if (!_isOneShot) ...[
              const SizedBox(height: 14),
              FormFieldWrap(
                label: 'Hasta',
                hint:
                    'Opcional. Si lo dejás vacío, el ingreso sigue activo indefinidamente.',
                child: MonthYearPicker(
                  value: _endPeriod == null
                      ? null
                      : PeriodKey.fromIso(_endPeriod!),
                  minPeriod: PeriodKey.fromIso(_startPeriod),
                  placeholder: 'Sin fin',
                  allowClear: true,
                  onChanged: (p) =>
                      setState(() => _endPeriod = p?.toIso()),
                ),
              ),
            ],
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Notas',
              child: FormTextField(
                controller: _notesController,
                hint: 'Opcional',
                maxLines: 4,
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 14),
              FormActiveToggle(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                subtitleOn: 'El ingreso aparece en Mes',
                subtitleOff: 'El ingreso queda oculto',
              ),
            ],
            const SizedBox(height: 20),
            FormSaveButton(
              label: widget.isEditing ? 'Guardar' : 'Crear ingreso',
              loading: _saving,
              onPressed: _submit,
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 10),
              FormDeleteButton(
                label: 'Eliminar ingreso',
                onPressed: _saving ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});
  final IncomeKind value;
  final ValueChanged<IncomeKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormFieldShell(
      onTap: () async {
        final picked = await showModalBottomSheet<IncomeKind>(
          context: context,
          backgroundColor: FzColors.card,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _KindSheet(selected: value),
        );
        if (picked != null) onChanged(picked);
      },
      child: Row(
        children: [
          Text(
            kIncomeKindEmoji[value] ?? '💰',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              kIncomeKindLabels[value] ?? '—',
              style: const TextStyle(
                fontFamily: FzType.sans,
                fontSize: 14,
                color: FzColors.text,
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

class _KindSheet extends StatelessWidget {
  const _KindSheet({required this.selected});
  final IncomeKind selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: FzColors.borderHi,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            for (final k in IncomeKind.values)
              ListTile(
                leading: Text(
                  kIncomeKindEmoji[k] ?? '💰',
                  style: const TextStyle(fontSize: 18),
                ),
                title: Text(
                  kIncomeKindLabels[k] ?? '—',
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight:
                        k == selected ? FontWeight.w600 : FontWeight.w400,
                    color: FzColors.text,
                  ),
                ),
                trailing: k == selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: FzColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(k),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: FzColors.lateColor),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 13,
              color: FzColors.text,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
