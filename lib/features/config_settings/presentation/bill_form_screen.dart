import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/url.dart';
import '../../../data/bills_repository.dart';
import '../../../data/cards_repository.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/bill_kind_icon.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/form_widgets.dart';

/// Pantallas 10/11 — Nueva/Editar cuenta fija.
/// Port del JSX `ANewFixedAccount` + `AEditFixedAccount`
/// (handoff/screens-a-config.jsx).
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
        _amountController.text = bill.defaultAmount?.toStringAsFixed(0) ?? '';
        _dayController.text = bill.dayOfMonth?.toString() ?? '';
        _providerCodeController.text = bill.providerCode ?? '';
        _urlController.text = bill.url ?? '';
        _notesController.text = bill.notes ?? '';
        _kind = bill.kind;
        _active = bill.active;
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
        normalizedUrl = normalizeUrl(rawUrl).url;
      }

      final amountRaw = _amountController.text.trim().replaceAll(',', '.');
      final defaultAmount = amountRaw.isEmpty
          ? null
          : double.tryParse(amountRaw);

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
      backgroundColor: FzColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FzAppBar(
              title: widget.isEditing ? 'Editar cuenta' : 'Nueva cuenta fija',
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
                hint: 'Ej. EPEC, Netflix, OSDE',
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
              hint: '1 a 31',
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
              label: 'Débito automático en',
              hint:
                  'Si está seleccionada, esta cuenta no aparece como ítem en Mes (ya viene en el resumen de la tarjeta).',
              child: _AutoDebitSelector(
                cards: _activeCards,
                selectedCardId: _autoDebitCardId,
                onChanged: (id) => setState(() => _autoDebitCardId = id),
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Código de referencia',
              hint: 'Se copia al clipboard al tocar "Ir a pagar" en el Mes.',
              child: FormTextField(
                controller: _providerCodeController,
                hint: '0292849306',
                mono: true,
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Link para pagar',
              child: FormTextField(
                controller: _urlController,
                hint: 'https://… o app://…',
                mono: true,
                keyboardType: TextInputType.url,
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
            if (widget.isEditing) ...[
              const SizedBox(height: 14),
              FormActiveToggle(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                subtitleOn: 'La cuenta aparece en Mes',
                subtitleOff: 'La cuenta queda oculta',
              ),
            ],
            const SizedBox(height: 20),
            FormSaveButton(
              label: widget.isEditing ? 'Guardar' : 'Crear cuenta',
              loading: _saving,
              onPressed: _submit,
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 10),
              FormDeleteButton(
                label: 'Eliminar cuenta',
                onPressed: _saving ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Selector del tipo (BillKind) — abre un bottom sheet con todas las
/// opciones cada una con su BillKindIcon.
class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});
  final BillKind value;
  final ValueChanged<BillKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormFieldShell(
      onTap: () async {
        final picked = await showModalBottomSheet<BillKind>(
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
          Icon(BillKindIcon.iconFor(value), size: 16, color: FzColors.text),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              kBillKindLabels[value] ?? '—',
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
  final BillKind selected;

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
            for (final k in BillKind.values)
              ListTile(
                leading: Icon(
                  BillKindIcon.iconFor(k),
                  size: 20,
                  color: FzColors.text,
                ),
                title: Text(
                  kBillKindLabels[k] ?? '—',
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight: k == selected
                        ? FontWeight.w600
                        : FontWeight.w400,
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

/// Selector de tarjeta para débito automático. Permite "Ninguna" (null).
class _AutoDebitSelector extends StatelessWidget {
  const _AutoDebitSelector({
    required this.cards,
    required this.selectedCardId,
    required this.onChanged,
  });

  final List<CreditCard> cards;
  final String? selectedCardId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedCard = selectedCardId == null
        ? null
        : cards.cast<CreditCard?>().firstWhere(
            (c) => c?.id == selectedCardId,
            orElse: () => null,
          );
    return FormFieldShell(
      onTap: () async {
        final picked = await showModalBottomSheet<_AutoDebitPick?>(
          context: context,
          backgroundColor: FzColors.card,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) =>
              _AutoDebitSheet(cards: cards, selectedCardId: selectedCardId),
        );
        if (picked != null) onChanged(picked.cardId);
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedCard?.name ?? 'Ninguna',
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 14,
                color: selectedCard == null ? FzColors.textMute : FzColors.text,
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

/// Sentinel para distinguir "elegí null" de "cancelé el sheet".
class _AutoDebitPick {
  const _AutoDebitPick(this.cardId);
  final String? cardId;
}

class _AutoDebitSheet extends StatelessWidget {
  const _AutoDebitSheet({required this.cards, required this.selectedCardId});

  final List<CreditCard> cards;
  final String? selectedCardId;

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
            ListTile(
              title: Text(
                'Ninguna',
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 14,
                  fontWeight: selectedCardId == null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: FzColors.text,
                ),
              ),
              trailing: selectedCardId == null
                  ? const Icon(
                      Icons.check_rounded,
                      color: FzColors.primary,
                      size: 20,
                    )
                  : null,
              onTap: () =>
                  Navigator.of(context).pop(const _AutoDebitPick(null)),
            ),
            for (final c in cards)
              ListTile(
                leading: _CardSwatch(brand: c.brand),
                title: Text(
                  c.name,
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight: c.id == selectedCardId
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: FzColors.text,
                  ),
                ),
                trailing: c.id == selectedCardId
                    ? const Icon(
                        Icons.check_rounded,
                        color: FzColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(_AutoDebitPick(c.id)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CardSwatch extends StatelessWidget {
  const _CardSwatch({required this.brand});
  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    final color = switch (brand) {
      CardBrand.visa => FzColors.visaBg,
      CardBrand.mastercard => FzColors.mastercardBg,
      CardBrand.amex => FzColors.mpBg,
      CardBrand.other => FzColors.cardHi,
      null => FzColors.cardHi,
    };
    return Container(
      width: 22,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: brand == null ? Border.all(color: FzColors.border) : null,
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
