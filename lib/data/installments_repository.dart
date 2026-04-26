import '../core/supabase_client.dart';
import '../domain/period.dart';
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

  Future<InstallmentPurchase?> fetchById(String id) async {
    final row = await supabase
        .from('installment_purchases')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : InstallmentPurchase.fromJson(row);
  }

  Future<InstallmentPurchase> savePurchase({
    String? existingId,
    required String creditCardId,
    required String description,
    required int installmentCount,
    required double installmentAmount,
    required PeriodKey firstPeriod,
    String? notes,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado.');
    }

    final data = <String, dynamic>{
      'user_id': user.id,
      'credit_card_id': creditCardId,
      'description': description,
      'total_amount': installmentAmount * installmentCount,
      'installment_count': installmentCount,
      'installment_amount': installmentAmount,
      'first_period': firstPeriod.toIso(),
      'notes': notes,
    };

    final row = existingId == null
        ? await supabase
            .from('installment_purchases')
            .insert(data)
            .select()
            .single()
        : await supabase
            .from('installment_purchases')
            .update(data)
            .eq('id', existingId)
            .select()
            .single();

    return InstallmentPurchase.fromJson(row);
  }

  Future<void> deletePurchase(String id) async {
    await supabase.from('installment_purchases').delete().eq('id', id);
  }
}
