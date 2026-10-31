import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Ukuran mengikuti Figma Beranda: foto 178, card nama 72, label jam 41.
class RestaurantHeader extends StatelessWidget {
  const RestaurantHeader({super.key, required this.onSearch});
  final VoidCallback onSearch;

  Widget _circleButton(IconData icon, String tooltip, VoidCallback onTap) =>
      IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: Colors.black),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFD9D9D9),
          fixedSize: const Size(30, 30),
          minimumSize: const Size(30, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/restaurant/header.png',
              height: 178,
              width: double.infinity,
              fit: BoxFit.cover,
              // Foto gedung tegak; geser ke atas agar tulisan Rumah Dhiesna terlihat.
              alignment: const Alignment(0, -0.8),
            ),
          ),
          Positioned(
            top: 14,
            right: 8,
            child: _circleButton(Icons.search, 'Cari makanan', onSearch),
          ),
        ],
      ),
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 72),
        margin: const EdgeInsets.fromLTRB(19, 18, 19, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: const Text(
          'Warung Ibu Kost Dhiesna',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ),
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 41),
        margin: const EdgeInsets.fromLTRB(21, 17, 21, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Buka 08.00–21.00',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}
