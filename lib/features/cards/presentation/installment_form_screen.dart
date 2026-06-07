import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics_service.dart';
import '../../../core/format.dart';
import '../../../core/realtime_service.dart';
import '../../../data/cards_repository.dart';
import '../../../data/installments_repository.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../domain/period.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/form_widgets.dart';
import '../../../widgets/month_year_picker.dart';
import '../../../widgets/fz_snackbar.dart';

/// Pantalla 6 — Nueva/Editar compra en cuotas.
/// Port del JSX `ANewPurchase` (handoff/screens-a-cards.jsx).
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
  CreditCard? _card;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_recompute);
    _countController.addListener(_recompute);
    _load();
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

  /// Cualquier interacción que no sea con un campo de texto cierra el teclado.
  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  double? get _liveTotal {
    // El campo agrupa miles con punto; los quitamos para parsear.
    final amount = double.tryParse(
      _amountController.text.replaceAll('.', '').trim(),
    );
    final count = int.tryParse(_countController.text.trim());
    if (amount == null || count == null || count <= 0 || amount <= 0) {
      return null;
    }
    return amount * count;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final cardsRepo = context.read<CardsRepository>();
      final installmentsRepo = context.read<InstallmentsRepository>();

      final cardFuture = cardsRepo.fetchById(widget.cardId);
      final purchaseFuture = widget.isEditing
          ? installmentsRepo.fetchById(widget.installmentId!)
          : Future.value(null);

      final card = await cardFuture;
      final purchase = await purchaseFuture;

      if (widget.isEditing && purchase == null) {
        setState(() {
          _loadError = 'No se encontró la compra.';
          _loading = false;
        });
        return;
      }

      _card = card;

      if (purchase != null) {
        _descriptionController.text = purchase.description;
        _amountController.text = formatAmountInput(purchase.installmentAmount);
        _countController.text = purchase.installmentCount.toString();
        _notesController.text = purchase.notes ?? '';
        _firstPeriod = PeriodKey.fromIso(purchase.firstPeriod);
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

    final repo = context.read<InstallmentsRepository>();
    final analytics = context.read<AnalyticsService>();
    final realtime = context.read<RealtimeService>();
    final isNew = widget.installmentId == null;
    final installmentCount = int.parse(_countController.text.trim());
    final router = GoRouter.of(context);

    try {
      await repo.savePurchase(
        existingId: widget.installmentId,
        creditCardId: widget.cardId,
        description: _descriptionController.text.trim(),
        installmentCount: installmentCount,
        installmentAmount: double.parse(
          _amountController.text.replaceAll('.', '').trim(),
        ),
        firstPeriod: _firstPeriod,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (isNew) {
        unawaited(
          analytics.installmentCreated(totalInstallments: installmentCount),
        );
      }

      // Refresh determinista (Mes y detalle de tarjeta muestran las cuotas),
      // sin depender de que Supabase Realtime esté habilitado.
      realtime.notifyLocalChange(RealtimeTable.installmentPurchases);

      if (!mounted) return;
      router.pop(true);
    } catch (error) {
      if (!mounted) return;
      showFzSnack(
        context,
        'No se pudo guardar: $error',
        kind: FzSnackKind.error,
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
    final realtime = context.read<RealtimeService>();
    final router = GoRouter.of(context);

    try {
      await repo.deletePurchase(widget.installmentId!);
      realtime.notifyLocalChange(RealtimeTable.installmentPurchases);
      if (!mounted) return;
      router.pop(true);
    } catch (error) {
      if (!mounted) return;
      showFzSnack(
        context,
        'No se pudo eliminar: $error',
        kind: FzSnackKind.error,
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
              title: widget.isEditing ? 'Editar compra' : 'Nueva compra',
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
      child: GestureDetector(
        // Tap en cualquier zona vacía → cierra el teclado.
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              if (_card != null) ...[
                _ContextCard(card: _card!),
                const SizedBox(height: 14),
              ],
              FormFieldWrap(
                label: 'Descripción',
                required: true,
                child: FormTextField(
                  controller: _descriptionController,
                  hint: 'Ej. Heladera Whirlpool',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresá una descripción'
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormFieldWrap(
                      label: 'Monto por cuota',
                      required: true,
                      child: FormTextField(
                        controller: _amountController,
                        hint: '0',
                        prefix: '\$ ',
                        mono: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandsInputFormatter()],
                        validator: (v) {
                          final raw = (v ?? '').replaceAll('.', '').trim();
                          final n = int.tryParse(raw);
                          if (n == null || n <= 0) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 96,
                    child: FormFieldWrap(
                      label: 'Cuotas',
                      required: true,
                      child: FormTextField(
                        controller: _countController,
                        hint: '12',
                        suffix: 'x',
                        mono: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n <= 0) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _TotalCalculated(amount: _liveTotal),
              const SizedBox(height: 14),
              FormFieldWrap(
                label: 'Mes de la primera cuota',
                required: true,
                child: MonthYearPicker(
                  value: _firstPeriod,
                  onChanged: (p) {
                    if (p == null) return;
                    setState(() => _firstPeriod = p);
                  },
                ),
              ),
              const SizedBox(height: 14),
              FormFieldWrap(
                label: 'Notas',
                child: FormTextField(
                  controller: _notesController,
                  hint: 'Opcional. Ej. "compra en black friday"',
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 20),
              FormSaveButton(
                label: widget.isEditing ? 'Guardar cambios' : 'Crear compra',
                loading: _saving,
                onPressed: _submit,
              ),
              if (widget.isEditing) ...[
                const SizedBox(height: 10),
                FormDeleteButton(
                  label: 'Eliminar compra',
                  onPressed: _saving ? null : _delete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de contexto: muestra "en `CardName`" con un chip de marca.
class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.card});
  final CreditCard card;

  @override
  Widget build(BuildContext context) {
    final brand = card.brand;
    final brandColor = brand == null
        ? FzColors.cardHi
        : switch (brand) {
            CardBrand.visa => FzColors.visaBg,
            CardBrand.mastercard => FzColors.mastercardBg,
            CardBrand.amex => FzColors.mpBg,
            CardBrand.other => FzColors.cardHi,
          };
    final brandLabel = brand == null
        ? '?'
        : switch (brand) {
            CardBrand.visa => 'V',
            CardBrand.mastercard => 'M',
            CardBrand.amex => 'A',
            CardBrand.other => '·',
          };
    return FormFieldShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              brandLabel,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: FzType.sans,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 12.5,
                  color: FzColors.textDim,
                ),
                children: [
                  const TextSpan(text: 'en '),
                  TextSpan(
                    text: card.name,
                    style: const TextStyle(
                      color: FzColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card destacada que muestra el total calculado (monto cuota * cantidad).
class _TotalCalculated extends StatelessWidget {
  const _TotalCalculated({required this.amount});
  final double? amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FzColors.primarySoft,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        border: Border.all(color: FzColors.borderPaid),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL DE LA COMPRA',
                  style: TextStyle(
                    fontFamily: FzType.mono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.63,
                    color: FzColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'se calcula automáticamente',
                  style: TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 11,
                    color: FzColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount == null ? '—' : formatCurrency(amount),
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              fontFeatures: FzType.tabularNums,
              color: amount == null ? FzColors.textDim : FzColors.primaryHi,
            ),
          ),
        ],
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
