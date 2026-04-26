import '../core/supabase_client.dart';
import '../models/credit_card.dart';

class CardsRepository {
  Future<List<CreditCard>> fetchAllActive() async {
    final rows = await supabase
        .from('credit_cards')
        .select()
        .eq('active', true)
        .order('due_day', ascending: true);
    return rows.map((r) => CreditCard.fromJson(r)).toList();
  }

  Future<List<CreditCard>> fetchAll() async {
    final rows = await supabase
        .from('credit_cards')
        .select()
        .order('due_day', ascending: true);
    return rows.map((r) => CreditCard.fromJson(r)).toList();
  }

  Future<CreditCard?> fetchById(String id) async {
    final row = await supabase
        .from('credit_cards')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : CreditCard.fromJson(row);
  }
}
