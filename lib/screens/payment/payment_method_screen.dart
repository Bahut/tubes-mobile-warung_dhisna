import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/customer_information_form.dart';
import '../../widgets/payment_method_selector.dart';
import '../../widgets/formatters.dart';
import '../../widgets/order_item_tile.dart';
import '../../widgets/page_layout.dart';
import '../../widgets/checkout_bottom_bar.dart';
import 'qris_payment_screen.dart';
import 'cash_payment_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key, required this.checkout});
  final CheckoutSnapshot checkout;
  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(),
      phone = TextEditingController(),
      address = TextEditingController();
  final orderId = 'WBD-${DateTime.now().microsecondsSinceEpoch}';
  PaymentMethod method = PaymentMethod.qris;
  bool opening = false;
  bool showItems = false;
  static const _darkTeal = Color(0xFF0E363F);
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (opening || !formKey.currentState!.validate()) {
      return;
    }
    setState(() => opening = true);
    final customer = CustomerInformation(
      name: name.text.trim(),
      phone: phone.text.replaceAll(RegExp(r'[\s-]'), ''),
      address: address.text.trim(),
    );
    final payment = context.read<PaymentProvider>();
    final ok = await payment.create(orderId, widget.checkout.total, method);
    if (!mounted) {
      return;
    }
    if (ok) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => method == PaymentMethod.qris
              ? QrisPaymentScreen(checkout: widget.checkout, customer: customer)
              : CashPaymentScreen(
                  checkout: widget.checkout,
                  customer: customer,
                ),
        ),
      );
    }
    if (mounted) {
      setState(() => opening = false);
    }
  }

  // Figma: "Rincian Pesanan" dengan jumlah item, "Lihat Detail", subtotal, total.
  Widget _orderDetails() {
    final checkout = widget.checkout;
    return SectionCard(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Rincian Pesanan',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${checkout.items.length} item',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => showItems = !showItems),
              style: TextButton.styleFrom(
                foregroundColor: _darkTeal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(showItems ? 'Tutup' : 'Lihat Detail'),
            ),
          ],
        ),
        const Divider(height: 16),
        if (showItems) ...[
          for (final item in checkout.items) OrderItemTile(item: item),
          if (checkout.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Catatan pesanan: ${checkout.note}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ),
          const Divider(height: 16),
        ],
        Row(
          children: [
            const Expanded(
              child: Text(
                'Subtotal pesanan',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7273)),
              ),
            ),
            Text(
              rupiah(checkout.subtotal),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        const Divider(height: 28),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              rupiah(checkout.total),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _darkTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    return PageLayout(
      title: 'Data Pesanan',
      bottom: CheckoutBottomBar(
        total: widget.checkout.total,
        totalLabel: 'Total Tagihan',
        label: 'Lanjutkan →',
        loading: opening,
        onPressed: next,
      ),
      children: [
        CustomerInformationForm(
          formKey: formKey,
          name: name,
          phone: phone,
          address: address,
        ),
        _orderDetails(),
        PaymentMethodSelector(
          value: method,
          onChanged: (selectedMethod) =>
              setState(() => method = selectedMethod),
        ),
        if (paymentProvider.error != null)
          Text(
            paymentProvider.error!,
            style: const TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
