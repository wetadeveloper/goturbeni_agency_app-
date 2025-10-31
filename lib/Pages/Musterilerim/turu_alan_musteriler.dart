import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TuruAlanMusteriler extends StatefulWidget {
  final Map<String, dynamic> turData;
  final String turID;

  TuruAlanMusteriler({super.key, required this.turData, required this.turID}) {
    initializeDateFormatting('tr_TR');
  }

  @override
  TuruAlanMusterilerState createState() => TuruAlanMusterilerState();
}

class TuruAlanMusterilerState extends State<TuruAlanMusteriler> {
  late List<Map<String, dynamic>> musteriler = [];
  double toplamFiyat = 0;
  int kapasite = 0;
  late String formattedDate = 'Tarih hatası';

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

  @override
  void initState() {
    super.initState();
    _getMusteriler();
    _fillTurData();
  }

  void _fillTurData() async {
    try {
      Map<String, dynamic>? turData;
      for (var koleksiyon in turKoleksiyonIsimleri.keys) {
        DocumentSnapshot turSnapshot = await FirebaseFirestore.instance.collection(koleksiyon).doc(widget.turID).get();
        if (turSnapshot.exists) {
          turData = turSnapshot.data() as Map<String, dynamic>;

          setState(() {
            DateTime tarihDateTime = (turData?['tarih'] as Timestamp?)?.toDate() ?? DateTime.now();
            formattedDate = DateFormat.yMMMMd('tr_TR').format(tarihDateTime);
            kapasite = turData?['kapasite'] ?? 0;
          });
          break; // Koleksiyon bulunduğunda döngüden çık
        }
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _getMusteriler() async {
    try {
      Stream<QuerySnapshot> combinedStream = FirebaseFirestore.instance
          .collectionGroup('turSatinAlanKisiler')
          .where('turID', isEqualTo: widget.turData['turID'])
          .where('odemeDurumu', isEqualTo: true)
          .snapshots();

      combinedStream.listen((querySnapshot) {
        List<Map<String, dynamic>> allMusteriler = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['doc_id'] = doc.id; // Döküman ID'sini verilere ekleyelim
          allMusteriler.add(data);
        }

        setState(() {
          musteriler = allMusteriler;
          toplamFiyat = _calculateToplamFiyat(musteriler);
        });
      });
    } catch (error) {
      print('Hata: $error');
    }
  }

  double _calculateToplamFiyat(List<Map<String, dynamic>> musteriler) {
    double toplam = 0.0;
    for (var musteri in musteriler) {
      double fiyat = musteri['fiyat'] ?? 0;
      toplam += fiyat;
    }
    return toplam;
  }

  @override
  Widget build(BuildContext context) {
    final int kisiSayisi = widget.turData['kisiSayisi'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turData['turAdi'] ?? ''),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Toplam Kişi Sayısı: $kisiSayisi',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Kalın yazı stili
                    fontSize: 18, // Font büyüklüğü
                  ),
                ),
                const SizedBox(height: 5), // Boşluk
                Text(
                  'Turun Tarihi: $formattedDate',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5), // Boşluk
                Text(
                  'Toplam Fiyat: ${toplamFiyat.toString()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5), // Boşluk
                Text(
                  'Kalan Kapasite: ${kapasite.toString()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Column(
              children: [
                Text(
                  'Kişi Bilgileri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: musteriler.length,
              itemBuilder: (context, index) {
                final kisi = musteriler[index];
                List<dynamic> kisilerBilgileriList = kisi['kisiBilgileri'];

                return Column(
                  children: kisilerBilgileriList.map((kisiBilgileri) {
                    String ad = kisiBilgileri['ad'] ?? '';
                    String soyad = kisiBilgileri['soyad'] ?? '';
                    String yas = kisiBilgileri['yas'] ?? '';
                    String tcKimlik = kisiBilgileri['tcKimlik'] ?? '';
                    String telefon = kisiBilgileri['telefon'] ?? '';
                    String cinsiyet = kisiBilgileri['cinsiyet'] ?? '';
                    String odemeSecenegi = kisi['odemeSecenegi'] ?? '';
                    double odemeFiyati = kisi['fiyat'] ?? 0;
                    int kisiSayisi = kisi['kisiSayisi'] ?? 0;
                    Timestamp odemeTarihiTimestamp = kisi['odemeTarihi'];
                    DateTime odemeTarihi = odemeTarihiTimestamp.toDate();
                    bool odemeDurumu = kisi['odemeDurumu'] ?? 'ODEME ETKİN DEĞİL';
                    bool turIptali = kisi['kullanıcıTurIptali'];
                    Timestamp turTarihiTimeStamp = kisi['odemeTarihi'];
                    DateTime turTarihi = turTarihiTimeStamp.toDate();
                    String formattedTurTarihi = DateFormat.yMMMMd('tr_TR').add_Hm().format(turTarihi);
                    bool hediyeKuponuKullanimi = kisi['HediyeKuponuKullanimi'] ?? false;
                    int indirimMiktari = kisi['indirimMiktari'] ?? 0;

                    String formattedOdemeTarihi = DateFormat.yMMMMd('tr_TR').add_Hm().format(odemeTarihi);

                    return Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            if (turIptali == true)
                              const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 0,
                                        maxWidth: MediaQuery.of(context).size.width * 0.3,
                                      ),
                                      child: Text(
                                        'Ad: $ad',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Tarih: $formattedTurTarihi",
                                    style: const TextStyle(fontSize: 13),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Soyad: $soyad'),
                            Text('Yaş: $yas'),
                            Text('TC Kimlik: $tcKimlik'),
                            Text('Telefon: $telefon'),
                            Text('Ödeme Seçeneği: $odemeSecenegi'),
                            Text('Fiyat: $odemeFiyati'),
                            Text('Cinsiyet: $cinsiyet'),
                            Text('Kişi Sayısı: $kisiSayisi'),
                            Text('Odeme Durumu: ${odemeDurumu ? "Etkin" : "Etkin Değil"}'),
                            Text('Odeme Tarihi: $formattedOdemeTarihi'),
                            if (hediyeKuponuKullanimi == true)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hediye Kuponu Kullanımı: ${hediyeKuponuKullanimi ? "Etkin" : "Etkin Değil"}',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  Text('İndirim Miktarı: $indirimMiktari'),
                                ],
                              ),
                            if (turIptali == true)
                              const Row(
                                children: [
                                  Icon(
                                    Icons.warning, // Uyarı simgesi
                                    color: Colors.red, // Kırmızı renk
                                  ),
                                  SizedBox(width: 5), // Simge ile metin arasında boşluk
                                  Text(
                                    'Kullanıcı Turu İptal etti',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
