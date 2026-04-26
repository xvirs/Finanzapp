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
}
