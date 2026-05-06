import '../core/supabase_client.dart';
import '../domain/period.dart';
import '../models/enums.dart';
import '../models/income.dart';

class IncomesRepository {
  /// Ingresos activos (sin filtrar por validez de período).
  Future<List<Income>> fetchAllActive() async {
    final rows = await supabase
        .from('incomes')
        .select()
        .eq('active', true)
        .order('day_of_month', ascending: true);
    return rows.map((r) => Income.fromJson(r)).toList();
  }

  /// Ingresos activos y vigentes en el período dado.
  Future<List<Income>> fetchActiveForPeriod(PeriodKey period) async {
    final iso = period.toIso();
    final rows = await supabase
        .from('incomes')
        .select()
        .eq('active', true)
        .lte('start_period', iso)
        .or('end_period.is.null,end_period.gte.$iso')
        .order('day_of_month', ascending: true);
    return rows.map((r) => Income.fromJson(r)).toList();
  }

  Future<List<Income>> fetchAll() async {
    final rows = await supabase
        .from('incomes')
        .select()
        .order('day_of_month', ascending: true);
    return rows.map((r) => Income.fromJson(r)).toList();
  }

  Future<Income?> fetchById(String id) async {
    final row = await supabase
        .from('incomes')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Income.fromJson(row);
  }

  Future<Income> saveIncome({
    String? existingId,
    required String name,
    required IncomeKind kind,
    double? defaultAmount,
    int? dayOfMonth,
    bool active = true,
    String? notes,
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
      'active': active,
      'notes': notes,
      'start_period': startPeriod,
      'end_period': endPeriod,
    };

    final row = existingId == null
        ? await supabase.from('incomes').insert(data).select().single()
        : await supabase
              .from('incomes')
              .update(data)
              .eq('id', existingId)
              .select()
              .single();

    return Income.fromJson(row);
  }

  /// Por simetría con bills. Hoy `incomes` no tiene tabla de pagos
  /// asociada, así que siempre hace DELETE real. La firma queda lista
  /// para cuando exista un futuro `income_records` o equivalente.
  Future<bool> softDeleteOrDelete(String incomeId) async {
    await supabase.from('incomes').delete().eq('id', incomeId);
    return true;
  }

  Future<void> deleteIncome(String id) async {
    await supabase.from('incomes').delete().eq('id', id);
  }
}
