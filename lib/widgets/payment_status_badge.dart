import 'package:flutter/material.dart';

import '../models/payment_model.dart';

String paymentLabel(PaymentStatus status) => switch (status) {
  PaymentStatus.pending => 'Menunggu pembayaran',
  PaymentStatus.success => 'Lunas',
  PaymentStatus.failed => 'Pembayaran gagal',
  PaymentStatus.expired => 'Pembayaran kedaluwarsa',
  PaymentStatus.awaitingCashPayment => 'Menunggu Pembayaran Tunai',
};

// Gabungan metode dan status untuk ringkasan, mis. "Lunas via QRIS".
String paymentMethodStatus(PaymentTransaction payment) => switch ((
  payment.method,
  payment.status,
)) {
  (PaymentMethod.qris, PaymentStatus.success) => 'Lunas via QRIS',
  (PaymentMethod.cash, PaymentStatus.success) => 'Lunas (Tunai)',
  (PaymentMethod.qris, PaymentStatus.pending) => 'QRIS • Menunggu pembayaran',
  (_, final status) => paymentLabel(status),
};

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});
  final PaymentStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: status == PaymentStatus.success
          ? const Color(0xFFE8F6ED)
          : const Color(0xFFFFF3D6),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      paymentLabel(status),
      style: TextStyle(
        fontSize: 11,
        color: status == PaymentStatus.success
            ? Colors.green.shade800
            : Colors.orange.shade900,
      ),
    ),
  );
}
