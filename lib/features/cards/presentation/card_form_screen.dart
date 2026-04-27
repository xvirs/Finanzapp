import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/url.dart';
import '../../../data/cards_repository.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../models/credit_card.dart';
import '../../../models/enums.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/form_widgets.dart';

/// Pantalla 7 — Editar tarjeta (o crear nueva si cardId == null).
/// Port del JSX `AEditCard` (handoff/screens-a-cards.jsx).
class CardFormScreen extends StatefulWidget {
  const CardFormScreen({this.cardId, super.key});

  final String? cardId;

  bool get isEditing => cardId != null;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _closingDayController = TextEditingController();
  final _dueDayController = TextEditingController();
  final _urlController = TextEditingController();

  CardBrand? _brand;
  bool _active = true;
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  // Para mostrar el preview en vivo
  CreditCard? _editingCard;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    if (widget.isEditing) {
      _load();
    }
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onNameChanged)
      ..dispose();
    _issuerController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<CardsRepository>();
      final card = await repo.fetchById(widget.cardId!);
      if (card == null) {
        setState(() {
          _loadError = 'No se encontró la tarjeta.';
          _loading = false;
        });
        return;
      }
      _editingCard = card;
      _nameController.text = card.name;
      _issuerController.text = card.issuer ?? '';
      _closingDayController.text = card.closingDay?.toString() ?? '';
      _dueDayController.text = card.dueDay?.toString() ?? '';
      _urlController.text = card.url ?? '';
      _brand = card.brand;
      _active = card.active;
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

    final repo = context.read<CardsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      String? normalizedUrl;
      final rawUrl = _urlController.text.trim();
      if (rawUrl.isNotEmpty) {
        normalizedUrl = normalizeUrl(rawUrl).url;
      }

      await repo.saveCard(
        existingId: widget.cardId,
        name: _nameController.text.trim(),
        issuer: _issuerController.text.trim().isEmpty
            ? null
            : _issuerController.text.trim(),
        brand: _brand,
        closingDay: int.tryParse(_closingDayController.text.trim()),
        dueDay: int.tryParse(_dueDayController.text.trim()),
        active: _active,
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
      title: 'Eliminar tarjeta',
      message:
          'Esta acción no se puede deshacer. También se eliminarán las cuotas asociadas.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<CardsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await repo.deleteCard(widget.cardId!);
      if (!mounted) return;
      router.go('/cards');
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
              title: widget.isEditing ? 'Editar tarjeta' : 'Nueva tarjeta',
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
            if (widget.isEditing) ...[
              _PreviewCard(
                name: _nameController.text.isEmpty
                    ? (_editingCard?.name ?? 'Tarjeta')
                    : _nameController.text,
                brand: _brand,
                closingDay:
                    int.tryParse(_closingDayController.text.trim()),
                dueDay: int.tryParse(_dueDayController.text.trim()),
                active: _active,
              ),
              const SizedBox(height: 14),
            ],
            FormFieldWrap(
              label: 'Nombre',
              required: true,
              child: FormTextField(
                controller: _nameController,
                hint: 'Ej. Galicia VISA',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresá un nombre'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Banco / emisor',
              child: FormTextField(
                controller: _issuerController,
                hint: 'Ej. Banco Galicia',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 14),
            FormFieldWrap(
              label: 'Marca',
              child: _BrandSelector(
                value: _brand,
                onChanged: (v) => setState(() => _brand = v),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormFieldWrap(
                    label: 'Día cierre',
                    child: FormTextField(
                      controller: _closingDayController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      mono: true,
                      hint: '10',
                      validator: _validateDay,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FormFieldWrap(
                    label: 'Día vencimiento',
                    child: FormTextField(
                      controller: _dueDayController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      mono: true,
                      hint: '15',
                      validator: _validateDay,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ],
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
            if (widget.isEditing) ...[
              const SizedBox(height: 14),
              FormActiveToggle(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ],
            const SizedBox(height: 20),
            FormSaveButton(
              label: widget.isEditing ? 'Guardar cambios' : 'Crear tarjeta',
              loading: _saving,
              onPressed: _submit,
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 10),
              FormDeleteButton(
                label: 'Eliminar tarjeta',
                onPressed: _saving ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _validateDay(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 31) return '1 a 31';
    return null;
  }
}

/// Preview card (en modo edición) con avatar de marca + nombre +
/// cierre/vence + ACTIVA/INACTIVA badge.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.name,
    required this.brand,
    required this.closingDay,
    required this.dueDay,
    required this.active,
  });

  final String name;
  final CardBrand? brand;
  final int? closingDay;
  final int? dueDay;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final brandColor = brand == null
        ? FzColors.cardHi
        : switch (brand!) {
            CardBrand.visa => FzColors.visaBg,
            CardBrand.mastercard => FzColors.mastercardBg,
            CardBrand.amex => FzColors.mpBg,
            CardBrand.other => FzColors.cardHi,
          };
    final brandLabel = brand == null
        ? '?'
        : switch (brand!) {
            CardBrand.visa => 'V',
            CardBrand.mastercard => 'M',
            CardBrand.amex => 'A',
            CardBrand.other => '·',
          };
    final subtitle = [
      if (closingDay != null) 'cierre $closingDay',
      if (dueDay != null) 'vence $dueDay',
    ].join(' · ');

    return FormFieldShell(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(FzRadius.md),
            ),
            alignment: Alignment.center,
            child: Text(
              brandLabel,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: FzType.sans,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FzColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: FzType.mono,
                      fontSize: 11,
                      color: FzColors.textMute,
                      letterSpacing: 0.44,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: active ? FzColors.primarySoft : FzColors.cardHi,
              borderRadius: BorderRadius.circular(FzRadius.xs),
            ),
            child: Text(
              active ? 'ACTIVA' : 'INACTIVA',
              style: TextStyle(
                fontFamily: FzType.mono,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.54,
                color: active ? FzColors.primary : FzColors.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de marca: input estilo card + texto + chevron, abre un
/// menú con las opciones (cada una con swatch del color de la marca).
class _BrandSelector extends StatelessWidget {
  const _BrandSelector({required this.value, required this.onChanged});

  final CardBrand? value;
  final ValueChanged<CardBrand?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormFieldShell(
      onTap: () async {
        final picked = await showModalBottomSheet<CardBrand?>(
          context: context,
          backgroundColor: FzColors.card,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _BrandSheet(selected: value),
        );
        // El sheet devuelve null si se cancela. Para "limpiar" usamos
        // un sentinel — no lo soportamos por ahora; null = cancel.
        if (picked != null) onChanged(picked);
      },
      child: Row(
        children: [
          _BrandSwatch(brand: value),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _label(value),
              style: TextStyle(
                fontFamily: FzType.sans,
                fontSize: 14,
                color: value == null ? FzColors.textMute : FzColors.text,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: FzColors.textDim,
          ),
        ],
      ),
    );
  }

  static String _label(CardBrand? b) {
    if (b == null) return 'Sin marca';
    return kCardBrandLabels[b] ?? '—';
  }
}

class _BrandSwatch extends StatelessWidget {
  const _BrandSwatch({required this.brand});
  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    final color = brand == null
        ? FzColors.cardHi
        : switch (brand!) {
            CardBrand.visa => FzColors.visaBg,
            CardBrand.mastercard => FzColors.mastercardBg,
            CardBrand.amex => FzColors.mpBg,
            CardBrand.other => FzColors.cardHi,
          };
    return Container(
      width: 22,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: brand == null
            ? Border.all(color: FzColors.border)
            : null,
      ),
    );
  }
}

class _BrandSheet extends StatelessWidget {
  const _BrandSheet({this.selected});
  final CardBrand? selected;

  @override
  Widget build(BuildContext context) {
    final brands = [null, ...CardBrand.values];
    return SafeArea(
      top: false,
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
          for (final b in brands)
            ListTile(
              leading: _BrandSwatch(brand: b),
              title: Text(
                _BrandSelector._label(b),
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 14,
                  fontWeight:
                      b == selected ? FontWeight.w600 : FontWeight.w400,
                  color: FzColors.text,
                ),
              ),
              trailing: b == selected
                  ? const Icon(Icons.check_rounded,
                      color: FzColors.primary, size: 20)
                  : null,
              onTap: () => Navigator.of(context).pop(b),
            ),
          const SizedBox(height: 8),
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
          const Icon(Icons.error_outline,
              size: 48, color: FzColors.lateColor),
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
