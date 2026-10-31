import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/page_layout.dart';
import '../../widgets/order_header.dart';
import '../../widgets/order_item_tile.dart';
import '../../widgets/payment_status_badge.dart';
import '../../widgets/formatters.dart';
import '../../theme/app_colors.dart';

// Susunan mengikuti Figma Status Pesanan (disiapkan, diantar, tiba & selesai).
// Tanpa backend, tidak ada estimasi waktu; status hanya berubah di provider.
class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key, required this.orderId});
  final String orderId;
  static const sellerPhone = '0852-9494-8086';
  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  static const sellerPhone = OrderStatusScreen.sellerPhone;

  @override
  void initState() {
    super.initState();
    // Countdown baru mulai saat halaman ini pertama kali dibuka.
    context.read<OrderProvider>().startTracking(widget.orderId);
  }

  void contact(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hubungi Penjual'),
      content: const Text(
        'Hubungi Warung Ibu Kost Dhiesna lewat telepon atau WhatsApp:\n'
        '$sellerPhone',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: sellerPhone));
            Navigator.pop(dialogContext);
          },
          child: const Text('Salin nomor'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final order = orders.getById(widget.orderId);
    final secondsLeft = orders.secondsLeft(widget.orderId);
    final arrived = order.status == OrderStatus.completed;
    return PageLayout(
      title: 'Status Pesanan',
      children: [
        OrderHeader(order: order, tracking: true),
        if (secondsLeft != null) _countdown(secondsLeft),
        _statusCard(order),
        _orderDetails(order, arrived),
        if (order.status == OrderStatus.completed)
          FilledButton.icon(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            icon: const Icon(Icons.add_shopping_cart, size: 20),
            label: const Text('Pesan Lagi'),
          ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: TextButton.icon(
            onPressed: () => contact(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 44),
              textStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Hubungi Penjual'),
          ),
        ),
      ],
    );
  }

  // Format 00:15, 00:14, ... sampai tahap berikutnya.
  Widget _countdown(int seconds) => GreyBox(
    child: Row(
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: _muted),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Tahap berikutnya dalam',
            style: TextStyle(fontSize: 13, color: _muted),
          ),
        ),
        Text(
          '00:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ],
    ),
  );

  Widget _statusCard(OrderModel order) => SectionCard(
    children: switch (order.status) {
      OrderStatus.confirmed => const [
        _SmallLabel('STATUS PESANAN'),
        _BigText('Pesanan dikonfirmasi'),
        _BodyText('Pesanan sudah diterima warung dan menunggu disiapkan.'),
      ],
      OrderStatus.preparing => const [
        _SmallLabel('STATUS DAPUR'),
        _BigText('Pesanan sedang disiapkan'),
        _BodyText('Dapur Warung Ibu Kost Dhiesna sedang menyiapkan pesananmu.'),
      ],
      OrderStatus.delivering => [
        const _SmallLabel('PENGANTARAN'),
        const _BigText('Pesanan sedang diantar'),
        _BodyText('Pengantar sedang menuju ${order.customer.address}.'),
        const SizedBox(height: 16),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/restaurant/delivery.png',
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
      OrderStatus.completed => [
        const Row(
          children: [
            Icon(Icons.room_service_outlined, size: 22),
            SizedBox(width: 8),
            Expanded(child: _BigText('Pesanan Sudah Tiba')),
          ],
        ),
        _BodyText(
          'Silakan periksa hidangan Anda di ${order.customer.address}. '
          'Selamat menikmati makanan Anda.',
        ),
        const SizedBox(height: 14),
        GreyBox(
          child: Row(
            children: [
              const Icon(Icons.qr_code_2, size: 18, color: _muted),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Status Pembayaran',
                  style: TextStyle(fontSize: 13, color: _muted),
                ),
              ),
              Expanded(
                child: Text(
                  paymentMethodStatus(order.payment),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    },
  );

  // Belum tiba: rincian bisa dibuka-tutup. Sudah tiba: "ITEM DITERIMA".
  Widget _orderDetails(OrderModel order, bool arrived) {
    final checkout = order.checkout;
    final count = checkout.items.length;
    final items = [
      for (final item in checkout.items)
        OrderItemTile(item: item, received: arrived),
      if (checkout.note.isNotEmpty)
        Text(
          'Catatan pesanan: ${checkout.note}',
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
      const Divider(height: 20),
      _row(
        'Metode pembayaran',
        '${order.payment.method == PaymentMethod.qris ? 'QRIS' : 'Tunai'} '
            '(${paymentLabel(order.payment.status)})',
      ),
      const SizedBox(height: 8),
      _row('Total pembayaran', rupiah(checkout.total), bold: true),
    ];
    return SectionCard(
      children: [
        ExpansionTile(
          key: ValueKey(arrived),
          initiallyExpanded: arrived,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          title: Text(
            arrived
                ? 'ITEM DITERIMA ($count MENU)'
                : 'Rincian pesanan ($count menu)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Total pembayaran ${rupiah(checkout.total)}',
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
          children: [GreyBox(child: Column(children: items))],
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: bold ? 14 : 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: bold ? Colors.black : _muted,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: bold ? 16 : 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, letterSpacing: 0.4, color: _muted),
    ),
  );
}

class _BigText extends StatelessWidget {
  const _BigText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  );
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, height: 1.4, color: _muted),
    ),
  );
}

const _muted = Color(0xFF6B7273);
