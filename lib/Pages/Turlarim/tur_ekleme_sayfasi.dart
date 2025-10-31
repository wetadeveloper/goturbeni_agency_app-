import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:gez_gor_saticii/services/firebase_helper.dart';

class TurEklemeSayfasi extends StatefulWidget {
  const TurEklemeSayfasi({Key? key}) : super(key: key);

  @override
  TurEklemeSayfasiState createState() => TurEklemeSayfasiState();
}

class TurEklemeSayfasiState extends State<TurEklemeSayfasi> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController turAdiController = TextEditingController();
  final TextEditingController acentaAdiController = TextEditingController(text: 'Acente Adı');
  final TextEditingController fiyatController = TextEditingController();
  final TextEditingController tarihController = TextEditingController();
  final TextEditingController yolculukTuruController = TextEditingController();
  final TextEditingController turSuresiController = TextEditingController();
  final TextEditingController kapasiteController = TextEditingController();

  List<TextEditingController> turDetaylariControllers = [];
  List<TextEditingController> fiyataDahilHizmetlerControllers = [];
  List<TextEditingController> otobusDuraklariControllers = [];

  List<File> selectedImages = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedYolculukTuru;
  String? selectedTurSuresi;
  String? selectedTurKoleksiyonIsimleri;
  String? selectedmevcutkSehir;
  String? selectedgidelecekSehir;
  bool turYayinda = true;
  bool turOnayi = false;
  String? turID; // Tur ID'si

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

  final List<String> turSehirleri = [
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
    getAcentaAdiFromFirestore();
  }

  Future<void> getAcentaAdiFromFirestore() async {
    // YENİ YAPI: user_info/acente_bilgileri
    final docSnapshot = await FirebaseHelper.getAgencyInfoDocument(user!.uid).get();
    final data = docSnapshot.data() as Map<String, dynamic>?;
    final acentaAdi = data?['acente_adi'] as String?;
    if (acentaAdi != null) {
      acentaAdiController.text = acentaAdi;
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
        title: const Center(child: Text("Tur Ekle")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: () {
              _pickImages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () {
              _ekleButtonHandler();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tur Kategorisi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              buildDropdownButtonFormField<String>(
                value: selectedTurKoleksiyonIsimleri,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTurKoleksiyonIsimleri = newValue;
                  });
                },
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
              buildTextField(
                controller: turAdiController,
                labelText: "Tur Adı",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tur Adı boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              buildTextField(
                controller: acentaAdiController,
                labelText: "Acenta Adı",
                readOnly: true,
              ),
              buildTextField(
                controller: fiyatController,
                labelText: "Fiyat",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fiyat boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hareket Noktası',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              buildDropdownButtonFormField<String>(
                value: selectedmevcutkSehir,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedmevcutkSehir = newValue;
                  });
                },
                items: turSehirleri.map((sehir) {
                  return DropdownMenuItem(
                    value: sehir,
                    child: Text(sehir),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hareket Noktası Şehiri Boş Bırakılamaz.';
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
                  'Turun Gideceği Şehir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              buildDropdownButtonFormField<String>(
                value: selectedgidelecekSehir,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedgidelecekSehir = newValue;
                  });
                },
                items: turSehirleri.map((sehir) {
                  return DropdownMenuItem(
                    value: sehir,
                    child: Text(sehir),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Turun Gideceği Şehir Boş Bırakılamaz.';
                  }
                  return null;
                },
              ),
              buildTextField(
                controller: tarihController,
                labelText: "Tarih",
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tarih boş bırakılamaz';
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
              buildDropdownButtonFormField<String>(
                value: selectedYolculukTuru,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYolculukTuru = newValue;
                  });
                },
                items: [
                  const DropdownMenuItem(
                    value: 'Otobüs',
                    child: Text('Otobüs'),
                  ),
                  const DropdownMenuItem(
                    value: 'Uçak',
                    child: Text('Uçak'),
                  ),
                  const DropdownMenuItem(
                    value: 'Tren',
                    child: Text('Tren'),
                  ),
                  const DropdownMenuItem(
                    value: 'Gemi',
                    child: Text('Gemi'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yolculuk Türü seçilmelidir';
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
                  'Tur Süresi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              buildDropdownButtonFormField<String>(
                value: selectedTurSuresi,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTurSuresi = newValue;
                  });
                },
                items: [
                  const DropdownMenuItem(
                    value: 'Günübirlik',
                    child: Text('Günübirlik'),
                  ),
                  const DropdownMenuItem(
                    value: '2 Gün 1 Gece',
                    child: Text('2 Gün 1 Gece'),
                  ),
                  const DropdownMenuItem(
                    value: '3 Gün 2 Gece',
                    child: Text('3 Gün 2 Gece'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tur Süresi seçilmelidir';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              buildTextField(
                controller: kapasiteController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                labelText: "Tur Yolcu Kapasitesi",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kapasite boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Tur Detayları',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildDynamicTextFields(
                controllers: turDetaylariControllers,
                labelText: 'Tur Programı',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addTurDetayiField,
                child: const Text("Tur Detayları Ekle"),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fiyata Dahil Hizmetler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildDynamicTextFields(
                controllers: fiyataDahilHizmetlerControllers,
                labelText: 'Fiyata Dahil Hizmetler',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addFiyataDahilHizmetField,
                child: const Text("Fiyata Dahil Hizmet Ekle"),
              ),
              const SizedBox(height: 16),
              const Text(
                'Otobus Durakları',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildDynamicTextFields(
                controllers: otobusDuraklariControllers,
                labelText: 'Otobus Durakları',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addOtobusDuraklariField,
                child: const Text("Otobus Durağı Ekle"),
              ),
              const Text(
                'Fotoğraflar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildImagePickerButton(),
              const SizedBox(height: 16),
              buildImagePreview(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _ekleButtonHandler,
                child: const Text("Turumu Ekle"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    Widget? suffixIcon,
    VoidCallback? suffixIconPressed,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText, // labelText doğrudan Text widget'ının içinde kullanılıyor
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: suffixIcon != null
                ? IconButton(
                    onPressed: suffixIconPressed,
                    icon: suffixIcon,
                  )
                : null,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          enabled: !readOnly,
          // Make the text field read-only if readOnly is true
          readOnly: readOnly, // Set the readOnly property to allow copying the text
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildDropdownButtonFormField<T>({
    required T? value,
    required void Function(T?) onChanged,
    required List<DropdownMenuItem<T>> items,
    required String? Function(T?) validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(),
      items: items,
      validator: validator,
    );
  }

  Widget buildDynamicTextFields({
    required List<TextEditingController> controllers,
    required String labelText,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controllers.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Expanded(
              child: buildTextField(
                controller: controllers[index],
                labelText: labelText,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  controllers.removeAt(index);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildImagePickerButton() {
    return ElevatedButton.icon(
      onPressed: _pickImages,
      icon: const Icon(Icons.add_photo_alternate),
      label: const Text('Fotoğraf Seç'),
    );
  }

  Widget buildImagePreview() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enableInfiniteScroll: false,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
      ),
      items: selectedImages.map((image) {
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Fotoğrafı Sil'),
                  content: const Text('Fotoğrafı silmek istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      child: const Text('Hayır'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Evet'),
                      onPressed: () {
                        setState(() {
                          selectedImages.remove(image);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Image.file(image),
          ),
        );
      }).toList(),
    );
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
    if (otobusDuraklariControllers.isNotEmpty) {
      otobusDuraklariControllers[otobusDuraklariControllers.length - 1].text = ''; // Yeni eklenen alanı boş bırak
    }
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

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  void _ekleButtonHandler() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (otobusDuraklariControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("En az bir otobüs durağı eklemelisiniz."),
          duration: Duration(seconds: 2),
        ),
      );
      return; // İşlemi durdur
    }

    final turAdi = turAdiController.text;
    final acentaAdi = acentaAdiController.text;
    final fiyat = double.parse(fiyatController.text);
    int kapasite = int.parse(kapasiteController.text);
    String userIPAddress = await getUserIPAddress();

    DateTime? tarih;
    try {
      tarih = DateFormat('dd/MM/yyyy').parseStrict(tarihController.text);
    } catch (e) {
      print('Geçersiz tarih formatı: ${tarihController.text}');
      return;
    }

    turID = const Uuid().v4(); // turID'yi oluştur

    List<String> imageUrls = [];

    for (var image in selectedImages) {
      final String imagePath = 'users/${user!.uid}/turFotograflari/$turID/fotograflar/${const Uuid().v4()}';
      firebase_storage.UploadTask uploadTask = firebase_storage.FirebaseStorage.instance.ref(imagePath).putFile(image);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
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

    // YENİ YAPI: tours collection'a kaydet
    final tourData = FirebaseHelper.createTourData(
      tourId: turID!,
      title: turAdi,
      category: selectedTurKoleksiyonIsimleri!, // Artık category değeri: 'popular', 'europe' vs
      pricePerPerson: fiyat,
      agencyId: user!.uid,
      agencyName: acentaAdi,
      maxCapacity: kapasite,
      availableSeats: kapasite,
      startDate: Timestamp.fromDate(tarih),
      destinationCities: [selectedgidelecekSehir!], // Gidilecek şehir
      departureCity: selectedmevcutkSehir, // Kalkış şehri
      transportationType: FirebaseHelper.convertTransportationTypeToEnglish(selectedYolculukTuru),
      images: imageUrls,
      coverImage: imageUrls.isNotEmpty ? imageUrls[0] : null,
      itinerary: turDetaylari,
      includedServices: fiyataDahilHizmetler,
      busStops: otobusDuraklari,
      durationText: selectedTurSuresi,
      isActive: turYayinda,
      additionalData: {
        'createdAt': FieldValue.serverTimestamp(),
        'turunkalkacagiSehir': selectedmevcutkSehir, // Backward compatibility için
        'turungidecegiSehir': selectedgidelecekSehir, // Backward compatibility için
        'Acente_ipAdresi': userIPAddress,
        'tur_onayi': turOnayi,
        // Eski yapı için backward compatibility fieldları
        'tur_adi': turAdi,
        'acenta_adi': acentaAdi,
        'acenta_id': user!.uid,
        'fiyat': fiyat.toInt(),
        'tarih': Timestamp.fromDate(tarih),
        'yolculuk_turu': selectedYolculukTuru,
        'tur_suresi': selectedTurSuresi,
        'kapasite': kapasite,
        'turDetaylari': turDetaylari,
        'fiyataDahilHizmetler': fiyataDahilHizmetler,
        'otobusDuraklari': otobusDuraklari,
        'turunOlusturulmaTarihi': DateTime.now(),
        'tur_yayinda': turYayinda,
        'imageUrls': imageUrls,
      },
    );

    // YENİ YAPI: tours collection'a kaydet
    FirebaseFirestore.instance.collection('tours').doc(turID).set(tourData).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tur başarıyla kaydedildi."),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey.shade700,
        ),
      );
      Navigator.of(context).pop();
    }).catchError((error) {
      print("$error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tur kaydedilirken bir hata oluştu."),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
