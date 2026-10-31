import 'package:flutter/material.dart';

import 'formatters.dart';
import 'page_layout.dart';

// Bar bawah sesuai Figma: panel putih bersudut bulat dengan
// "Total Biaya" di kiri dan tombol biru di kanan.
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({
    super.key,
    required this.total,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.totalLabel = 'Total Biaya',
  });
  final int total;
  final String label, totalLabel;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => BottomPanel(
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(totalLabel, style: const TextStyle(fontSize: 13)),
              Text(
                rupiah(total),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size(150, 44),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      ],
    ),
  );
}
