import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/notification_service.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../widgets/fz_snackbar.dart';

/// Pantalla de notificaciones (Ajustes → Notificaciones).
///
/// Muestra el estado del permiso y cuántos recordatorios hay programados, y
/// permite (re)activar el permiso si el usuario lo tenía denegado — la causa
/// más común de que "no lleguen" las notificaciones.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool? _granted;
  int? _pending;
  bool _loading = true;

  NotificationService get _service => context.read<NotificationService>();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final granted = await _service.permissionStatus();
    final pending = await _service.pendingCount();
    if (!mounted) return;
    setState(() {
      _granted = granted;
      _pending = pending;
      _loading = false;
    });
  }

  Future<void> _requestPermission() async {
    await _service.requestPermissions();
    await _refresh();
    if (!mounted) return;
    if (_granted != true) {
      showFzSnack(
        context,
        'Si el permiso quedó denegado, activalo desde los ajustes del sistema.',
        kind: FzSnackKind.error,
      );
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
            const FzAppBar(title: 'Notificaciones'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  fzBottomNavClearance(context),
                ),
                children: [
                  _StatusCard(
                    loading: _loading,
                    granted: _granted,
                    pending: _pending,
                    onRefresh: _refresh,
                  ),
                  const SizedBox(height: 12),
                  if (_granted == false) ...[
                    FzPrimaryButton(
                      label: 'Activar notificaciones',
                      icon: Icons.notifications_active_outlined,
                      onPressed: _requestPermission,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const _InfoText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.loading,
    required this.granted,
    required this.pending,
    required this.onRefresh,
  });

  final bool loading;
  final bool? granted;
  final int? pending;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (granted) {
      true => (FzColors.primary, 'Permiso concedido'),
      false => (FzColors.lateColor, 'Permiso denegado'),
      null => (FzColors.textMute, 'Estado desconocido'),
    };

    return FzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loading ? 'Verificando…' : label,
                  style: FzText.bodyM,
                ),
              ),
              IconButton(
                onPressed: loading ? null : onRefresh,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: FzColors.textDim,
                ),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            loading ? '' : 'Recordatorios programados: ${pending ?? '—'}',
            style: FzText.caption,
          ),
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Los recordatorios se programan automáticamente 1 día antes de cada '
        'vencimiento, a las 9:00. Si un pago ya está marcado como pagado, no '
        'se recuerda. Si no te llegan, revisá que el permiso esté concedido '
        '(y que no estés en "No molestar").',
        style: FzText.caption,
      ),
    );
  }
}
