import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_food_data.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/restaurant_header.dart';
import '../../widgets/category_tabs.dart';
import '../../widgets/food_grid.dart';
import '../../widgets/cart_floating_bar.dart';
import '../food/food_detail_screen.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool search = false;
  String query = '';
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final foods = mockFoods
        .where(
          (food) => query.isNotEmpty
              ? food.name.toLowerCase().contains(query.toLowerCase())
              : food.category == cart.category,
        )
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            RestaurantHeader(onSearch: () => setState(() => search = !search)),
            if (search)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari makanan',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
            CategoryTabs(
              categories: foodCategories,
              selected: cart.category,
              onSelected: (value) {
                setState(() => query = '');
                cart.selectCategory(value);
              },
            ),
            if (foods.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Makanan tidak ditemukan.'),
              ),
            FoodGrid(
              foods: foods,
              onTap: (food) => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FoodDetailScreen(food: food),
                ),
              ),
            ),
            // Ruang kosong agar card terakhir tidak tertutup bar keranjang.
            if (cart.quantity > 0) const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cart.quantity == 0
          ? null
          : CartFloatingBar(
              quantity: cart.quantity,
              total: cart.subtotal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const CartScreen()),
              ),
            ),
    );
  }
}
