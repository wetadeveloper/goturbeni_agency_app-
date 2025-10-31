import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gez_gor_saticii/services/firebase_helper.dart';
import 'KullaniciBilgileri/sehir.dart';
import 'KullaniciBilgileri/tckimlik.dart';
import 'KullaniciBilgileri/telefon.dart';
import 'package:http/http.dart' as http;

class KullaniciBilgileri extends StatefulWidget {
  const KullaniciBilgileri({super.key});

  @override
  KullaniciBilgileriState createState() => KullaniciBilgileriState();
}

class KullaniciBilgileriState extends State<KullaniciBilgileri> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _tcKimlikNumarasiController = TextEditingController();
  final TextEditingController _telefonNumarasiController = TextEditingController();
  final TextEditingController _acenteSloganiController = TextEditingController();

  String selectedCity = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _userNameController.text = user != null ? user.displayName ?? "" : "Acente Ismi";
    _userEmailController.text = user != null ? user.email ?? "" : "acente@goturbeni.com";
    _getTotal();
  }

  Future<void> _saveUserInformation() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(_userNameController.text);

      // Email sadece değişmişse güncelle (hassas işlem olduğu için)
      if (user.email != _userEmailController.text) {
        try {
          await user.verifyBeforeUpdateEmail(_userEmailController.text);
        } catch (e) {
          // Eğer yeniden giriş gerekiyorsa, kullanıcıyı bilgilendir
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email güncellemesi için lütfen çıkış yapıp tekrar giriş yapın.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          // Email güncellemesi başarısız olsa bile diğer bilgileri kaydet
          print('Email güncelleme hatası: $e');
        }
      }

      String userIPAddress = await getUserIPAddress();

      // YENİ YAPI: user_info/acente_bilgileri
      final acenteBilgileriRef = FirebaseHelper.getAgencyInfoDocument(user.uid);
      await acenteBilgileriRef.set({
        'acente_adi': _userNameController.text,
        'email': _userEmailController.text,
        'acente_slogani': _acenteSloganiController.text,
        'sehir': selectedCity,
        'telefonNumarasi': _telefonNumarasiController.text,
        'tcKimlik': _tcKimlikNumarasiController.text,
        'sonGuncelleme': _lastUpdate,
        'ipAdresi': userIPAddress,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _lastUpdate = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilgileriniz başarıyla kaydedildi.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _getTotal() async {
    final user = _auth.currentUser;
    if (user != null) {
      // YENİ YAPI: user_info/acente_bilgileri
      final docSnapshot = await FirebaseHelper.getAgencyInfoDocument(user.uid).get();
      final data = docSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          _userNameController.text = data['acente_adi'] ?? '';
          selectedCity = data['sehir'] ?? '';
          _telefonNumarasiController.text = data['telefonNumarasi'] ?? '';
          _tcKimlikNumarasiController.text = data['tcKimlik'] ?? '';
          _acenteSloganiController.text = data['acente_slogani'] ?? '';
          _lastUpdate = data['sonGuncelleme']?.toDate() ?? DateTime.now();
        });
      }
    }
  }

  Future<String> getUserIPAddress() async {
    final response = await http.get(Uri.parse('https://api.ipify.org/?format=json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final ipAddress = data['ip'];
      return ipAddress;
    } else {
      throw Exception('Failed to get user IP address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Bilgileri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveUserInformation();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'Acente İsmi ',
                  hintText: "Acente İsmi Giriniz",
                ),
              ),
              TextField(
                controller: _acenteSloganiController,
                decoration: const InputDecoration(
                  labelText: 'Acente Sloganı ',
                  hintText: "Acentenizin Sloganını Giriniz",
                ),
              ),
              TextField(
                controller: _userEmailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                ),
                enabled: false,
              ),
              SizedBox(height: 16.0),
              SehirSecimi(
                selectedCity: selectedCity,
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TcKimlikNumarasi(
                tcKimlikNumarasiController: _tcKimlikNumarasiController,
              ),
              const SizedBox(height: 16.0),
              TelefonNumarasi(
                telefonNumarasiController: _telefonNumarasiController,
              ),

              // BURADA SİFRE DEĞİŞTİRME İŞLEMİ YAPACAGIM //

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveUserInformation,
                child: const Text('Bilgileri Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
