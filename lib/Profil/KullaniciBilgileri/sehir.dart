import 'package:flutter/material.dart';

class SehirSecimi extends StatelessWidget {
  final String selectedCity;
  final Function(String) onChanged;

  const SehirSecimi({
    super.key,
    required this.selectedCity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Yaşadığınız Şehir",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: selectedCity,
          onChanged: (String? newValue) => onChanged(newValue!),
          items: const [
            DropdownMenuItem(
              value: '', // Tüm şehirler için boş değer
              child: Text('Belirsiz'),
            ),
            DropdownMenuItem(
              value: 'İstanbul',
              child: Text('İstanbul'),
            ),
            DropdownMenuItem(
              value: 'Ankara',
              child: Text('Ankara'),
            ),
            DropdownMenuItem(
              value: 'Konya',
              child: Text('Konya'),
            ),
          ],
        ),
      ],
    );
  }
}
