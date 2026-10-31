import 'package:flutter/material.dart';

import 'page_layout.dart';

// Figma Data Pesanan: judul kartu, lalu label tebal di atas setiap kolom.
class CustomerInformationForm extends StatelessWidget {
  const CustomerInformationForm({
    super.key,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.address,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController name, phone, address;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: SectionCard(
      children: [
        const Text(
          'Informasi Pemesan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        _label('Nama Lengkap'),
        TextFormField(
          controller: name,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(hintText: 'Nama pemesan'),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
        ),
        _label('Nomor WhatsApp'),
        TextFormField(
          controller: phone,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(hintText: '08xxxxxxxxxx'),
          validator: (value) =>
              RegExp(r'^(?:\+62|62|0)8[0-9]{7,11}$')
                  .hasMatch((value ?? '').replaceAll(RegExp(r'[\s-]'), ''))
              ? null
              : 'Masukkan nomor WhatsApp Indonesia yang valid',
        ),
        _label('Mau dikirim ke mana?'),
        TextFormField(
          controller: address,
          minLines: 2,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Contoh: Kamar 204, lantai 2 atau alamat lengkap',
          ),
          validator: (value) => (value ?? '').trim().isEmpty
              ? 'Lokasi pengantaran wajib diisi'
              : null,
        ),
      ],
    ),
  );
}
