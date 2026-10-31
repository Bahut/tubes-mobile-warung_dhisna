import 'package:flutter/material.dart';

// Figma Edit Makanan: label "Catatan" di atas kotak setinggi 127.
class FoodNoteField extends StatelessWidget {
  const FoodNoteField({super.key, required this.controller});
  final TextEditingController controller;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: const Text('Catatan', style: TextStyle(fontSize: 13)),
      ),
      DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: 127,
          child: TextField(
            controller: controller,
            expands: true,
            maxLines: null,
            maxLength: 300,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Contoh: pedas sedang, acar dipisah',
              hintStyle: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
              counterText: '',
              contentPadding: EdgeInsets.all(8),
              border: _border,
              enabledBorder: _border,
            ),
          ),
        ),
      ),
    ],
  );
}
