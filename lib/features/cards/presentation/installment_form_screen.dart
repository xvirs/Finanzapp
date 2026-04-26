import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format.dart';
import '../../../data/installments_repository.dart';
import '../../../domain/period.dart';
import '../../../widgets/confirm_delete_dialog.dart';

class InstallmentFormScreen extends StatefulWidget {
  const InstallmentFormScreen({
    required this.cardId,
    this.installmentId,
    super.key,
  });

  final String cardId;
  final String? installmentId;

  bool get isEditing => installmentId != null;

  @override
  State<InstallmentFormScreen> createState() => _InstallmentFormScreenState();
}

class _InstallmentFormScreenState extends State<InstallmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _countController = TextEditingController();
  final _notesController = TextEditingController();

  PeriodKey _firstPeriod = PeriodKey.current();
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_recompute);
    _countController.addListener(_recompute);
    if (widget.isEditing) {
      _load();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _countController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recompute() => setState(() {});

  double? get _liveTotal {
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    final count = int.tryParse(_countController.text.trim());
    if (amount == null || count == null || count <= 0 || amount <= 0) {
      return null;
    }
    return amount * count;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<InstallmentsRepository>();
      final purchase = await repo.fetchById(widget.installmentId!);
      if (purchase == null) {
        setState(() {
          _loadError = 'No se encontró la compra.';
          _loading = false;
        });
        return;
      }
      _descriptionController.text = purchase.description;
      _amountController.text =
          purchase.installmentAmount.toStringAsFixed(0);
      _countController.text = purchase.installmentCount.toString();
      _notesController.text = purchase.notes ?? '';
      _firstPeriod = PeriodKey.fromIso(purchase.firstPeriod);
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickPeriod() async {
    final theme = Theme.of(context);
    final selected = await showDialog<PeriodKey>(
      context: context,
      builder: (ctx) => _MonthYearPicker(initial: _firstPeriod, theme: theme),
    );
    if (selected != null) {
      setState(() => _firstPeriod = selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final repo = context.read<InstallmentsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.savePurchase(
        existingId: widget.installmentId,
        creditCardId: widget.cardId,
        description: _descriptionController.text.trim(),
        installmentCount: int.parse(_countController.text.trim()),
        installmentAmount: double.parse(
          _amountController.text.trim().replaceAll(',', '.'),
        ),
        firstPeriod: _firstPeriod,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
      title: 'Eliminar compra',
      message: 'Esta acción no se puede deshacer.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<InstallmentsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.deletePurchase(widget.installmentId!);
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
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar compra' : 'Nueva compra'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _ErrorView(message: _loadError!, onRetry: _load)
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final total = _liveTotal;

    return AbsorbPointer(
      absorbing: _saving,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción *'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresá una descripción'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto por cuota *',
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final raw = (v ?? '').trim().replaceAll(',', '.');
                      final n = double.tryParse(raw);
                      if (n == null || n <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _countController,
                    decoration: const InputDecoration(labelText: 'Cuotas *'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return 'Cuotas inválidas';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Total de la compra',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      total == null ? '—' : formatCurrency(total),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickPeriod,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Mes de la primera cuota *',
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                ),
                child: Text(_firstPeriod.formatLong()),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(widget.isEditing ? 'Guardar' : 'Crear compra'),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Eliminar compra'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthYearPicker extends StatefulWidget {
  const _MonthYearPicker({required this.initial, required this.theme});

  final PeriodKey initial;
  final ThemeData theme;

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int _year;
  late int _monthOneIndexed;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _monthOneIndexed = widget.initial.month + 1;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(11, (i) => now.year - 5 + i);
    final months = List.generate(12, (i) => i + 1);

    return AlertDialog(
      title: const Text('Mes de la primera cuota'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _monthOneIndexed,
              decoration: const InputDecoration(labelText: 'Mes'),
              items: months
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          DateFormat.MMMM('es_AR')
                              .format(DateTime(2000, m, 1)),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _monthOneIndexed = v!),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: DropdownButtonFormField<int>(
              initialValue: _year,
              decoration: const InputDecoration(labelText: 'Año'),
              items: years
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (v) => setState(() => _year = v!),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            PeriodKey(year: _year, month: _monthOneIndexed - 1),
          ),
          child: const Text('OK'),
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
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
