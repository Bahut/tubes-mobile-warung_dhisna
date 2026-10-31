import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/page_layout.dart';
import '../../widgets/formatters.dart';
import '../../widgets/order_item_tile.dart';
import '../../widgets/payment_info_label.dart';
import '../order/order_summary_screen.dart';

class CashPaymentScreen extends StatefulWidget {
  const CashPaymentScreen({
    super.key,
    required this.checkout,
    required this.customer,
  });
  final CheckoutSnapshot checkout;
  final CustomerInformation customer;
  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  bool submitted = false;
  void confirm() {
    if (submitted) {
      return;
    }
    setState(() => submitted = true);
    final transaction = context.read<PaymentProvider>().transaction!;
    context.read<OrderProvider>().confirm(
      OrderModel(
        id: transaction.orderId,
        checkout: widget.checkout,
        customer: widget.customer,
        payment: transaction,
      ),
    );
    context.read<CartProvider>().clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OrderSummaryScreen(orderId: transaction.orderId),
      ),
      (r) => r.isFirst,
    );
  }

  // Figma "Pembayaran Tunai - Konfirmasi Pesanan".
  @override
  Widget build(BuildContext context) => PageLayout(
    title: 'Konfirmasi Pembayaran',
    bottom: BottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: submitted ? null : confirm,
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Pesan Sekarang'),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: submitted ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _muted),
            child: const Text('Ganti cara bayar'),
          ),
        ],
      ),
    ),
    children: [
      SectionCard(
        children: [
          const PaymentInfoLabel('METODE PEMBAYARAN'),
          const Row(
            children: [
              Icon(Icons.payments_outlined, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tunai saat pesanan tiba',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          const PaymentInfoLabel('TOTAL YANG HARUS DIBAYAR'),
          Text(
            rupiah(widget.checkout.total),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const Divider(height: 28),
          const PaymentInfoLabel('LOKASI PENGANTARAN'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.customer.address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          const PaymentInfoLabel('RINCIAN PESANAN'),
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                '${widget.checkout.items.length} item',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          for (final item in widget.checkout.items) OrderItemTile(item: item),
        ],
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F1F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bayar ${rupiah(widget.checkout.total)} langsung kepada '
                    'pengantar saat pesanan sampai.',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Siapkan uang pas. Status pembayaran tetap menunggu '
                    'sampai uang diterima petugas.',
                    style: TextStyle(fontSize: 13, color: _muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bolt_outlined, size: 16, color: _muted),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Setelah menekan tombol di bawah, pesananmu akan langsung '
              'dikirim ke dapur dan disiapkan.',
              style: TextStyle(fontSize: 12, color: _muted),
            ),
          ),
        ],
      ),
    ],
  );
}

const _muted = Color(0xFF6B7273);
