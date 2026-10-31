import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../widgets/page_layout.dart';
import '../../widgets/order_header.dart';
import '../../widgets/order_item_tile.dart';
import '../../widgets/payment_status_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/formatters.dart';
import 'order_status_screen.dart';

// Susunan mengikuti Figma "Ringkasan pesanan" (QRIS dan Tunai).
class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().getById(orderId);
    final checkout = order.checkout;
    return PageLayout(
      title: 'Ringkasan Pesanan',
      children: [
        OrderHeader(order: order),
        SectionCard(
          children: [
            GreyBox(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar pesanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${checkout.items.length} menu',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            for (final (index, item) in checkout.items.indexed) ...[
              if (index > 0) const Divider(height: 1),
              OrderItemTile(item: item),
            ],
            if (checkout.note.isNotEmpty)
              Text(
                'Catatan pesanan: ${checkout.note}',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
          ],
        ),
        SectionCard(
          children: [
            const Text(
              'Rincian pembayaran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            _row('Subtotal', rupiah(checkout.subtotal)),
            const Divider(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total pembayaran',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  rupiah(checkout.total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GreyBox(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Metode & status',
                          style: TextStyle(fontSize: 12, color: _muted),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1EBEF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            paymentMethodStatus(order.payment),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _row(
                    'Waktu transaksi',
                    transactionTime(order.payment.createdAt),
                    small: true,
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pembayaran simulasi untuk presentasi',
                      style: TextStyle(fontSize: 11, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        PrimaryButton(
          label: 'Lihat status pesanan',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => OrderStatusScreen(orderId: orderId),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool small = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(fontSize: small ? 12 : 14, color: _muted),
        ),
      ),
      Text(value, style: TextStyle(fontSize: small ? 12 : 14)),
    ],
  );
}

const _muted = Color(0xFF6B7273);
