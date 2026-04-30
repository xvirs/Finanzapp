import '../core/supabase_client.dart';
import '../models/enums.dart';
import '../models/payment.dart';

class PaymentsRepository {
  Future<List<Payment>> fetchForPeriod(String periodIso) async {
    final rows = await supabase
        .from('payments')
        .select()
        .eq('period', periodIso);
    return rows.map((r) => Payment.fromJson(r)).toList();
  }

  /// Pagos `paid` en la ventana [startIso, endIso) — usado para promedio
  /// de los últimos pagos al sugerir monto.
  Future<List<Payment>> fetchPaidInWindow({
    required String startIso,
    required String endIso,
  }) async {
    final rows = await supabase
        .from('payments')
        .select()
        .eq('status', PaymentStatus.paid.name)
        .gte('period', startIso)
        .lt('period', endIso);
    return rows.map((r) => Payment.fromJson(r)).toList();
  }

  /// Marca un pago como `paid`. Si [existingPaymentId] está dado, actualiza
  /// la fila existente; sino, inserta una nueva. Las constraints UNIQUE
  /// (user_id, period, bill_id) y (user_id, period, card_id) garantizan
  /// que solo haya un pago por bill/card y mes.
  Future<Payment> savePaidPayment({
    String? existingPaymentId,
    required String periodIso,
    required PaymentKind kind,
    String? billId,
    String? cardId,
    required double amount,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado.');
    }

    final data = <String, dynamic>{
      'user_id': user.id,
      'period': periodIso,
      'kind': switch (kind) {
        PaymentKind.bill => 'bill',
        PaymentKind.cardTotal => 'card_total',
        PaymentKind.manual => 'manual',
      },
      'bill_id': billId,
      'card_id': cardId,
      'status': 'paid',
      'amount_real': amount,
      'paid_at': DateTime.now().toUtc().toIso8601String(),
    };

    final row = existingPaymentId == null
        ? await supabase.from('payments').insert(data).select().single()
        : await supabase
              .from('payments')
              .update(data)
              .eq('id', existingPaymentId)
              .select()
              .single();

    return Payment.fromJson(row);
  }

  /// Borra un pago — usado para "Marcar como pendiente".
  Future<void> deletePayment(String paymentId) async {
    await supabase.from('payments').delete().eq('id', paymentId);
  }
}
