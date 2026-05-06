import '../core/supabase_client.dart';
import '../domain/period.dart';
import '../models/bill.dart';
import '../models/enums.dart';

class BillsRepository {
  /// Bills activos (sin filtrar por validez de período). Reservar para
  /// pantallas administrativas (Configuración).
  Future<List<Bill>> fetchAllActive() async {
    final rows = await supabase
        .from('bills')
        .select()
        .eq('active', true)
        .order('day_of_month', ascending: true);
    return rows.map((r) => Bill.fromJson(r)).toList();
  }

  /// Bills activos y vigentes en el período dado (start_period <= period
  /// AND (end_period IS NULL OR end_period >= period)).
  Future<List<Bill>> fetchActiveForPeriod(PeriodKey period) async {
    final iso = period.toIso();
    final rows = await supabase
        .from('bills')
        .select()
        .eq('active', true)
        .lte('start_period', iso)
        .or('end_period.is.null,end_period.gte.$iso')
        .order('day_of_month', ascending: true);
    return rows.map((r) => Bill.fromJson(r)).toList();
  }

  Future<List<Bill>> fetchAll() async {
    final rows = await supabase
        .from('bills')
        .select()
        .order('day_of_month', ascending: true);
    return rows.map((r) => Bill.fromJson(r)).toList();
  }

  Future<Bill?> fetchById(String id) async {
    final row = await supabase
        .from('bills')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Bill.fromJson(row);
  }

  Future<Bill> saveBill({
    String? existingId,
    required String name,
    required BillKind kind,
    double? defaultAmount,
    int? dayOfMonth,
    String? providerCode,
    bool active = true,
    String? notes,
    String? autoDebitCardId,
    String? url,
    required String startPeriod,
    String? endPeriod,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado.');
    }

    final data = <String, dynamic>{
      'user_id': user.id,
      'name': name,
      'kind': kind.name,
      'default_amount': defaultAmount,
      'day_of_month': dayOfMonth,
      'provider_code': providerCode,
      'active': active,
      'notes': notes,
      'auto_debit_card_id': autoDebitCardId,
      'url': url,
      'start_period': startPeriod,
      'end_period': endPeriod,
    };

    final row = existingId == null
        ? await supabase.from('bills').insert(data).select().single()
        : await supabase
              .from('bills')
              .update(data)
              .eq('id', existingId)
              .select()
              .single();

    return Bill.fromJson(row);
  }

  /// Borra el bill si no tiene pagos asociados; si tiene, hace soft-delete
  /// seteando `end_period` al mes anterior al actual para preservar el
  /// histórico.
  ///
  /// Retorna `true` si fue DELETE real, `false` si fue soft-delete.
  Future<bool> softDeleteOrDelete(String billId) async {
    final paymentsCount = await supabase
        .from('payments')
        .select('id')
        .eq('bill_id', billId)
        .limit(1);

    if (paymentsCount.isEmpty) {
      await supabase.from('bills').delete().eq('id', billId);
      return true;
    }

    final previousMonth = PeriodKey.current().previous().toIso();
    await supabase
        .from('bills')
        .update({'end_period': previousMonth})
        .eq('id', billId);
    return false;
  }

  /// Borra un bill sin verificar histórico — usar con cuidado.
  /// Mantenido para compatibilidad; preferir [softDeleteOrDelete].
  Future<void> deleteBill(String id) async {
    await supabase.from('bills').delete().eq('id', id);
  }
}
