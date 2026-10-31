import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'formatters.dart';

// Figma: bar 300 x 60 di tengah, kiri putih (ikon keranjang + badge),
// kanan biru (total dan tombol PESAN).
class CartFloatingBar extends StatelessWidget {
  const CartFloatingBar({
    super.key,
    required this.quantity,
    required this.total,
    required this.onTap,
  });
  final int quantity, total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
    heightFactor: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, minHeight: 60),
        child: Material(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shadowColor: const Color(0x40000000),
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 71,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.blue),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_basket_outlined,
                          color: AppColors.blue,
                          size: 22,
                        ),
                        Positioned(top: 0, right: 0, child: _Badge(quantity)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(9, 8, 14, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  rupiah(total),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'PESAN ($quantity)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.quantity);
  final int quantity;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
    padding: const EdgeInsets.symmetric(horizontal: 3),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '$quantity',
      style: const TextStyle(fontSize: 9, color: Colors.white),
    ),
  );
}
