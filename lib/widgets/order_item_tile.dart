import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../theme/app_colors.dart';
import 'formatters.dart';

// Baris pesanan sesuai Figma Ringkasan: "1×", nama, harga tebal,
// lalu catatan pelanggan (jika ada) di kotak abu-abu.
class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item, this.received = false});
  final CartItemModel item;
  // true di tracking saat pesanan tiba: tampilkan centang biru.
  final bool received;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (received) ...[
          const Icon(Icons.check_circle, size: 18, color: AppColors.blue),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 26,
          child: Text(
            '${item.quantity}×',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7273)),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.food.name, style: const TextStyle(fontSize: 14)),
              for (final option in item.food.options.where(
                (option) => (item.options[option.id] ?? 0) > 0,
              ))
                Text(
                  '${item.options[option.id]}× ${option.name}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              // Hanya catatan dari pelanggan, bukan deskripsi produk.
              if (item.note.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Catatan: ${item.note}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rupiah(item.total),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
