import '../core/supabase_client.dart';
import '../models/credit_card.dart';
import '../models/enums.dart';

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

  /// Insert si [existingId] es null, update por id si está dado.
  /// Devuelve la fila resultante (ya sincronizada con la DB).
  Future<CreditCard> saveCard({
    String? existingId,
    required String name,
    String? issuer,
    CardBrand? brand,
    int? closingDay,
    int? dueDay,
    bool active = true,
    String? url,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado.');
    }

    final data = <String, dynamic>{
      'user_id': user.id,
      'name': name,
      'issuer': issuer,
      'brand': brand?.name,
      'closing_day': closingDay,
      'due_day': dueDay,
      'active': active,
      'url': url,
    };

    final row = existingId == null
        ? await supabase.from('credit_cards').insert(data).select().single()
        : await supabase
              .from('credit_cards')
              .update(data)
              .eq('id', existingId)
              .select()
              .single();

    return CreditCard.fromJson(row);
  }

  Future<void> deleteCard(String id) async {
    await supabase.from('credit_cards').delete().eq('id', id);
  }
}
