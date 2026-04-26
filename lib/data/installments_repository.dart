import '../core/supabase_client.dart';
import '../models/installment_purchase.dart';

class InstallmentsRepository {
  Future<List<InstallmentPurchase>> fetchAll() async {
    final rows = await supabase
        .from('installment_purchases')
        .select()
        .order('first_period', ascending: false);
    return rows.map((r) => InstallmentPurchase.fromJson(r)).toList();
  }

  Future<List<InstallmentPurchase>> fetchForCard(String cardId) async {
    final rows = await supabase
        .from('installment_purchases')
        .select()
        .eq('credit_card_id', cardId)
        .order('first_period', ascending: false);
    return rows.map((r) => InstallmentPurchase.fromJson(r)).toList();
  }
}
