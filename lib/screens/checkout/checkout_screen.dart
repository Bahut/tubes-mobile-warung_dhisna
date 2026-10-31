import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_layout.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/checkout_bottom_bar.dart';
import '../food/food_detail_screen.dart';
import '../payment/payment_method_screen.dart';

// Susunan mengikuti Figma "checkout.png".
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Widget _sectionHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
    decoration: const BoxDecoration(
      color: Color(0xFFFCFCFC),
      border: Border(bottom: BorderSide(color: Color(0xFFD2D2D2))),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Pesanan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Tambah Pesanan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.blue,
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            side: const BorderSide(color: AppColors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _noteField() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: TextField(
      controller: note,
      maxLength: 300,
      style: const TextStyle(fontSize: 13),
      decoration: const InputDecoration(
        hintText: 'Catatan Tambahan',
        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        prefixIcon: Icon(Icons.edit_square, size: 22, color: Colors.black87),
        counterText: '',
        filled: false,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: pageAppBar(context, 'Pesanan'),
      body: ListView(
        children: [
          _sectionHeader(),
          if (cart.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada pesanan.'),
            ),
          for (final item in cart.items)
            CartItemTile(
              item: item,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FoodDetailScreen(food: item.food, item: item),
                ),
              ),
              onQuantity: (quantity) => cart.changeQuantity(item.id, quantity),
              onRemove: () => cart.remove(item.id),
            ),
          _noteField(),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: CheckoutBottomBar(
        total: cart.subtotal,
        label: 'Lanjutkan ke Pembayaran',
        onPressed: cart.items.isEmpty
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PaymentMethodScreen(
                    checkout: cart.snapshot(note: note.text.trim()),
                  ),
                ),
              ),
      ),
    );
  }
}
