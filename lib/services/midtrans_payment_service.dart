import '../models/payment_model.dart';
import 'payment_service.dart';

/// Future adapter to our backend only. Never put a Midtrans Server Key here.
/// Backend must recalculate prices, verify webhooks and provide authoritative status.
class MidtransPaymentService implements PaymentService {
  @override
  Future<PaymentTransaction> create({
    required String orderId,
    required int amount,
    required PaymentMethod method,
  }) => Future.error(
    UnimplementedError(
      'Backend Midtrans belum tersedia. Gunakan MockPaymentService.',
    ),
  );
  @override
  Future<PaymentResult> check(String transactionId) => Future.error(
    UnimplementedError('Status harus diverifikasi oleh backend.'),
  );
}
