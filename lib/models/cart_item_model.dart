import 'food_model.dart';

class CartItemModel {
  CartItemModel({
    required this.id,
    required this.food,
    this.quantity = 1,
    String note = '',
    Map<String, int> options = const {},
  }) : note = note.trim(), // catatan berisi spasi saja dianggap kosong
       options = Map.unmodifiable(options) {
    if (quantity < 1 ||
        options.values.any((quantity) => quantity < 0) ||
        options.keys.any(
          (id) => !food.options.any((option) => option.id == id),
        )) {
      throw ArgumentError('Pilihan atau jumlah tidak valid');
    }
  }
  final String id, note;
  final FoodModel food;
  final int quantity;
  final Map<String, int> options;
  // Tambahan dihitung per porsi, lalu dikalikan jumlah makanan.
  int get unitPrice {
    int price = food.price;
    for (final option in food.options) {
      final selectedQuantity = options[option.id] ?? 0;
      price += option.price * selectedQuantity;
    }
    return price;
  }

  int get total => unitPrice * quantity;
  CartItemModel copyWith({
    int? quantity,
    String? note,
    Map<String, int>? options,
  }) => CartItemModel(
    id: id,
    food: food,
    quantity: quantity ?? this.quantity,
    note: note ?? this.note,
    options: options ?? this.options,
  );
}
