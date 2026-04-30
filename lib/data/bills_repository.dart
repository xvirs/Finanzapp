import '../core/supabase_client.dart';
import '../models/bill.dart';
import '../models/enums.dart';

class BillsRepository {
  Future<List<Bill>> fetchAllActive() async {
    final rows = await supabase
        .from('bills')
        .select()
        .eq('active', true)
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

  Future<void> deleteBill(String id) async {
    await supabase.from('bills').delete().eq('id', id);
  }
}
