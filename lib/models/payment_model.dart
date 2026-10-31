enum PaymentMethod { qris, cash }

enum PaymentStatus { pending, success, failed, expired, awaitingCashPayment }

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });
  final String id, orderId;
  final int amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt, expiresAt;
  PaymentTransaction withStatus(PaymentStatus value) => PaymentTransaction(
    id: id,
    orderId: orderId,
    amount: amount,
    method: method,
    status: value,
    createdAt: createdAt,
    expiresAt: expiresAt,
  );
}

class PaymentResult {
  const PaymentResult({this.transaction, this.error});
  final PaymentTransaction? transaction;
  final String? error;
}
