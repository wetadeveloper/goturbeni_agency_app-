import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase yeni yapısına geçiş için helper class
/// Backward compatibility sağlar - hem eski hem yeni field'leri kontrol eder
class FirebaseHelper {
  // Kategori mapping - eski collection isimlerinden yeni category değerlerine
  static const Map<String, String> categoryMapping = {
    'populer_turlar': 'popular',
    'avrupa_turlari': 'europe',
    'deniz_tatilleri': 'sea_vacation',
    'karadeniz_turlari': 'black_sea',
    'anadolu_turlari': 'anatolia',
    'hac_umre_turlari': 'religious',
    'gastronomi_turlari': 'gastronomy',
    'yatvetekne_turlari': 'yacht',
    'saglik_turlari': 'health',
  };

  // Ters mapping - yeni category değerlerinden eski collection isimlerine
  static const Map<String, String> reverseCategoryMapping = {
    'popular': 'populer_turlar',
    'europe': 'avrupa_turlari',
    'sea_vacation': 'deniz_tatilleri',
    'black_sea': 'karadeniz_turlari',
    'anatolia': 'anadolu_turlari',
    'religious': 'hac_umre_turlari',
    'gastronomy': 'gastronomi_turlari',
    'yacht': 'yatvetekne_turlari',
    'health': 'saglik_turlari',
  };

  // Kategori display isimleri
  static const Map<String, String> categoryDisplayNames = {
    'popular': 'Popüler Turlar',
    'europe': 'Avrupa Turları',
    'sea_vacation': 'Deniz Tatilleri',
    'black_sea': 'Karadeniz Turları',
    'anatolia': 'Anadolu Turları',
    'religious': 'Hac & Umre Turları',
    'gastronomy': 'Gastronomi Turları',
    'yacht': 'Yat & Tekne Turları',
    'health': 'Sağlık Turları',
  };

  /// Tur başlığını al (backward compatible)
  static String getTourTitle(Map<String, dynamic> data) {
    return data['title']?.toString() ?? data['tur_adi']?.toString() ?? 'Bilinmiyor';
  }

  /// Tur fiyatını al (backward compatible)
  static double getTourPrice(Map<String, dynamic> data) {
    final price = data['pricePerPerson'] ?? data['fiyat'] ?? 0;
    if (price is int) return price.toDouble();
    if (price is double) return price;
    return double.tryParse(price.toString()) ?? 0.0;
  }

  /// Acente ID'sini al (backward compatible)
  static String getAgencyId(Map<String, dynamic> data) {
    return data['agencyId']?.toString() ?? data['acenta_id']?.toString() ?? '';
  }

  /// Acente adını al (backward compatible)
  static String getAgencyName(Map<String, dynamic> data) {
    return data['agencyName']?.toString() ?? data['acenta_adi']?.toString() ?? '';
  }

  /// Tur kapasitesini al (backward compatible)
  static int getTourCapacity(Map<String, dynamic> data) {
    final capacity = data['maxCapacity'] ?? data['kapasite'] ?? 0;
    if (capacity is int) return capacity;
    return int.tryParse(capacity.toString()) ?? 0;
  }

  /// Müsait koltuk sayısını al (backward compatible)
  static int getAvailableSeats(Map<String, dynamic> data) {
    final seats = data['availableSeats'] ?? data['kalan_kontenjan'] ?? getTourCapacity(data);
    if (seats is int) return seats;
    return int.tryParse(seats.toString()) ?? 0;
  }

  /// Tur tarihini al (backward compatible)
  static Timestamp? getTourDate(Map<String, dynamic> data) {
    return data['startDate'] ?? data['tarih'];
  }

  /// Gidilecek şehirleri al (backward compatible)
  static List<String> getDestinationCities(Map<String, dynamic> data) {
    final cities = data['destinationCities'] ?? data['turungidecegiSehir'];
    if (cities is List) {
      return cities.map((c) => c.toString()).toList();
    }
    return [];
  }

  /// Ulaşım tipini al (backward compatible)
  static String getTransportationType(Map<String, dynamic> data) {
    final transport = data['transportationType'] ?? data['yolculuk_turu'] ?? '';
    return transport.toString();
  }

  /// Tur görsellerini al (backward compatible)
  static List<String> getTourImages(Map<String, dynamic> data) {
    final images = data['images'] ?? data['resimURLleri'] ?? data['imageUrls'];
    if (images is List) {
      return images.map((img) => img.toString()).toList();
    }
    return [];
  }

  /// Kapak görselini al (backward compatible)
  static String? getCoverImage(Map<String, dynamic> data) {
    return data['coverImage']?.toString() ?? data['thumbnailUrl']?.toString();
  }

  /// Günlük programı al (backward compatible)
  static List<dynamic> getItinerary(Map<String, dynamic> data) {
    final itinerary = data['itinerary'] ?? data['turDetaylari'] ?? data['gunlukProgram'];
    if (itinerary is List) return itinerary;
    return [];
  }

  /// Dahil hizmetleri al (backward compatible)
  static List<String> getIncludedServices(Map<String, dynamic> data) {
    final services = data['includedServices'] ?? data['fiyataDahilHizmetler'];
    if (services is List) {
      return services.map((s) => s.toString()).toList();
    }
    return [];
  }

  /// Dahil olmayan hizmetleri al (backward compatible)
  static List<String> getExcludedServices(Map<String, dynamic> data) {
    final services = data['excludedServices'] ?? data['fiyataDahilOlmayanHizmetler'];
    if (services is List) {
      return services.map((s) => s.toString()).toList();
    }
    return [];
  }

  /// Otobüs duraklarını al (backward compatible)
  static List<String> getBusStops(Map<String, dynamic> data) {
    final stops = data['busStops'] ?? data['otobus_duraklari'];
    if (stops is List) {
      return stops.map((s) => s.toString()).toList();
    }
    return [];
  }

  /// Açıklamayı al (backward compatible)
  static String getDescription(Map<String, dynamic> data) {
    return data['description']?.toString() ?? data['aciklama']?.toString() ?? '';
  }

  /// Tur süresini al (backward compatible)
  static String getTourDuration(Map<String, dynamic> data) {
    return data['durationText']?.toString() ?? data['tur_suresi']?.toString() ?? '';
  }

  /// Tur kategorisini al (backward compatible)
  static String getTourCategory(Map<String, dynamic> data) {
    return data['category']?.toString() ?? 'general';
  }

  /// Tur aktif mi kontrol et (backward compatible)
  static bool isTourActive(Map<String, dynamic> data) {
    return data['isActive'] ?? data['turYayinda'] ?? true;
  }

  /// Yeni yapıya göre tur verisi oluştur (Create/Update için)
  static Map<String, dynamic> createTourData({
    required String tourId,
    required String title,
    required String category,
    required double pricePerPerson,
    required String agencyId,
    required String agencyName,
    required int maxCapacity,
    int? availableSeats,
    required Timestamp startDate,
    Timestamp? endDate,
    required List<String> destinationCities,
    String? departureCity,
    String? transportationType,
    List<String>? images,
    String? coverImage,
    List<dynamic>? itinerary,
    List<String>? includedServices,
    List<String>? excludedServices,
    List<String>? busStops,
    String? description,
    String? durationText,
    bool isActive = true,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{
      'tourId': tourId,
      'title': title,
      'category': category,
      'pricePerPerson': pricePerPerson,
      'currency': 'TRY',
      'agencyId': agencyId,
      'agencyName': agencyName,
      'maxCapacity': maxCapacity,
      'availableSeats': availableSeats ?? maxCapacity,
      'startDate': startDate,
      'destinationCities': destinationCities,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (endDate != null) data['endDate'] = endDate;
    if (departureCity != null) data['departureCity'] = departureCity;
    if (transportationType != null) data['transportationType'] = transportationType;
    if (images != null && images.isNotEmpty) data['images'] = images;
    if (coverImage != null) data['coverImage'] = coverImage;
    if (itinerary != null && itinerary.isNotEmpty) data['itinerary'] = itinerary;
    if (includedServices != null && includedServices.isNotEmpty) data['includedServices'] = includedServices;
    if (excludedServices != null && excludedServices.isNotEmpty) data['excludedServices'] = excludedServices;
    if (busStops != null && busStops.isNotEmpty) data['busStops'] = busStops;
    if (description != null) data['description'] = description;
    if (durationText != null) data['durationText'] = durationText;

    // Ek data varsa ekle
    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Kullanıcı bilgileri yolu - yeni yapı
  static CollectionReference getUserInfoCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('user_info');
  }

  /// Acente bilgileri yolu - yeni yapı
  static DocumentReference getAgencyInfoDocument(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('user_info').doc('acente_bilgileri');
  }

  /// Kullanıcı bilgileri dökümanı - yeni yapı
  static DocumentReference getUserBilgileriDocument(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('user_info').doc('bilgiler');
  }

  /// Rezervasyon collection'ı - yeni yapı
  static CollectionReference getReservationsCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('reservations');
  }

  /// Tüm turları çek (yeni yapı)
  static Query<Map<String, dynamic>> getAllToursQuery() {
    return FirebaseFirestore.instance.collection('tours').orderBy('createdAt', descending: true);
  }

  /// Kategori bazlı turları çek
  static Query<Map<String, dynamic>> getToursByCategory(String category) {
    return FirebaseFirestore.instance
        .collection('tours')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('startDate');
  }

  /// Acente turlarını çek
  static Query<Map<String, dynamic>> getToursByAgency(String agencyId) {
    return FirebaseFirestore.instance
        .collection('tours')
        .where('agencyId', isEqualTo: agencyId)
        .orderBy('startDate', descending: false);
  }

  /// Yaklaşan turları çek
  static Query<Map<String, dynamic>> getUpcomingTours(String agencyId) {
    final now = Timestamp.fromDate(DateTime.now());
    return FirebaseFirestore.instance
        .collection('tours')
        .where('agencyId', isEqualTo: agencyId)
        .where('startDate', isGreaterThanOrEqualTo: now)
        .orderBy('startDate');
  }

  /// Geçmiş turları çek
  static Query<Map<String, dynamic>> getPastTours(String agencyId) {
    final now = Timestamp.fromDate(DateTime.now());
    return FirebaseFirestore.instance
        .collection('tours')
        .where('agencyId', isEqualTo: agencyId)
        .where('startDate', isLessThan: now)
        .orderBy('startDate', descending: true);
  }

  /// Kategori adını göster adına çevir
  static String getCategoryDisplayName(String category) {
    return categoryDisplayNames[category] ?? category;
  }

  /// Eski koleksiyon ismini yeni kategori değerine çevir
  static String convertOldCollectionToCategory(String oldCollection) {
    return categoryMapping[oldCollection] ?? 'general';
  }

  /// Yeni kategori değerini eski koleksiyon ismine çevir
  static String convertCategoryToOldCollection(String category) {
    return reverseCategoryMapping[category] ?? 'turlar';
  }

  /// Rezervasyon verisi oluştur (yeni yapı)
  static Map<String, dynamic> createReservationData({
    required String reservationId,
    required String userId,
    required String tourId,
    required String tourTitle,
    required String companyId,
    required String companyName,
    required Timestamp tourStartDate,
    Timestamp? tourEndDate,
    required int adultCount,
    required int childCount,
    int infantCount = 0,
    required double pricePerPerson,
    required double totalPrice,
    double discount = 0.0,
    String paymentStatus = 'pending',
    String status = 'pending',
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{
      'reservationId': reservationId,
      'userId': userId,
      'tourId': tourId,
      'tourTitle': tourTitle,
      'companyId': companyId,
      'companyName': companyName,
      'tourStartDate': tourStartDate,
      'reservationDate': FieldValue.serverTimestamp(),
      'adultCount': adultCount,
      'childCount': childCount,
      'infantCount': infantCount,
      'totalPassengers': adultCount + childCount + infantCount,
      'pricePerPerson': pricePerPerson,
      'totalPrice': totalPrice,
      'discount': discount,
      'finalPrice': totalPrice - discount,
      'currency': 'TRY',
      'paymentStatus': paymentStatus,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (tourEndDate != null) data['tourEndDate'] = tourEndDate;

    // Ek data varsa ekle
    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Transportation type Türkçe'den İngilizce'ye
  static String convertTransportationTypeToEnglish(String? turkishType) {
    if (turkishType == null) return 'bus';
    switch (turkishType.toLowerCase()) {
      case 'otobüs':
        return 'bus';
      case 'uçak':
        return 'plane';
      case 'gemi':
        return 'ship';
      case 'tren':
        return 'train';
      default:
        return 'bus';
    }
  }

  /// Transportation type İngilizce'den Türkçe'ye
  static String convertTransportationTypeToTurkish(String? englishType) {
    if (englishType == null) return 'Otobüs';
    switch (englishType.toLowerCase()) {
      case 'bus':
        return 'Otobüs';
      case 'plane':
        return 'Uçak';
      case 'ship':
        return 'Gemi';
      case 'train':
        return 'Tren';
      default:
        return 'Otobüs';
    }
  }
}
