import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Foto makanan selalu memenuhi kotak dengan rasio tetap dan dipotong
// otomatis (BoxFit.cover). Jika file belum ada, tampil placeholder.
class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.path,
    this.aspectRatio = 4 / 3,
    this.borderRadius = 8,
  });
  final String path;
  final double aspectRatio, borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.pale,
          child: Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 32,
              color: AppColors.muted,
            ),
          ),
        ),
      ),
    ),
  );
}
