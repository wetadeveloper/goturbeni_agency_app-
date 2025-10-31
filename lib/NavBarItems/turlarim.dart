import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gez_gor_saticii/NavBarItems/navbar.dart';
import 'package:gez_gor_saticii/Pages/Turlarim/tur_guncelleme_sayfasi.dart';
import 'package:gez_gor_saticii/Pages/Turlarim/tur_ekleme_sayfasi.dart';
import 'package:gez_gor_saticii/services/firebase_helper.dart';
import 'package:intl/intl.dart';

class Turlarim extends StatefulWidget {
  const Turlarim({Key? key}) : super(key: key);

  @override
  State<Turlarim> createState() => _TurlarimState();
}

class _TurlarimState extends State<Turlarim> {
  final user = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _turlarRefSubscription;

  @override
  void dispose() {
    _turlarRefSubscription?.cancel();
    super.dispose();
    _turlarRefSubscription = null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcı kontrolü ekle
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Turlarım"),
        ),
        body: const Center(
          child: Text('Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Turlarım"),
        ),
        bottomNavigationBar: const BottomNavBar(
          index: 1,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseHelper.getToursByAgency(user!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print("Hata: ${snapshot.error}");
              return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tour, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Henüz tur eklemediniz', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            final List<Widget> turWidgets = snapshot.data!.docs.map((DocumentSnapshot document) {
              final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return _buildTurWidget(data, document.id);
            }).toList();

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: turWidgets,
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TurEklemeSayfasi()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget get veriBulunamadiWidget => const Center(
        child: Text('Veri bulunamadı'),
      );

  Widget _buildTurWidget(Map<String, dynamic> data, String turID) {
    // Yeni yapı ile backward compatible veri okuma
    final String turAdi = FirebaseHelper.getTourTitle(data);
    final String acentaAdi = FirebaseHelper.getAgencyName(data);
    final double fiyat = FirebaseHelper.getTourPrice(data);
    final Timestamp? tarih = FirebaseHelper.getTourDate(data);
    final String yolculukTuru = FirebaseHelper.getTransportationType(data);
    final String category = FirebaseHelper.getTourCategory(data);

    final String kategoriAdi = FirebaseHelper.getCategoryDisplayName(category);
    final IconData kategoriIcon = _getKategoriIcon(category);

    DateTime dateTime = tarih?.toDate() ?? DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM');
    final String formattedDate = formatter.format(dateTime); // sadece gün ve ay bilgisi

    Widget getTravelIcon(String travelType) {
      // İngilizce tipleri Türkçe'ye çevir
      final turkishType = FirebaseHelper.convertTransportationTypeToTurkish(travelType);

      switch (turkishType) {
        case "Otobüs":
          return const Icon(FontAwesomeIcons.bus, color: Colors.white, size: 30);
        case "Uçak":
          return const Icon(FontAwesomeIcons.planeDeparture, color: Colors.white, size: 30);
        case "Tren":
          return const Icon(FontAwesomeIcons.trainTram, color: Colors.white, size: 33);
        default:
          return const Icon(FontAwesomeIcons.bus, color: Colors.white, size: 30);
      }
    }

    void _deleteTur(String turID) async {
      try {
        // Yeni yapıda tours collection'ından sil
        await FirebaseFirestore.instance.collection('tours').doc(turID).delete();
        if (mounted) {
          setState(() {});
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tur başarıyla silindi.'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print("$e");
      }
    }

    void _showDeleteConfirmationDialog(String turID) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tur Silme Onayı'),
            content: const Text('Bu turu silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                child: const Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Sil'),
                onPressed: () {
                  _deleteTur(turID);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Dismissible(
      key: Key(turID),
      onDismissed: (direction) {
        _showDeleteConfirmationDialog(turID);
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TurGuncellemeSayfasi(turID: turID)),
          );
        },
        child: Card(
          color: Colors.red.shade900,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getTravelIcon(yolculukTuru),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: Text(
                        turAdi,
                        style: const TextStyle(
                            fontSize: 17, fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  acentaAdi,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Tarih: ",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Center(
                      child: Row(
                        children: [
                          Icon(
                            kategoriIcon,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            kategoriAdi,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${fiyat.toStringAsFixed(0)} TL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getKategoriIcon(String category) {
    switch (category) {
      case 'popular':
        return FontAwesomeIcons.solidStar;
      case 'europe':
        return FontAwesomeIcons.earthEurope;
      case 'sea_vacation':
        return FontAwesomeIcons.umbrellaBeach;
      case 'black_sea':
        return FontAwesomeIcons.tree;
      case 'anatolia':
        return FontAwesomeIcons.mountain;
      case 'religious':
        return FontAwesomeIcons.mosque;
      case 'gastronomy':
        return FontAwesomeIcons.utensils;
      case 'yacht':
        return FontAwesomeIcons.ship;
      case 'health':
        return FontAwesomeIcons.heartPulse;
      default:
        return Icons.category;
    }
  }
}
