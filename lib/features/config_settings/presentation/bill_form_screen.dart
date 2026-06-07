import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics_service.dart';
import '../../../core/format.dart';
import '../../../core/realtime_service.dart';
import '../../../core/url.dart';
import '../../../data/bills_repository.dart';
import '../../../data/cards_repository.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../domain/period.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/bill_kind_icon.dart';
import '../../../widgets/card_brand_logo.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/form_widgets.dart';
import '../../../widgets/month_year_picker.dart';

/// Modo del formulario de gasto.
///
/// Frecuencia del gasto, elegida con un campo dentro del formulario:
///
/// - [recurring]: gasto mes a mes (un servicio o cuenta fija, ej: Netflix).
///   Es el default — el caso más común.
/// - [oneShot]: gasto puntual (una compra única, ej: un sillón al contado).
///   Por detrás es un `Bill` con `endPeriod == startPeriod`.
enum BillFormMode { oneShot, recurring }

/// Pantallas 10/11 — Nuevo/Editar gasto.
///
/// Form único y adaptativo: arranca en modo recurrente y un campo
/// "¿Cada cuánto?" cambia entre mes a mes y puntual, mostrando/ocultando
/// los campos que correspondan. Al editar, el modo se deriva del bill
/// cargado (puntual si `endPeriod == startPeriod`).
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

  BillFormMode _mode = BillFormMode.recurring;
  BillKind _kind = BillKind.other;
  String? _autoDebitCardId;
  bool _active = true;
  String _startPeriod = PeriodKey.current().toIso();
  String? _endPeriod;
  bool _advancedExpanded = false;

  List<CreditCard> _activeCards = const [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool get _isOneShot => _mode == BillFormMode.oneShot;

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
          _loadError = 'No se encontró el gasto.';
          _loading = false;
        });
        return;
      }

      _activeCards = cards;
      if (bill != null) {
        _nameController.text = bill.name;
        _amountController.text = bill.defaultAmount == null
            ? ''
            : formatAmountInput(bill.defaultAmount!);
        _dayController.text = bill.dayOfMonth?.toString() ?? '';
        _providerCodeController.text = bill.providerCode ?? '';
        _urlController.text = bill.url ?? '';
        _notesController.text = bill.notes ?? '';
        _kind = bill.kind;
        _active = bill.active;
        _startPeriod = bill.startPeriod;
        _endPeriod = bill.endPeriod;
        // Derivar el modo del bill: puntual si vive un solo mes.
        _mode = (bill.endPeriod != null && bill.endPeriod == bill.startPeriod)
            ? BillFormMode.oneShot
            : BillFormMode.recurring;
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
    final analytics = context.read<AnalyticsService>();
    final realtime = context.read<RealtimeService>();
    final isNew = widget.billId == null;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      String? normalizedUrl;
      final rawUrl = _urlController.text.trim();
      if (rawUrl.isNotEmpty) {
        normalizedUrl = normalizeUrl(rawUrl).url;
      }

      // El campo agrupa miles con punto ("1.629.560"); los quitamos para
      // parsear el monto entero.
      final amountRaw = _amountController.text.replaceAll('.', '').trim();
      final defaultAmount = amountRaw.isEmpty
          ? null
          : double.tryParse(amountRaw);

      // En puntual el gasto vive un único mes: end == start.
      final endPeriod = _isOneShot ? _startPeriod : _endPeriod;

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
        startPeriod: _startPeriod,
        endPeriod: endPeriod,
      );

      if (isNew) {
        unawaited(analytics.billCreated(kind: _kind.name));
      }

      // Avisar a los blocs que escuchan realtime (Mes, lista) para que
      // refresquen sí o sí, sin depender de Supabase Realtime.
      realtime.notifyLocalChange(RealtimeTable.bills);

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
      title: 'Eliminar gasto',
      message: 'Esta acción no se puede deshacer.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<BillsRepository>();
    final realtime = context.read<RealtimeService>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.softDeleteOrDelete(widget.billId!);
      realtime.notifyLocalChange(RealtimeTable.bills);
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

  /// Estándar de la pantalla: cualquier interacción que no sea con un
  /// campo de texto cierra el teclado.
  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  String get _title => widget.isEditing ? 'Editar gasto' : 'Nuevo gasto';

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
          subtitleOn: 'La cuenta aparece en Mes',
          subtitleOff: 'La cuenta queda oculta',
        ),
      ],
      const SizedBox(height: 22),
      _saveButton(),
      if (widget.isEditing) ...[
        const SizedBox(height: 10),
        FormDeleteButton(
          label: 'Eliminar gasto',
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
            _mode = i == 1 ? BillFormMode.oneShot : BillFormMode.recurring;
            if (_isOneShot) {
              // Puntual: vive un solo mes (end == start) y no usa avanzadas.
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
      hint: 'Mes en el que registrás esta compra.',
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
      hint: 'Opcional. Día en que vence (1 a 31).',
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
        label: 'Desde',
        hint: 'Primer mes en que aplica esta cuenta.',
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
            'Opcional. Si lo dejás vacío, la cuenta sigue activa indefinidamente.',
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
    ];
  }

  // ─────────────────────────── Campos comunes ────────────────────────

  Widget _nameField() {
    return FormFieldWrap(
      label: 'Nombre',
      required: true,
      child: FormTextField(
        controller: _nameController,
        hint: 'Ej. Netflix, EPEC, Sillón',
        textInputAction: TextInputAction.next,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Ingresá un nombre' : null,
      ),
    );
  }

  Widget _amountField() {
    // En puntual el monto es obligatorio (ya pagaste, sabés cuánto); en
    // recurrente es opcional (vacío = variable, ej: la luz).
    final required = _isOneShot;
    return FormFieldWrap(
      label: _isOneShot ? 'Monto' : 'Monto estimado',
      required: required,
      hint: _isOneShot
          ? '¿Cuánto pagaste?'
          : 'Dejalo vacío si el monto varía (ej: la luz).',
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
      label: widget.isEditing ? 'Guardar cambios' : 'Guardar gasto',
      loading: _saving,
      onPressed: _submit,
    );
  }
}

/// Selector de categoría (BillKind) como chips inline — 1 tap, sin
/// bottom sheet. Más amigable que el dropdown anterior.
class _KindChips extends StatelessWidget {
  const _KindChips({required this.value, required this.onChanged});
  final BillKind value;
  final ValueChanged<BillKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final k in BillKind.values)
          FormChoiceChip(
            icon: BillKindIcon.iconFor(k),
            label: kBillKindLabels[k] ?? '—',
            selected: k == value,
            onTap: () => onChanged(k),
          ),
      ],
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
        FocusManager.instance.primaryFocus?.unfocus();
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
    return SizedBox(
      width: 28,
      child: Center(child: CardBrandLogo(brand: brand, size: 20)),
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
