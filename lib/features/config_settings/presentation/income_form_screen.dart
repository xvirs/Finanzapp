import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/realtime_service.dart';
import '../../../data/incomes_repository.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../domain/period.dart';
import '../../../models/enums.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/form_widgets.dart';
import '../../../widgets/month_year_picker.dart';

/// Frecuencia del ingreso, elegida con un campo dentro del formulario:
///
/// - [recurring]: ingreso mes a mes (ej: sueldo, un alquiler que cobro).
///   Es el default — el caso más común.
/// - [oneShot]: ingreso puntual (una vez, ej: aguinaldo, venta, bonus).
///   Por detrás es un `Income` con `endPeriod == startPeriod`.
enum IncomeFormMode { oneShot, recurring }

/// Crear/editar un ingreso. Espejo simétrico de `BillFormScreen`.
///
/// Form único y adaptativo: arranca en modo recurrente y un campo
/// "¿Cada cuánto?" cambia entre mes a mes y puntual. Al editar, el modo se
/// deriva del income cargado (puntual si `endPeriod == startPeriod`).
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

  IncomeFormMode _mode = IncomeFormMode.recurring;
  IncomeKind _kind = IncomeKind.salary;
  bool _active = true;
  String _startPeriod = PeriodKey.current().toIso();
  String? _endPeriod;
  bool _advancedExpanded = false;

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool get _isOneShot => _mode == IncomeFormMode.oneShot;

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
      _amountController.text = income.defaultAmount == null
          ? ''
          : formatAmountInput(income.defaultAmount!);
      _dayController.text = income.dayOfMonth?.toString() ?? '';
      _notesController.text = income.notes ?? '';
      _kind = income.kind;
      _active = income.active;
      _startPeriod = income.startPeriod;
      _endPeriod = income.endPeriod;
      _mode =
          (income.endPeriod != null && income.endPeriod == income.startPeriod)
          ? IncomeFormMode.oneShot
          : IncomeFormMode.recurring;
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
    final realtime = context.read<RealtimeService>();
    final isNew = widget.incomeId == null;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      // El campo agrupa miles con punto ("1.629.560"); los quitamos para
      // parsear el monto entero.
      final amountRaw = _amountController.text.replaceAll('.', '').trim();
      final defaultAmount = amountRaw.isEmpty
          ? null
          : double.tryParse(amountRaw);

      // En puntual el ingreso vive un único mes: end == start.
      final endPeriod = _isOneShot ? _startPeriod : _endPeriod;

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
        endPeriod: endPeriod,
      );

      // Avisar a los blocs que escuchan realtime (Mes, lista) para que
      // refresquen sí o sí, sin depender de Supabase Realtime.
      realtime.notifyLocalChange(RealtimeTable.incomes);

      if (!mounted) return;
      // Al crear, volvemos al home (Mes) limpiando el flujo de alta. Al
      // editar, volvemos a la lista de donde vino.
      if (isNew) {
        router.go('/');
      } else {
        router.pop(true);
      }
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
    final realtime = context.read<RealtimeService>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.softDeleteOrDelete(widget.incomeId!);
      realtime.notifyLocalChange(RealtimeTable.incomes);
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

  /// Cualquier interacción que no sea con un campo de texto cierra el teclado.
  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  String get _title => widget.isEditing ? 'Editar ingreso' : 'Nuevo ingreso';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FzAppBar(title: _title),
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
      child: GestureDetector(
        // Tap en cualquier zona vacía → cierra el teclado.
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: _fields(),
          ),
        ),
      ),
    );
  }

  /// Form único: lo esencial primero (nombre, monto, categoría), después
  /// la frecuencia, y según ésta los campos que correspondan.
  List<Widget> _fields() {
    return [
      _nameField(),
      const SizedBox(height: 14),
      _amountField(),
      const SizedBox(height: 14),
      _categoryField(),
      const SizedBox(height: 14),
      _frequencyField(),
      const SizedBox(height: 14),
      if (_isOneShot)
        _monthField()
      else ...[
        _dayField(),
        const SizedBox(height: 6),
        FormMoreOptions(
          expanded: _advancedExpanded,
          onToggle: () {
            _dismissKeyboard();
            setState(() => _advancedExpanded = !_advancedExpanded);
          },
          children: _advancedFields(),
        ),
      ],
      if (widget.isEditing) ...[
        const SizedBox(height: 14),
        FormActiveToggle(
          value: _active,
          onChanged: (v) {
            _dismissKeyboard();
            setState(() => _active = v);
          },
          subtitleOn: 'El ingreso aparece en Mes',
          subtitleOff: 'El ingreso queda oculto',
        ),
      ],
      const SizedBox(height: 22),
      _saveButton(),
      if (widget.isEditing) ...[
        const SizedBox(height: 10),
        FormDeleteButton(
          label: 'Eliminar ingreso',
          onPressed: _saving ? null : _delete,
        ),
      ],
    ];
  }

  Widget _frequencyField() {
    return FormFieldWrap(
      label: '¿Cada cuánto?',
      child: FormSegmented(
        options: const ['Todos los meses', 'Una sola vez'],
        selectedIndex: _isOneShot ? 1 : 0,
        onChanged: (i) {
          _dismissKeyboard();
          setState(() {
            _mode = i == 1 ? IncomeFormMode.oneShot : IncomeFormMode.recurring;
            if (_isOneShot) {
              _endPeriod = _startPeriod;
              _advancedExpanded = false;
            } else {
              _endPeriod = null;
            }
          });
        },
      ),
    );
  }

  Widget _monthField() {
    return FormFieldWrap(
      label: 'Mes',
      required: true,
      hint: 'Mes en el que registrás este ingreso.',
      child: MonthYearPicker(
        value: PeriodKey.fromIso(_startPeriod),
        onChanged: (p) {
          if (p == null) return;
          setState(() {
            _startPeriod = p.toIso();
            _endPeriod = _startPeriod;
          });
        },
      ),
    );
  }

  Widget _dayField() {
    return FormFieldWrap(
      label: 'Día del mes',
      hint: 'Opcional. Día en que lo cobrás (1 a 31).',
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
    );
  }

  List<Widget> _advancedFields() {
    return [
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
              if (_endPeriod != null &&
                  PeriodKey.fromIso(_endPeriod!).compareTo(p) < 0) {
                _endPeriod = null;
              }
            });
          },
        ),
      ),
      const SizedBox(height: 14),
      FormFieldWrap(
        label: 'Hasta',
        hint:
            'Opcional. Si lo dejás vacío, el ingreso sigue activo indefinidamente.',
        child: MonthYearPicker(
          value: _endPeriod == null ? null : PeriodKey.fromIso(_endPeriod!),
          minPeriod: PeriodKey.fromIso(_startPeriod),
          placeholder: 'Sin fin',
          allowClear: true,
          onChanged: (p) => setState(() => _endPeriod = p?.toIso()),
        ),
      ),
      const SizedBox(height: 14),
      FormFieldWrap(
        label: 'Notas',
        child: FormTextField(
          controller: _notesController,
          hint: 'Opcional',
          maxLines: 4,
        ),
      ),
    ];
  }

  // ─────────────────────────── Campos comunes ────────────────────────

  Widget _nameField() {
    return FormFieldWrap(
      label: 'Nombre',
      required: true,
      child: FormTextField(
        controller: _nameController,
        hint: 'Ej. Sueldo, Cliente X, Aguinaldo',
        textInputAction: TextInputAction.next,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Ingresá un nombre' : null,
      ),
    );
  }

  Widget _amountField() {
    // En puntual el monto es obligatorio (ya cobraste, sabés cuánto); en
    // recurrente es opcional (vacío = variable).
    final required = _isOneShot;
    return FormFieldWrap(
      label: _isOneShot ? 'Monto' : 'Monto estimado',
      required: required,
      hint: _isOneShot
          ? '¿Cuánto cobraste?'
          : 'Dejalo vacío si el monto varía.',
      child: FormTextField(
        controller: _amountController,
        hint: '0',
        prefix: '\$ ',
        mono: true,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandsInputFormatter()],
        validator: (v) {
          final raw = (v ?? '').replaceAll('.', '').trim();
          if (raw.isEmpty) {
            return required ? 'Ingresá el monto' : null;
          }
          final n = int.tryParse(raw);
          if (n == null || n <= 0) return 'Inválido';
          return null;
        },
      ),
    );
  }

  Widget _categoryField() {
    return FormFieldWrap(
      label: 'Categoría',
      child: _KindChips(
        value: _kind,
        onChanged: (v) {
          _dismissKeyboard();
          setState(() => _kind = v);
        },
      ),
    );
  }

  Widget _saveButton() {
    return FormSaveButton(
      label: widget.isEditing ? 'Guardar cambios' : 'Guardar ingreso',
      loading: _saving,
      onPressed: _submit,
    );
  }
}

/// Icono Material por tipo de ingreso (sin emojis, alineado al resto de
/// la UI del handoff).
IconData iconForIncomeKind(IncomeKind kind) {
  switch (kind) {
    case IncomeKind.salary:
      return Icons.work_outline_rounded;
    case IncomeKind.freelance:
      return Icons.laptop_mac_outlined;
    case IncomeKind.rental:
      return Icons.home_outlined;
    case IncomeKind.other:
      return Icons.payments_outlined;
  }
}

/// Selector de categoría (IncomeKind) como chips inline — 1 tap, sin
/// bottom sheet.
class _KindChips extends StatelessWidget {
  const _KindChips({required this.value, required this.onChanged});
  final IncomeKind value;
  final ValueChanged<IncomeKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final k in IncomeKind.values)
          FormChoiceChip(
            icon: iconForIncomeKind(k),
            label: kIncomeKindLabels[k] ?? '—',
            selected: k == value,
            onTap: () => onChanged(k),
          ),
      ],
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
