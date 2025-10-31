import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';
import 'package:gez_gor_saticii/services/firebase_helper.dart';

class TurGuncellemeSayfasi extends StatefulWidget {
  final String turID;

  const TurGuncellemeSayfasi({Key? key, required this.turID}) : super(key: key);

  @override
  TurGuncellemeSayfasiState createState() => TurGuncellemeSayfasiState();
}

class TurGuncellemeSayfasiState extends State<TurGuncellemeSayfasi> {
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController turAdiController = TextEditingController();
  final TextEditingController acentaAdiController = TextEditingController();
  final TextEditingController fiyatController = TextEditingController();
  final TextEditingController tarihController = TextEditingController();
  final TextEditingController turSuresiController = TextEditingController();
  final TextEditingController kapasiteController = TextEditingController();
  late TextEditingController acenteID = TextEditingController();

  List<TextEditingController> turDetaylariControllers = [];
  List<TextEditingController> fiyataDahilHizmetlerControllers = [];
  List<TextEditingController> otobusDuraklariControllers = [];

  String? selectedYolculukTuru;
  String? selectedTurSuresi;
  String? selectedkoleksiyon;
  String? selectedmevcutkSehir;
  String? selectedgidelecekSehir;
  bool turYayinda = false;
  List<String> turFotograflari = []; // Fotoğraf URL'lerini tutacak liste
  final picker = ImagePicker();

  Map<String, String> turKoleksiyonIsimleri = {
    'popular': 'Popüler Turlar',
    'europe': 'Avrupa Turları',
    'sea_vacation': 'Deniz Tatilleri',
    'black_sea': 'Karadeniz Turları',
    'anatolia': 'Anadolu Turları',
    'religious': 'Hac & Umre Turları',
    'gastronomy': 'Gastronomi Turları',
    'yacht': 'Yat & Tekne Turları',
    'health': 'Sağlık Turları'
  };

  List<String> yolculukTuruOptions = ['Otobüs', 'Uçak', 'Tren', 'Gemi'];
  List<String> turSuresiOptions = ['Günübirlik', '2 Gün 1 Gece', '3 Gün 2 Gece'];
  List<String> turSehiriOptions = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kilis',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Şanlıurfa',
    'Siirt',
    'Sinop',
    'Sivas',
    'Şırnak',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak'
  ];

  @override
  void initState() {
    super.initState();
    _fillTurData();
    _getTurFotograflari();
  }

  @override
  void dispose() {
    turAdiController.dispose();
    acentaAdiController.dispose();
    fiyatController.dispose();
    tarihController.dispose();
    turSuresiController.dispose();

    for (var controller in turDetaylariControllers) {
      controller.dispose();
    }
    for (var controller in fiyataDahilHizmetlerControllers) {
      controller.dispose();
    }
    for (var controller in otobusDuraklariControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _getTurFotograflari() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final acenteID = user!.uid;
      final turFotoRef =
          firebase_storage.FirebaseStorage.instance.ref('users/$acenteID/turFotograflari/${widget.turID}/fotograflar');
      final result = await turFotoRef.listAll();

      final fotoURLs = await Future.wait(result.items.map((fotoRef) => fotoRef.getDownloadURL()));

      setState(() {
        turFotograflari = fotoURLs.cast<String>();
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(String fotoURL) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fotoğrafı Sil'),
          content: const Text('Silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () {
                _deleteFoto(fotoURL);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFoto(String fotoURL) {
    // Fotoğrafı silme işlemi
  }

  Future<void> _showImagePicker() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final acenteID = user!.uid;
      final uuid = const Uuid().v4(); // Benzersiz bir ID oluşturun
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref('users/$acenteID/turFotograflari/${widget.turID}/fotograflar/$uuid');
      final uploadTask = storageRef.putFile(imageFile);

      await uploadTask.whenComplete(() => null);

      setState(() {
        // Yeni fotoğrafı ekleyin
        turFotograflari.add(storageRef.fullPath);
      });
    } catch (e) {
      print('Hata: $e');
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

  void _fillTurData() async {
    try {
      // YENİ YAPI: tours collection'dan oku
      DocumentSnapshot turSnapshot = await FirebaseFirestore.instance.collection('tours').doc(widget.turID).get();

      if (turSnapshot.exists) {
        final turData = turSnapshot.data() as Map<String, dynamic>;

        setState(() {
          // Yeni yapı ile backward compatible veri okuma
          selectedkoleksiyon = FirebaseHelper.getTourCategory(turData);
          turAdiController.text = FirebaseHelper.getTourTitle(turData);
          acentaAdiController.text = FirebaseHelper.getAgencyName(turData);
          fiyatController.text = FirebaseHelper.getTourPrice(turData).toStringAsFixed(0);

          final tourDate = FirebaseHelper.getTourDate(turData);
          if (tourDate != null) {
            tarihController.text = DateFormat('dd/MM/yyyy').format(tourDate.toDate());
          }

          selectedYolculukTuru =
              FirebaseHelper.convertTransportationTypeToTurkish(FirebaseHelper.getTransportationType(turData));
          selectedTurSuresi = FirebaseHelper.getTourDuration(turData);
          kapasiteController.text = FirebaseHelper.getTourCapacity(turData).toString();

          // Şehir değerlerini al ve listede yoksa ekle
          final departureCity = turData['departureCity'] ?? turData['turunkalkacagiSehir'] ?? '';
          if (departureCity.isNotEmpty && !turSehiriOptions.contains(departureCity)) {
            turSehiriOptions.add(departureCity);
          }
          selectedmevcutkSehir = departureCity;

          final destCities = FirebaseHelper.getDestinationCities(turData);
          final destCity = destCities.isNotEmpty ? destCities[0] : (turData['turungidecegiSehir'] ?? '');
          if (destCity.isNotEmpty && !turSehiriOptions.contains(destCity)) {
            turSehiriOptions.add(destCity);
          }
          selectedgidelecekSehir = destCity;

          turYayinda = FirebaseHelper.isTourActive(turData);
          acenteID.text = FirebaseHelper.getAgencyId(turData);

          // Tur detayları
          final itinerary = FirebaseHelper.getItinerary(turData);
          for (var turDetay in itinerary) {
            turDetaylariControllers.add(TextEditingController(text: turDetay.toString()));
          }

          // Dahil hizmetler
          final includedServices = FirebaseHelper.getIncludedServices(turData);
          for (var hizmet in includedServices) {
            fiyataDahilHizmetlerControllers.add(TextEditingController(text: hizmet));
          }

          // Otobüs durakları
          final busStops = FirebaseHelper.getBusStops(turData);
          for (var otobusDurak in busStops) {
            otobusDuraklariControllers.add(TextEditingController(text: otobusDurak));
          }
        });
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _onKoleksiyonChanged(String? newValue) {
    setState(() {
      selectedkoleksiyon = newValue;
    });
  }

  void _addTurDetayiField() {
    setState(() {
      turDetaylariControllers.add(TextEditingController());
    });
  }

  void _addFiyataDahilHizmetField() {
    setState(() {
      fiyataDahilHizmetlerControllers.add(TextEditingController());
    });
  }

  void _addOtobusDuraklariField() {
    setState(() {
      otobusDuraklariControllers.add(TextEditingController());
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        tarihController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> getAcentaAdiFromFirestore() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final documentSnapshot = await userRef.collection('kullanici_bilgileri').doc('acente_bilgileri').get();
    final acentaAdi = documentSnapshot.data()?['acenteAdi'] as String?;
    if (acentaAdi != null) {
      acentaAdiController.text = acentaAdi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Tur Güncelle")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: () {
              _showImagePicker();
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _guncelleButtonHandler();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tur Kategorisi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedkoleksiyon,
                onChanged: _onKoleksiyonChanged,
                items: turKoleksiyonIsimleri.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Koleksiyon seçilmelidir';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tur Yayında',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 150,
                  ),
                  Switch(
                    value: turYayinda,
                    onChanged: (value) {
                      setState(() {
                        turYayinda = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tur Adı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: turAdiController,
                decoration: const InputDecoration(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Tur Adı boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Acente Adı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: acentaAdiController,
                decoration: const InputDecoration(),
                enabled: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Acente Adı boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fiyat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: fiyatController,
                decoration: const InputDecoration(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Fiyat boş bırakılamaz.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Harekat noktası şehiri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedmevcutkSehir,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedmevcutkSehir = newValue;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Harekat noktası şehiri boş bırakılamaz.';
                  }
                  return null;
                },
                items: turSehiriOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Turun Gideceği Şehir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedgidelecekSehir,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedgidelecekSehir = newValue;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Turun Gideceği Şehir boş bırakılamaz.';
                  }
                  return null;
                },
                items: turSehiriOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tarih',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: tarihController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Tarih boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Yolculuk Türü',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedYolculukTuru,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYolculukTuru = newValue;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Yolculuk Türü boş bırakılamaz.';
                  }
                  return null;
                },
                items: yolculukTuruOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tur Süresi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedTurSuresi,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTurSuresi = newValue;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Tur Süresi boş bırakılamaz.';
                  }
                  return null;
                },
                items: turSuresiOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tur Yolcu Kapasitesi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: kapasiteController,
                decoration: const InputDecoration(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Tur Yolcu Kapasitesi boş bırakılamaz.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tur Programı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: turDetaylariControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: turDetaylariControllers[index],
                          decoration: const InputDecoration(
                              labelText: 'Tur Detayları', labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            turDetaylariControllers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: _addTurDetayiField,
                child: const Text("Tur Programı Ekle"),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fiyata Dahil Hizmetler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: fiyataDahilHizmetlerControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fiyataDahilHizmetlerControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Fiyata Dahil Hizmetler',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            fiyataDahilHizmetlerControllers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: _addFiyataDahilHizmetField,
                child: const Text("Fiyata Dahil Hizmet Ekle"),
              ),
              const SizedBox(
                height: 20,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Otobus Durakları',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: otobusDuraklariControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: otobusDuraklariControllers[index],
                          decoration: const InputDecoration(
                              labelText: 'Otobus Durakları', labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            otobusDuraklariControllers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: _addOtobusDuraklariField,
                child: const Text("Otobus Durağı Ekle"),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Fotoğraflar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
                items: turFotograflari.map((fotoURL) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Image.network(
                              fotoURL,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white, width: 0)),
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _showDeleteConfirmationDialog(fotoURL);
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      icon: const Icon(Icons.add_photo_alternate),
                      onPressed: _showImagePicker,
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _guncelleButtonHandler();
                },
                child: const Text("Güncelle"),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _guncelleButtonHandler() async {
    final turAdi = turAdiController.text;
    final acentaAdi = acentaAdiController.text;
    final fiyat = double.parse(fiyatController.text);
    final tarih = DateFormat('dd/MM/yyyy').parse(tarihController.text);
    final tarihTimestamp = Timestamp.fromDate(tarih);
    final yolculukTuru = selectedYolculukTuru;
    final turunkalkacagiSehir = selectedmevcutkSehir;
    final turungidecegiSehiri = selectedgidelecekSehir;
    final turSuresi = selectedTurSuresi;
    final kapasite = int.parse(kapasiteController.text);
    String userIPAddress = await getUserIPAddress();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    List<String> turDetaylari = [];
    for (var controller in turDetaylariControllers) {
      turDetaylari.add(controller.text);
    }

    List<String> fiyataDahilHizmetler = [];
    for (var controller in fiyataDahilHizmetlerControllers) {
      fiyataDahilHizmetler.add(controller.text);
    }

    List<String> otobusDuraklari = [];
    for (var controller in otobusDuraklariControllers) {
      otobusDuraklari.add(controller.text);
    }

    try {
      // YENİ YAPI: tours collection'ı güncelle
      await FirebaseFirestore.instance.collection('tours').doc(widget.turID).update({
        // Yeni yapı fieldları
        'title': turAdi,
        'agencyName': acentaAdi,
        'pricePerPerson': fiyat,
        'startDate': tarihTimestamp,
        'transportationType': FirebaseHelper.convertTransportationTypeToEnglish(yolculukTuru),
        'durationText': turSuresi,
        'maxCapacity': kapasite,
        'departureCity': turunkalkacagiSehir,
        'destinationCities': [turungidecegiSehiri],
        'isActive': turYayinda,
        'itinerary': turDetaylari,
        'includedServices': fiyataDahilHizmetler,
        'busStops': otobusDuraklari,
        'category': selectedkoleksiyon,
        'updatedAt': FieldValue.serverTimestamp(),

        // Backward compatibility için eski yapı fieldları
        'tur_adi': turAdi,
        'acenta_adi': acentaAdi,
        'fiyat': fiyat.toInt(),
        'tarih': tarihTimestamp,
        'yolculuk_turu': yolculukTuru,
        'tur_suresi': turSuresi,
        'kapasite': kapasite,
        'turunkalkacagiSehir': turunkalkacagiSehir,
        'turungidecegiSehir': turungidecegiSehiri,
        'tur_yayinda': turYayinda,
        'turDetaylari': turDetaylari,
        'fiyataDahilHizmetler': fiyataDahilHizmetler,
        'otobusDuraklari': otobusDuraklari,
        'Guncelleyen_Acente_ipAdresi': userIPAddress,
        'Acente_Guncelleme_tarihi': DateTime.now(),
      });

      // Başarıyla güncellendiğinde bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tur başarıyla güncellendi.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Güncelleme hatası: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
