import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gez_gor_saticii/NavBarItems/musterilerim.dart';

class SatilanTurlar extends StatefulWidget {
  const SatilanTurlar({Key? key}) : super(key: key);

  @override
  State<SatilanTurlar> createState() => _SatilanTurlarState();
}

class _SatilanTurlarState extends State<SatilanTurlar> {
  List<Musteri> musteriler = [];
  late String? userId;
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    initUserId();
  }

  Future<void> initUserId() async {
    userId = await getCurrentUserId();
    if (userId != null) {
      await getMusteriler();
    }
  }

  Future<void> getMusteriler() async {
    try {
      if (userId == null) {
        print("Kullanıcı oturumu açmamış");
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // YENİ YAPI: collectionGroup ile tüm kullanıcıların reservations'larını çek
      QuerySnapshot reservationsSnapshot = await firestore
          .collectionGroup('reservations')
          .where('companyId', isEqualTo: userId) // Sadece bu acentenin turları
          .where('paymentStatus', isEqualTo: 'completed') // Sadece ödeme yapılmış olanlar
          .orderBy('reservationDate', descending: true)
          .get();

      List<Musteri> updatedMusteriler = [];

      for (var doc in reservationsSnapshot.docs) {
        try {
          Map<String, dynamic> reservationData = doc.data() as Map<String, dynamic>;

          // Passengers array'inden ilk yolcunun adını al
          List<dynamic>? passengers = reservationData['passengers'];
          String ad = '';
          if (passengers != null && passengers.isNotEmpty) {
            ad = passengers[0]['name'] ?? '';
          }

          // Tur adı
          String tur = reservationData['tourTitle'] ?? '';

          // Tur tarihi
          Timestamp? tourDateTimestamp = reservationData['tourStartDate'];
          if (tourDateTimestamp == null) continue;

          DateTime tarih = tourDateTimestamp.toDate();

          // Ödeme durumu
          String paymentStatus = reservationData['paymentStatus'] ?? '';
          bool odemeDurumu = paymentStatus == 'completed';

          // Şu andan bir gün sonraki tarihlere kadar olanları listele
          if (odemeDurumu && ad.isNotEmpty && tur.isNotEmpty) {
            Musteri musteri = Musteri(
              ad: ad,
              tur: tur,
              tarih: tarih,
              odemeDurumu: odemeDurumu,
            );
            updatedMusteriler.add(musteri);
          }
        } catch (e) {
          print('Rezervasyon işleme hatası: $e');
          continue;
        }
      }

      setState(() {
        musteriler = updatedMusteriler;
      });
    } catch (e) {
      print('Firestore veri çekme hatası: $e');
    }
  }

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
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Son Müşterilerim',
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
                      builder: (context) => const MusterilerSayfasi(),
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
          const SizedBox(height: 10),
          musteriler.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Henüz müşteri yok.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Ad',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Tur',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: musteriler
                        .take(5)
                        .map(
                          (musteri) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(musteri.ad)),
                              DataCell(Text(
                                musteri.tur.length > 20 ? '${musteri.tur.substring(0, 20)}...' : musteri.tur,
                              )),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }
}

class Musteri {
  final String ad;
  final String tur;
  final DateTime tarih;
  final bool odemeDurumu;

  Musteri({required this.ad, required this.tur, required this.tarih, required this.odemeDurumu});
}
