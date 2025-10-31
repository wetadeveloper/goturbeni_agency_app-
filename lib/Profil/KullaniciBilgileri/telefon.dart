import 'package:flutter/material.dart';

class TelefonNumarasi extends StatelessWidget {
  final TextEditingController telefonNumarasiController;

  const TelefonNumarasi({
    super.key,
    required this.telefonNumarasiController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: telefonNumarasiController,
      decoration: const InputDecoration(
        labelText: 'Telefon',
        hintText: '5*********',
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Lütfen telefon numaranızı girin.';
        }
        //Bu şimdilik kapalı olsun 10 haneli rakam zorunluluğu
        // else if (value.length != 10) {return 'Telefon numarası 10 haneli olmalıdır.';}
        else if (!RegExp(r'^\d+$').hasMatch(value)) {
          return 'Lütfen sadece rakam girin.';
        }
        return null;
      },
      keyboardType: TextInputType.phone,
    );
  }
}
