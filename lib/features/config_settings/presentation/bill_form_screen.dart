import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/url.dart';
import '../../../data/bills_repository.dart';
import '../../../data/cards_repository.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/confirm_delete_dialog.dart';

class BillFormScreen extends StatefulWidget {
  const BillFormScreen({this.billId, super.key});

  final String? billId;

  bool get isEditing => billId != null;

  @override
  State<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends State<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();
  final _providerCodeController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  BillKind _kind = BillKind.other;
  String? _autoDebitCardId;
  bool _active = true;

  List<CreditCard> _activeCards = const [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

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
    _providerCodeController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final billsRepo = context.read<BillsRepository>();
      final cardsRepo = context.read<CardsRepository>();

      final cardsFuture = cardsRepo.fetchAllActive();
      final billFuture = widget.isEditing
          ? billsRepo.fetchById(widget.billId!)
          : Future.value(null);

      final cards = await cardsFuture;
      final bill = await billFuture;

      if (widget.isEditing && bill == null) {
        setState(() {
          _loadError = 'No se encontró la cuenta fija.';
          _loading = false;
        });
        return;
      }

      _activeCards = cards;

      if (bill != null) {
        _nameController.text = bill.name;
        _amountController.text =
            bill.defaultAmount?.toStringAsFixed(0) ?? '';
        _dayController.text = bill.dayOfMonth?.toString() ?? '';
        _providerCodeController.text = bill.providerCode ?? '';
        _urlController.text = bill.url ?? '';
        _notesController.text = bill.notes ?? '';
        _kind = bill.kind;
        _active = bill.active;
        // Solo asignamos auto_debit_card_id si la tarjeta sigue activa.
        if (bill.autoDebitCardId != null &&
            cards.any((c) => c.id == bill.autoDebitCardId)) {
          _autoDebitCardId = bill.autoDebitCardId;
        }
      }

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

    final repo = context.read<BillsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      String? normalizedUrl;
      final rawUrl = _urlController.text.trim();
      if (rawUrl.isNotEmpty) {
        final result = normalizeUrl(rawUrl);
        normalizedUrl = result.url;
      }

      final amountRaw =
          _amountController.text.trim().replaceAll(',', '.');
      final defaultAmount =
          amountRaw.isEmpty ? null : double.tryParse(amountRaw);

      await repo.saveBill(
        existingId: widget.billId,
        name: _nameController.text.trim(),
        kind: _kind,
        defaultAmount: defaultAmount,
        dayOfMonth: int.tryParse(_dayController.text.trim()),
        providerCode: _providerCodeController.text.trim().isEmpty
            ? null
            : _providerCodeController.text.trim(),
        active: _active,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        autoDebitCardId: _autoDebitCardId,
        url: normalizedUrl,
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
      title: 'Eliminar cuenta fija',
      message: 'Esta acción no se puede deshacer.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<BillsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.deleteBill(widget.billId!);
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
        title: Text(widget.isEditing ? 'Editar cuenta' : 'Nueva cuenta fija'),
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

    return AbsorbPointer(
      absorbing: _saving,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresá un nombre'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BillKind>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Tipo *'),
              items: BillKind.values
                  .map(
                    (k) => DropdownMenuItem(
                      value: k,
                      child: Row(
                        children: [
                          Text(
                            kBillKindEmoji[k] ?? '📌',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(kBillKindLabels[k] ?? '—'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _kind = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto estimado',
                prefixText: '\$ ',
                helperText: 'Vacío = monto variable',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final raw = (v ?? '').trim().replaceAll(',', '.');
                if (raw.isEmpty) return null;
                final n = double.tryParse(raw);
                if (n == null || n <= 0) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dayController,
              decoration: const InputDecoration(
                labelText: 'Día del mes',
                helperText: '1 a 31',
              ),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _autoDebitCardId,
              decoration: const InputDecoration(
                labelText: 'Débito automático en',
                helperText:
                    'Si está seleccionada, esta cuenta no aparece como ítem '
                    'del Mes — se suma al total de la tarjeta.',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Ninguna'),
                ),
                ..._activeCards.map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _autoDebitCardId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _providerCodeController,
              decoration: const InputDecoration(
                labelText: 'Código de referencia',
                helperText:
                    'Se copia al clipboard al tocar "Ir a pagar" en el Mes.',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Link para pagar',
                hintText: 'https://… o app://…',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 3,
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: const Text('Activa'),
                subtitle: Text(
                  _active
                      ? 'La cuenta aparece en el Mes'
                      : 'La cuenta queda oculta',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
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
              label: Text(widget.isEditing ? 'Guardar' : 'Crear cuenta'),
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
                label: const Text('Eliminar cuenta'),
              ),
            ],
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
