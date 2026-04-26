import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/url.dart';
import '../../../data/cards_repository.dart';
import '../../../models/enums.dart';
import '../../../widgets/confirm_delete_dialog.dart';

class CardFormScreen extends StatefulWidget {
  const CardFormScreen({this.cardId, super.key});

  /// Si es null, el form crea una tarjeta nueva. Si tiene id, edita la
  /// existente (carga al iniciar).
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

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _load();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    _urlController.dispose();
    super.dispose();
  }

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
        final result = normalizeUrl(rawUrl);
        normalizedUrl = result.url;
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
      // Volver al listado, no al detalle (que ya no existe).
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
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar tarjeta' : 'Nueva tarjeta'),
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
            TextFormField(
              controller: _issuerController,
              decoration: const InputDecoration(labelText: 'Banco / emisor'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CardBrand?>(
              initialValue: _brand,
              decoration: const InputDecoration(labelText: 'Marca'),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...CardBrand.values.map(
                  (b) => DropdownMenuItem(
                    value: b,
                    child: Text(kCardBrandLabels[b]!),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _brand = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _closingDayController,
                    decoration: const InputDecoration(labelText: 'Día cierre'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateDay,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _dueDayController,
                    decoration: const InputDecoration(labelText: 'Día venc.'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateDay,
                  ),
                ),
              ],
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
            if (widget.isEditing) ...[
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: const Text('Activa'),
                subtitle: Text(
                  _active
                      ? 'La tarjeta aparece en el Mes y Tarjetas'
                      : 'La tarjeta queda oculta',
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
              label: Text(widget.isEditing ? 'Guardar' : 'Crear tarjeta'),
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
                label: const Text('Eliminar tarjeta'),
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
