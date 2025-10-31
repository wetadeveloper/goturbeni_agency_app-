import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gez_gor_saticii/NavBarItems/turlarim.dart';
import 'package:gez_gor_saticii/services/firebase_helper.dart';

class HomePageAksiyonlar extends StatefulWidget {
  const HomePageAksiyonlar({Key? key}) : super(key: key);

  @override
  State<HomePageAksiyonlar> createState() => _HomePageAksiyonlarState();
}

class _HomePageAksiyonlarState extends State<HomePageAksiyonlar> {
  List<String> yaklasanTurlar = [];
  List<String> gecmisTurlar = [];
  StreamSubscription<QuerySnapshot>? _yaklasanTurlarRefSubscription;
  StreamSubscription<QuerySnapshot>? _gecmisTurlarRefSubscription;

  @override
  void initState() {
    super.initState();
    _fetchYaklasanTurlar();
    _fetchGecmisTurlar();
  }

  @override
  void dispose() {
    _yaklasanTurlarRefSubscription?.cancel();
    _gecmisTurlarRefSubscription?.cancel();
    super.dispose();
  }

  void _fetchYaklasanTurlar() {
    final user = FirebaseAuth.instance.currentUser;

    // Kullanıcı yoksa boş liste döndür
    if (user == null) {
      setState(() {
        yaklasanTurlar = [];
      });
      return;
    }

    // Yeni yapıda tek bir query ile yaklaşan turları çek
    final updatedTurlarRef = FirebaseHelper.getUpcomingTours(user.uid).snapshots();

    _yaklasanTurlarRefSubscription = updatedTurlarRef.listen((snapshot) {
      setState(() {
        yaklasanTurlar = snapshot.docs.map((document) => _calculateRemainingDays(document)).toList();
      });
    });
  }

  void _fetchGecmisTurlar() {
    final user = FirebaseAuth.instance.currentUser;

    // Kullanıcı yoksa boş liste döndür
    if (user == null) {
      setState(() {
        gecmisTurlar = [];
      });
      return;
    }

    // Yeni yapıda tek bir query ile geçmiş turları çek
    final updatedTurlarRef = FirebaseHelper.getPastTours(user.uid).snapshots();

    _gecmisTurlarRefSubscription = updatedTurlarRef.listen((snapshot) {
      setState(() {
        gecmisTurlar = snapshot.docs.map((document) => _calculateElapsedDays(document)).toList();
      });
    });
  }

  String _calculateRemainingDays(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;
    if (data == null) return '';

    final turTarihi = FirebaseHelper.getTourDate(data);
    final turAdi = FirebaseHelper.getTourTitle(data);

    if (turTarihi == null) {
      return '';
    }

    final now = DateTime.now();
    final startDate = turTarihi.toDate();
    final difference = startDate.difference(now).inDays;

    if (difference >= 0) {
      return '$turAdi (Kalan Gün: $difference)';
    } else {
      return '';
    }
  }

  String _calculateElapsedDays(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;
    if (data == null) return '';

    final turTarihi = FirebaseHelper.getTourDate(data);
    final turAdi = FirebaseHelper.getTourTitle(data);

    if (turTarihi == null) {
      return '';
    }

    final now = DateTime.now();
    final startDate = turTarihi.toDate();
    final difference = now.difference(startDate).inDays;

    if (difference > 0) {
      return '$turAdi (Geçen Gün: $difference)';
    } else if (difference == 0) {
      return '$turAdi (Bugün)';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.23,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Turlarım',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Turlarim(),
                      ),
                    );
                  },
                  child: const Text(
                    'Hepsini Göster',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Yaklaşan Turlarım ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                )
                // SONRA BELKİ AÇARIZ
                /*     Container(
                  child: Text(
                    'Geçmiş Turlarım',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ), */
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: yaklasanTurlar.length > 5 ? 5 : yaklasanTurlar.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5.0),
              itemBuilder: (context, index) {
                final tur = yaklasanTurlar[index];
                return Text(
                  tur,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red.shade900),
                );
              },
            )),
            const SizedBox(
              height: 10,
            ),
            /*   Container(
                child: Expanded(
                    child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: gecmisTurlar
                  .take(5)
                  .map(
                    (tur) => Text(
                      tur,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  )
                  .toList(),
            ))), */
          ],
        ),
      ),
    );
  }
}
