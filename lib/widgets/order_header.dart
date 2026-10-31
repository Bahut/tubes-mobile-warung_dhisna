import 'package:flutter/material.dart';

import '../models/order_model.dart';
import 'page_layout.dart';
import 'order_status_stepper.dart';

// Kartu atas Ringkasan dan Tracking (Figma): nama warung, chip status,
// lalu nomor referensi (ringkasan) atau garis progres (tracking).
class OrderHeader extends StatelessWidget {
  const OrderHeader({super.key, required this.order, this.tracking = false});
  final OrderModel order;
  final bool tracking;

  @override
  Widget build(BuildContext context) => SectionCard(
    children: [
      // Nama dan label status satu baris jika muat; jika label terlalu
      // panjang (mis. "Pesanan Dikonfirmasi"), label turun ke baris berikutnya.
      SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
              'Warung Ibu Kost Dhiesna',
              style: TextStyle(
                fontSize: tracking ? 16 : 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE1EBEF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tracking
                    ? orderStatusLabels[order.status.index]
                    : '● Terkonfirmasi',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        tracking
            ? 'ID Pesanan #${order.id}'
            : '${order.customer.name} • ${order.customer.address}',
        style: TextStyle(
          fontSize: tracking ? 13 : 12,
          color: const Color(0xFF424A4D),
        ),
      ),
      const SizedBox(height: 14),
      if (tracking)
        OrderStatusStepper(status: order.status)
      else
        GreyBox(
          child: Row(
            children: [
              const Text(
                'No. Referensi',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7273)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '#${order.id}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
