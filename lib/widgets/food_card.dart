import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../theme/app_colors.dart';
import 'food_image.dart';
import 'formatters.dart';

// Ukuran mengikuti Figma Beranda (card 180 x 200 pada layar 390).
class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required this.food, required this.onTap});
  final FoodModel food;
  final VoidCallback onTap;

  static const imageAspectRatio = 3 / 2;
  static const horizontalPadding = 21.0;
  static const nameStyle = TextStyle(
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  static const priceStyle = TextStyle(
    fontSize: 10,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 4,
          offset: Offset(1, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding - 1,
            21,
            horizontalPadding - 1,
            5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FoodImage(path: food.image, aspectRatio: imageAspectRatio),
              const SizedBox(height: 14),
              // Nama menu asli bisa panjang, jadi disediakan 2 baris.
              Expanded(
                child: Text(
                  food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle,
                ),
              ),
              const SizedBox(height: 4),
              // Baris kecil kedua di Figma dipakai untuk harga.
              Text(rupiah(food.price), maxLines: 1, style: priceStyle),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 20,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: AppColors.blue),
                  ),
                  onPressed: food.isAvailable ? onTap : null,
                  child: Text(
                    food.isAvailable ? 'Tambahkan' : 'Habis',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
