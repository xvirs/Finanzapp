import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Tono semántico del snackbar. Dispara color de borde + ícono.
enum FzSnackKind { info, success, error }

/// Muestra un snackbar con la estética de la app (oscuro, bordes finos,
/// tipografía Geist, ícono según el tono).
///
/// Reemplaza al `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))`
/// genérico de Material que se ve fuera de lugar contra el tema dark.
///
/// Ejemplos:
/// ```dart
/// showFzSnack(context, 'Código 0123 copiado');
/// showFzSnack(context, 'No se pudo abrir el link', kind: FzSnackKind.error);
/// ```
void showFzSnack(
  BuildContext context,
  String message, {
  FzSnackKind kind = FzSnackKind.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final (icon, accent) = switch (kind) {
    FzSnackKind.info => (Icons.info_outline_rounded, FzColors.textDim),
    FzSnackKind.success => (
      Icons.check_circle_outline_rounded,
      FzColors.primary,
    ),
    FzSnackKind.error => (Icons.error_outline_rounded, FzColors.lateColor),
  };

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: FzColors.card,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FzRadius.lg),
          side: BorderSide(color: accent.withValues(alpha: 0.45)),
        ),
        content: Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  height: 1.35,
                  color: FzColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
