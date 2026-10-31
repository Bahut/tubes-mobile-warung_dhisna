import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_model.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/food_option_tile.dart';
import '../../widgets/food_image.dart';
import '../../widgets/food_note_field.dart';
import '../../widgets/quantity_selector.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/formatters.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.food, this.item});
  final FoodModel food;
  final CartItemModel? item;
  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late int quantity;
  late Map<String, int> options;
  late TextEditingController note;
  @override
  void initState() {
    super.initState();
    quantity = widget.item?.quantity ?? 1;
    options = Map.of(widget.item?.options ?? {});
    note = TextEditingController(text: widget.item?.note);
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  CartItemModel get item => CartItemModel(
    id: widget.item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
    food: widget.food,
    quantity: quantity,
    note: note.text.trim(),
    options: options,
  );
  // Ukuran mengikuti Figma Edit Makanan (layar 390).
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: ListView(
        children: [
          Stack(
            children: [
              FoodImage(
                path: widget.food.image,
                aspectRatio: 390 / 233,
                borderRadius: 0,
              ),
              Positioned(
                top: 14,
                right: 11,
                child: IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.black,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    fixedSize: const Size(30, 30),
                    minimumSize: const Size(30, 30),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
          // Lembar putih bersudut bulat yang menumpuk 10px di atas foto.
          Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.food.name,
                    style: const TextStyle(fontSize: 19.5, height: 1.25),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rupiah(widget.food.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.food.description,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFC7C7C7)),
          for (final option in widget.food.options)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 12, 8),
              child: FoodOptionTile(
                option: option,
                value: options[option.id] ?? 0,
                onChanged: (value) =>
                    setState(() => options[option.id] = value),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 32, 26, 24),
            child: FoodNoteField(controller: note),
          ),
        ],
      ),
    ),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Color(0xFFCCCCCC))),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            15,
            14,
            18,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pesanan',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          rupiah(item.total),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  QuantitySelector(
                    value: quantity,
                    minimum: 1,
                    onChanged: (value) => setState(() => quantity = value),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: PrimaryButton(
                  label: widget.item == null
                      ? 'Tambah Pesanan'
                      : 'Simpan Perubahan',
                  onPressed: () {
                    context.read<CartProvider>().save(item);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
