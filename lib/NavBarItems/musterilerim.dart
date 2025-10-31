import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gez_gor_saticii/Pages/Musterilerim/turu_alan_musteriler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:gez_gor_saticii/NavBarItems/navbar.dart';

class MusterilerSayfasi extends StatefulWidget {
  const MusterilerSayfasi({Key? key}) : super(key: key);

  @override
  MusterilerSayfasiState createState() => MusterilerSayfasiState();
}

class MusterilerSayfasiState extends State<MusterilerSayfasi> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late DateTime currentDate;
  late String? userId;
  late String? acentaId;
  late String turTarihi = 'Tarih hatası';
  List<Map<String, dynamic>> satilanTurlar = [];

  Map<String, String> turKoleksiyonIsimleri = {
    'populer_turlar': 'Populer Turlar',
    'avrupa_turlari': 'Avrupa Turları',
    'deniz_tatilleri': 'Deniz Tatilleri',
    'karadeniz_turlari': 'Karadeniz Turları',
    'anadolu_turlari': 'Anadolu Turları',
    'hac_umre_turlari': 'Hac&Umre Turları',
    'gastronomi_turlari': 'Gastronomi Turları',
    'yatvetekne_turlari': 'Yat & Tekne Turları',
    'saglik_turlari': 'Sağlık Turları'
  };

  Future<String?> getCurrentUserId() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      this.userId = userId;
      return userId;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    initializeDateFormatting('tr_TR');
    fetchSatilanTurlar(); // StreamBuilder'ı kullanmadan önce verileri çek
  }

  Future<void> initializeData() async {
    userId = await getCurrentUserId();
    currentDate = DateTime.now();
    acentaId = userId;
  }

  void _fillTurData(String turID) async {
    try {
      Map<String, dynamic>? turData;
      for (var koleksiyon in turKoleksiyonIsimleri.keys) {
        DocumentSnapshot turSnapshot = await FirebaseFirestore.instance.collection(koleksiyon).doc(turID).get();
        if (turSnapshot.exists) {
          turData = turSnapshot.data() as Map<String, dynamic>;

          setState(() {
            DateTime tarihDateTime = (turData?['tarih'] as Timestamp?)?.toDate() ?? DateTime.now();
            turTarihi = DateFormat.yMMMMd('tr_TR').format(tarihDateTime);
          });
          break; // Koleksiyon bulunduğunda döngüden çık
        }
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> fetchSatilanTurlar() async {
    try {
      userId = await getCurrentUserId();
      currentDate = DateTime.now();
      acentaId = userId;

      // StreamBuilder'ın yapacağı işi burada yap
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Stream<QuerySnapshot> queryStream = firestore.collection('users').snapshots();

      queryStream.listen((usersQuerySnapshot) async {
        satilanTurlar = [];

        for (var userDoc in usersQuerySnapshot.docs) {
          CollectionReference collectionRef = userDoc.reference.collection('turSatinAlanKisiler');

          QuerySnapshot querySnapshot = await collectionRef.orderBy('tarih', descending: true).get();

          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> turData = doc.data() as Map<String, dynamic>;

            if (turData['acenta_id'] == acentaId) {
              final turID = turData['turID'];

              bool found = false;
              for (var i = 0; i < satilanTurlar.length; i++) {
                if (satilanTurlar[i]['turID'] == turID) {
                  satilanTurlar[i]['kisiSayisi'] += turData['kisiSayisi'];
                  found = true;
                  break;
                }
              }
              if (!found) {
                // Sadece odemeDurumu true olanları ekleyin
                if (turData['odemeDurumu'] == true) {
                  satilanTurlar.add(turData);
                }
              }
            }
          }
        }

        // setState ile yeniden çizimi tetikleme
        setState(() {});
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> listenToSatilanTurlar() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> queryStream = firestore.collection('users').snapshots();

    return queryStream.asyncMap((usersQuerySnapshot) async {
      List<Map<String, dynamic>> satilanTurlar = [];

      for (var userDoc in usersQuerySnapshot.docs) {
        CollectionReference collectionRef = userDoc.reference.collection('turSatinAlanKisiler');

        QuerySnapshot querySnapshot = await collectionRef.orderBy('tarih', descending: true).get();

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> turData = doc.data() as Map<String, dynamic>;

          if (turData['acenta_id'] == acentaId) {
            final turID = turData['turID'];

            bool found = false;
            for (var i = 0; i < satilanTurlar.length; i++) {
              if (satilanTurlar[i]['turID'] == turID) {
                satilanTurlar[i]['kisiSayisi'] += turData['kisiSayisi'];
                found = true;
                break;
              }
            }
            if (!found) {
              // Sadece odemeDurumu true olanları ekleyin
              if (turData['odemeDurumu'] == true) {
                satilanTurlar.add(turData);
              }
            }
          }
        }
      }

      return satilanTurlar;
    });
  }

  Widget buildSatilanTurlarList() {
    if (satilanTurlar.isEmpty) {
      return const Center(
        child: Text('Henüz müşteri yok.'),
      );
    }

    return ListView(
      children: satilanTurlar.map((turData) {
        final turAdi = turData['turAdi'];
        final int kisiSayisi = turData['kisiSayisi'];
        final String turID = turData['turID'];
        _fillTurData(turID);

        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tur: " + (turAdi.length > 20 ? turAdi.substring(0, 17) + "..." : turAdi),
              ),
              Text(
                "Tur Tarihi: $turTarihi",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          subtitle: Text('Kişi Sayısı: ${kisiSayisi.toString()}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TuruAlanMusteriler(
                  turData: turData,
                  turID: turData['turID'],
                ),
              ),
            ).then((_) {
              setState(() {
                // satilanTurlar listesini güncelleme seçeneğiniz varsa burada yapabilirsiniz.
              });
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Müşteriler'),
          ),
          body: buildSatilanTurlarList(),
          bottomNavigationBar: const BottomNavBar(
            index: 2,
          ),
        ),
      ),
    );
  }
}
