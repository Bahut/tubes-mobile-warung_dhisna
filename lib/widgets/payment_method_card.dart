import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../theme/app_colors.dart';

// Pilihan cara bayar sesuai Figma: ikon centang, judul, label kecil, keterangan.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isQris = method == PaymentMethod.qris;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: selected ? const Color(0xFFEBF5F9) : const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? AppColors.blue : const Color(0xFFEEEEEE),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 22,
                  color: selected ? AppColors.blue : const Color(0xFF6B7273),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isQris ? 'QRIS' : 'Tunai di Tempat',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            color: const Color(0xFFE5F0F4),
                            child: Text(
                              isQris ? 'Instan' : 'Di Tempat',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isQris
                            ? 'Bayar lewat aplikasi m-banking atau e-wallet '
                                  'yang mendukung QRIS.'
                            : 'Bayar langsung secara tunai kepada staf '
                                  'pengantar saat makanan disajikan.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF6B7273),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
