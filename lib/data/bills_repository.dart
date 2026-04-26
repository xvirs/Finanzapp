import '../core/supabase_client.dart';
import '../models/bill.dart';

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
}
