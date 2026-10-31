import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../theme/app_colors.dart';

const orderStatusLabels = [
  'Pesanan Dikonfirmasi',
  'Sedang Disiapkan',
  'Sedang Diantar',
  'Pesanan Selesai',
];

// Figma: tiga garis progres "Disiapkan", "Otewe", "Selesai".
class OrderStatusStepper extends StatelessWidget {
  const OrderStatusStepper({super.key, required this.status});
  final OrderStatus status;

  // Jumlah garis yang sudah biru untuk setiap status.
  int get _filled => switch (status) {
    OrderStatus.confirmed => 0,
    OrderStatus.preparing => 1,
    OrderStatus.delivering => 2,
    OrderStatus.completed => 3,
  };

  Color _color(int index) =>
      index < _filled ? AppColors.blue : const Color(0xFFA0A0A0);

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final (index, label) in const [
        'Disiapkan',
        'Otewe',
        'Selesai',
      ].indexed)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _color(index),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      index < _filled ? Icons.check : Icons.close,
                      size: 12,
                      color: _color(index),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: _color(index)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
