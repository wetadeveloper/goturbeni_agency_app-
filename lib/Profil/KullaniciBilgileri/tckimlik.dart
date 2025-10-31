import 'package:flutter/material.dart';

class TcKimlikNumarasi extends StatelessWidget {
  final TextEditingController tcKimlikNumarasiController;

  const TcKimlikNumarasi({
    super.key,
    required this.tcKimlikNumarasiController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: tcKimlikNumarasiController,
      decoration: const InputDecoration(
        labelText: 'TC Kimlik Numarası',
      ),
    );
  }
}
