import '../models/payment_model.dart';

abstract interface class PaymentService {
  Future<PaymentTransaction> create({
    required String orderId,
    required int amount,
    required PaymentMethod method,
  });
  Future<PaymentResult> check(String transactionId);
}
