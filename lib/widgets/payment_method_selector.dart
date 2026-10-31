import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import 'payment_method_card.dart';
import 'page_layout.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;
  @override
  Widget build(BuildContext context) => SectionCard(
    children: [
      const Text(
        'Pilih Cara Bayar',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      const Text(
        'Semua transaksi tercatat otomatis',
        style: TextStyle(fontSize: 11, color: Color(0xFF6B7273)),
      ),
      for (final method in PaymentMethod.values)
        PaymentMethodCard(
          method: method,
          selected: method == value,
          onTap: () => onChanged(method),
        ),
    ],
  );
}
