import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Tablas que monitoreamos para auto-refresh.
enum RealtimeTable {
  bills,
  creditCards,
  installmentPurchases,
  payments,
  incomes,
}

extension RealtimeTableX on RealtimeTable {
  String get name {
    switch (this) {
      case RealtimeTable.bills:
        return 'bills';
      case RealtimeTable.creditCards:
        return 'credit_cards';
      case RealtimeTable.installmentPurchases:
        return 'installment_purchases';
      case RealtimeTable.payments:
        return 'payments';
      case RealtimeTable.incomes:
        return 'incomes';
    }
  }
}

/// Mantiene un canal único de Supabase Realtime con suscripciones a las
/// tablas del usuario. Cuando llega un cambio (insert/update/delete) emite
/// el [RealtimeTable] correspondiente por [changes]. Los blocs escuchan y
/// dispatch un refresh silencioso si la tabla los afecta.
///
/// Importante: para que esto funcione, hay que habilitar Realtime en cada
/// tabla en el Dashboard de Supabase (Database → Replication → activar
/// el toggle por tabla).
class RealtimeService {
  RealtimeService();

  RealtimeChannel? _channel;
  final _controller = StreamController<RealtimeTable>.broadcast();

  /// Stream de cambios. Cada evento es la tabla que cambió.
  Stream<RealtimeTable> get changes => _controller.stream;

  bool get isActive => _channel != null;

  /// Inicia el canal. Llamar una vez al loguearse (o al iniciar la app
  /// si ya hay sesión persistente).
  Future<void> start() async {
    if (_channel != null) return;

    final channel = supabase.channel('user-data');

    for (final table in RealtimeTable.values) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table.name,
        callback: (_) {
          if (!_controller.isClosed) _controller.add(table);
        },
      );
    }

    channel.subscribe();
    _channel = channel;
  }

  /// Cierra el canal. Llamar al hacer logout para liberar la conexión.
  Future<void> stop() async {
    final channel = _channel;
    if (channel == null) return;
    _channel = null;
    await supabase.removeChannel(channel);
  }

  /// Emite un cambio "local" — como si Supabase Realtime hubiera avisado.
  ///
  /// Lo usamos después de una mutación propia (crear/editar/eliminar) para
  /// que los blocs que escuchan [changes] refresquen sí o sí, sin depender
  /// de que Realtime esté habilitado en el Dashboard ni de su latencia.
  void notifyLocalChange(RealtimeTable table) {
    if (!_controller.isClosed) _controller.add(table);
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
