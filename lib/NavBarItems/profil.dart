import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gez_gor_saticii/Giris/login.dart';
import 'package:gez_gor_saticii/Giris/testlogin.dart';
import 'package:gez_gor_saticii/NavBarItems/navbar.dart';
import 'package:gez_gor_saticii/Profil/kullanici_bilgileri.dart';
import 'package:image_picker/image_picker.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  ProfilState createState() => ProfilState();
}

class ProfilState extends State<Profil> {
  File? _image;
  ImageProvider<Object>? _profileAvatar;
  final _storage = FirebaseStorage.instance;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _uploadProfileImage(); // Profil fotoğrafını yükle ve güncelle
      }
    } catch (e) {
      print('Fotograf yuklenirken hata: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_image == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user != null ? user.uid : '';

    if (userId.isNotEmpty) {
      final ref = _storage.ref().child('profil_fotograflari').child('$userId.jpg');

      try {
        final uploadTask = ref.putFile(_image!);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await snapshot.ref.getDownloadURL();

        setState(() {
          _profileAvatar = Image.network(downloadURL).image;
        });
        print('Profil fotoğrafı yüklendi.');
      } catch (e) {
        print('Profil fotoğrafı yüklenirken hata: $e');
      }
    }
  }

  Future<ImageProvider<Object>> _buildProfileAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user != null ? user.uid : '';

    if (_image != null) {
      // Kullanıcının seçtiği profil fotoğrafı varsa
      return FileImage(_image!);
    } else if (userId.isNotEmpty) {
      // Firebase Storage'dan kullanıcının profil fotoğrafını al
      final storageRef = FirebaseStorage.instance.ref().child('/profil_fotograflari').child('$userId.jpg');

      try {
        final downloadURL = await storageRef.getDownloadURL();
        return NetworkImage(downloadURL);
      } catch (e) {
        print('Profil fotoğrafı alınırken hata: $e');
      }
    }
    return const AssetImage('assets/user.jpeg'); // Varsayılan avatar
  }

  Future<void> _loadProfileAvatar() async {
    final profileAvatar = await _buildProfileAvatar();
    setState(() {
      _profileAvatar = profileAvatar;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfileAvatar();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user != null ? user.displayName : "Furkan Pala";
    final userEmail = user != null ? user.email : "admin@gezgor.com";

    return PopScope(
      canPop: false,
      child: MaterialApp(
        home: Scaffold(
          bottomNavigationBar: const BottomNavBar(
            index: 3,
          ),
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 55.0,
                          ),
                          InkWell(
                            onTap: _getImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey, // Arka plan rengi
                                image: DecorationImage(
                                  image: _profileAvatar ?? const AssetImage('assets/user.jpeg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            userName ?? "Kullanıcı Adı",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            userEmail ?? "E-posta Adresi",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Text(
                            'GezGör',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white60,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 1.0,
                          offset: const Offset(1.0, 2.0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Kullanıcı Bilgileri'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => KullaniciBilgileri()));
                          },
                        ),

                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.call),
                          title: const Text('Canlı Destek'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            //  Navigator.push(context, MaterialPageRoute(builder: (context) => CanliDestek()),);
                          },
                        ),
                        const Divider(),
                        //AYARLAR
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Ayarlar'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            //   Navigator.push(context,MaterialPageRoute(builder: (context) => Ayarlar()));
                          },
                        ),
                        const Divider(),
                        //ÇIKIŞ YAP
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Çıkış Yap'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            // Show "Are you sure?" dialog
                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Çıkış yap'),
                                  content: const Text('Emin misiniz?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Hayır'),
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Evet'),
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const TestLoginSayfasi(),
                                          ),
                                          (route) => false, // Remove all routes
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            // If user confirmed, sign out
                            if (confirm) {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginSayfasi(),
                                ),
                                (route) => false, // Remove all routes
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
