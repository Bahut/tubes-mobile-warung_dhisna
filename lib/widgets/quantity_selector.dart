import 'package:flutter/material.dart';

// Figma: ikon lingkaran (−) dan (+) hitam dengan angka di tengah.
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.minimum = 0,
    this.iconSize = 22,
  });
  final int value, minimum;
  final double iconSize;
  final ValueChanged<int> onChanged;

  Widget _button(String tooltip, IconData icon, VoidCallback? onPressed) =>
      IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
        color: Colors.black,
        padding: EdgeInsets.zero,
        // Area sentuh minimal 38px walau ikon kecil.
        constraints: BoxConstraints.tight(Size.square(iconSize + 16)),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _button(
        'Kurangi jumlah',
        Icons.remove_circle_outline,
        value > minimum ? () => onChanged(value - 1) : null,
      ),
      SizedBox(
        width: 24,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      _button(
        'Tambah jumlah',
        Icons.add_circle_outline,
        () => onChanged(value + 1),
      ),
    ],
  );
}
