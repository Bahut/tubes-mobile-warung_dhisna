class FoodOption {
  const FoodOption(this.id, this.name, this.price);
  final String id, name;
  final int price;
}

class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.options = const [],
    this.isAvailable = true,
  });
  final String id, name, description, category;
  final int price;
  final List<FoodOption> options;
  final bool isAvailable;

  // Ganti foto cukup dengan menaruh file bernama sama di folder ini.
  String get image => 'assets/images/foods/$id.jpg';
}
