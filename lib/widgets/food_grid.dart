import 'package:flutter/material.dart';

import '../models/food_model.dart';
import 'food_card.dart';

class FoodGrid extends StatelessWidget {
  const FoodGrid({super.key, required this.foods, required this.onTap});
  final List<FoodModel> foods;
  final ValueChanged<FoodModel> onTap;

  // Figma: margin kiri-kanan 10, jarak antar-card 10.
  static const sidePadding = 10.0;
  static const spacing = 10.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - sidePadding * 2 - spacing) / 2;
      final imageHeight =
          (cardWidth - FoodCard.horizontalPadding * 2) /
          FoodCard.imageAspectRatio;
      // Tinggi teks: nama 2 baris + harga 1 baris, ikut skala font HP.
      final textHeight = MediaQuery.textScalerOf(context)
          .scale(14 * 1.25 * 2 + 10 * 1.25);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(sidePadding, 17, sidePadding, 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // 21 + 14 + 4 + 8 + 20 + 5 + 2 (border) = 74
          mainAxisExtent: imageHeight + textHeight + 74,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: foods.length,
        itemBuilder: (_, index) =>
            FoodCard(food: foods[index], onTap: () => onTap(foods[index])),
      );
    },
  );
}
