import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/checkout_bottom_bar.dart';
import '../../widgets/page_layout.dart';
import '../food/food_detail_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: pageAppBar(context, 'Keranjang'),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_basket_outlined,
                    size: 64,
                    color: Color(0xFFBDBDBD),
                  ),
                  const SizedBox(height: 16),
                  const Text('Keranjang masih kosong'),
                  TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Text('Pilih makanan'),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                for (final item in cart.items)
                  CartItemTile(
                    item: item,
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            FoodDetailScreen(food: item.food, item: item),
                      ),
                    ),
                    onQuantity: (quantity) =>
                        cart.changeQuantity(item.id, quantity),
                    onRemove: () => cart.remove(item.id),
                  ),
              ],
            ),
      bottomNavigationBar: CheckoutBottomBar(
        total: cart.subtotal,
        label: 'PESAN',
        onPressed: cart.items.isEmpty
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
              ),
      ),
    );
  }
}
