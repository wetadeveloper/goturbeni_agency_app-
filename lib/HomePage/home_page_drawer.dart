import 'package:flutter/material.dart';
import 'package:gez_gor_saticii/Pages/Turlarim/tur_ekleme_sayfasi.dart';

class DrawerSayfasi extends StatefulWidget {
  const DrawerSayfasi({Key? key}) : super(key: key);

  @override
  State<DrawerSayfasi> createState() => _DrawerSayfasiState();
}

class _DrawerSayfasiState extends State<DrawerSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          ListTile(
            title: const Text("Tur Ekle"),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TurEklemeSayfasi()));
            },
          ),
          ListTile(
            title: const Text("Tur Sil"),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            onTap: () {
              //    Navigator.push(context, MaterialPageRoute(builder:(context)=> TurSilSayfasi()));
            },
          ),
        ],
      ),
    );
  }
}
