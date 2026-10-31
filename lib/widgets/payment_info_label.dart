import 'package:flutter/material.dart';

// Label kecil huruf kapital abu-abu di atas setiap info pembayaran.
class PaymentInfoLabel extends StatelessWidget {
  const PaymentInfoLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: Color(0xFF6B7273),
      ),
    ),
  );
}
