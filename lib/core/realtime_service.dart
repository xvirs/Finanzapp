import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Tablas que monitoreamos para auto-refresh.
enum RealtimeTable { bills, creditCards, installmentPurchases, payments }

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
    }
  }
}

/// Mantiene un canal único de Supabase Realtime con suscripciones a las 4
/// tablas del usuario. Cuando llega un cambio (insert/update/delete) emite
/// el [RealtimeTable] correspondiente por [changes]. Los blocs escuchan y
/// dispatch un refresh silencioso si la tabla los afecta.
///
/// Importante: para que esto funcione, hay que habilitar Realtime en las
/// 4 tablas en el Dashboard de Supabase (Database → Replication → activar
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

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
