import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(16, 31, 0, 0),
    child: Row(
      children: [
        for (final category in categories)
          _tab(category, isActive: category == selected),
      ],
    ),
  );

  // Figma: teks 14, jarak antar-tab sekitar 40, garis biru di bawah tab aktif.
  Widget _tab(String category, {required bool isActive}) => InkWell(
    onTap: () => onSelected(category),
    child: Padding(
      padding: const EdgeInsets.only(right: 40),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.blue.withValues(alpha: 0.55) : null,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
