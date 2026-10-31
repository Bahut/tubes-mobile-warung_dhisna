import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/page_layout.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/formatters.dart';
import '../../widgets/payment_status_badge.dart';
import '../../widgets/payment_countdown.dart';
import '../../widgets/payment_info_label.dart';
import '../order/order_summary_screen.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({
    super.key,
    required this.checkout,
    required this.customer,
  });
  final CheckoutSnapshot checkout;
  final CustomerInformation customer;
  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  bool navigated = false;
  // true setelah pelanggan menekan Cek Status minimal sekali.
  bool checked = false;
  Future<void> check() async {
    final paymentProvider = context.read<PaymentProvider>();
    await paymentProvider.check();
    if (!mounted || navigated) {
      return;
    }
    setState(() => checked = true);
    final transaction = paymentProvider.transaction!;
    if (transaction.status == PaymentStatus.success) {
      navigated = true;
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
  }

  // Belum ada frame QRIS di Figma; gaya mengikuti halaman Konfirmasi Pembayaran.
  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final transaction = paymentProvider.transaction!;
    final isPending = transaction.status == PaymentStatus.pending;
    return PageLayout(
      title: 'Pembayaran QRIS',
      bottom: BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: paymentProvider.error == null
                  ? 'Cek Status Pembayaran'
                  : 'Coba Lagi',
              loading: paymentProvider.loading,
              onPressed: check,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: paymentProvider.loading
                  ? null
                  : () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: _muted),
              child: const Text('Ganti Metode Pembayaran'),
            ),
          ],
        ),
      ),
      children: [
        SectionCard(
          children: [
            const Text(
              'Warung Ibu Kost Dhiesna',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'No. Referensi: ${transaction.orderId}',
              style: const TextStyle(fontSize: 12, color: _muted),
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
            const PaymentInfoLabel('TOTAL PEMBAYARAN'),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  rupiah(transaction.amount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                PaymentStatusBadge(status: transaction.status),
              ],
            ),
          ],
        ),
        SectionCard(
          children: [
            const Center(
              child: Text(
                'Scan QRIS untuk membayar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            const Center(child: _QrisImage()),
            const SizedBox(height: 16),
            for (final (index, step) in const [
              'Buka aplikasi m-banking atau e-wallet yang mendukung QRIS.',
              'Scan kode QRIS di atas, lalu bayar sesuai total.',
              'Setelah membayar, tekan Cek Status Pembayaran.',
            ].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${index + 1}. $step',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
          ],
        ),
        if (isPending)
          PaymentCountdown(expiresAt: transaction.expiresAt, onExpired: check),
        SectionCard(
          children: [
            const Text(
              'Detail Pembayaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _detailRow('Total Tagihan', rupiah(transaction.amount)),
            const Divider(height: 20),
            _detailRow('Metode Pembayaran', 'QRIS'),
            const Divider(height: 20),
            _detailRow('Status', paymentLabel(transaction.status)),
            const SizedBox(height: 12),
            const Text(
              'Pembayaran simulasi untuk presentasi',
              style: TextStyle(fontSize: 11, color: _muted),
            ),
          ],
        ),
        if (paymentProvider.error != null)
          Text(
            paymentProvider.error!,
            style: const TextStyle(color: Colors.red),
          )
        else if (isPending && checked)
          const _Notice(
            'Pembayaran belum dikonfirmasi. Selesaikan pembayaran di '
            'aplikasimu, lalu cek lagi.',
          ),
        if (transaction.status == PaymentStatus.failed ||
            transaction.status == PaymentStatus.expired)
          const _Notice(
            'Transaksi ini sudah berakhir. Ganti metode pembayaran atau '
            'buat pesanan baru.',
          ),
      ],
    );
  }

  Widget _detailRow(String label, String value) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 13, color: _muted)),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

// Gambar QRIS ilustrasi untuk presentasi (bukan QR transaksi sungguhan).
// Setelah backend + Midtrans tersedia, ganti dengan QR dari Midtrans.
class _QrisImage extends StatelessWidget {
  const _QrisImage();
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 240),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset('assets/images/payment/qris.jpg', fit: BoxFit.contain),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE9F1F6),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

const _muted = Color(0xFF6B7273);
