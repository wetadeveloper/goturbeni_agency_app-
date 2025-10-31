# Firebase Database Structure Documentation
## Banatuur - Yeni Yapı (Güncellenmiş: 28 Ekim 2025)

Bu döküman, Banatuur uygulamasının güncel Firebase veritabanı yapısını detaylı olarak açıklamaktadır. **ESKİ YAPI ARTIK KULLANILMIYOR.**

---

## 📋 İçindekiler
- [Genel Bakış](#genel-bakış)
- [Tours Collection](#tours-collection)
- [Users Collection](#users-collection)
- [Reservations Structure](#reservations-structure)
- [Reviews & Ratings](#reviews--ratings)
- [Chat System](#chat-system)
- [Campaigns](#campaigns)
- [Field Mapping (Eski → Yeni)](#field-mapping-eski--yeni)
- [Code Examples](#code-examples)

---

## 🎯 Genel Bakış

### ⚠️ ESKİ YAPI (ARTIK KULLANILMIYOR)
```
❌ populer_turlar/
❌ avrupa_turlari/
❌ deniz_tatilleri/
❌ karadeniz_turlari/
❌ anadolu_turlari/
❌ hac_umre_turlari/
❌ gastronomi_turlari/
❌ yatvetekne_turlari/
❌ saglik_turlari/
❌ turlar/
❌ kullanici_bilgileri/
```

### ✅ YENİ YAPI (GÜNCEL)
```
✅ tours/ (TEK unified collection)
✅ users/{userId}/
   ├── user_info/ (eski: kullanici_bilgileri)
   │   ├── bilgiler/
   │   └── acente_bilgileri/
   └── reservations/
✅ tour_chats/
✅ chat_messages/
✅ kampanyalar/
```

---

## 🗺️ Tours Collection

### Collection Path
```
/tours/{tourId}
```

### Document Structure

```javascript
{
  // ========== TEMEL BİLGİLER ==========
  "tourId": "unique_tour_id",           // String - Tur benzersiz ID
  "title": "Kapadokya Turu",            // String - Tur adı (ESKİ: tur_adi)
  "category": "popular",                 // String - Kategori (aşağıda detay)
  
  // ========== FİYATLANDIRMA ==========
  "pricePerPerson": 2500.0,             // Number - Kişi başı fiyat (ESKİ: fiyat)
  "currency": "TRY",                     // String - Para birimi
  "discountPercentage": 10,              // Number - İndirim yüzdesi (opsiyonel)
  "originalPrice": 2750.0,               // Number - İndirimli fiyat varsa orijinal fiyat
  
  // ========== ACENTE/FİRMA BİLGİLERİ ==========
  "agencyId": "company_user_id",        // String - Acente ID (ESKİ: acenta_id)
  "agencyName": "Gezgin Turizm",        // String - Acente adı (ESKİ: acenta_adi)
  "agencyLogo": "https://...",          // String - Acente logosu URL
  
  // ========== KAPASİTE VE DURUM ==========
  "maxCapacity": 40,                     // Number - Maksimum kapasite (ESKİ: kapasite)
  "availableSeats": 35,                  // Number - Müsait koltuk sayısı (ESKİ: kalan_kontenjan)
  "minParticipants": 20,                 // Number - Minimum katılımcı sayısı
  "isActive": true,                      // Boolean - Tur aktif mi?
  "status": "available",                 // String - available, full, cancelled
  
  // ========== TARİH VE SÜRE ==========
  "startDate": Timestamp,                // Timestamp - Başlangıç tarihi (ESKİ: tarih)
  "endDate": Timestamp,                  // Timestamp - Bitiş tarihi
  "duration": 5,                         // Number - Gün sayısı
  "durationText": "4 Gece 5 Gün",       // String - Süre metni
  
  // ========== LOKASYON BİLGİLERİ ==========
  "destinationCities": [                 // Array - Gidilecek şehirler (ESKİ: turungidecegiSehir)
    "Nevşehir",
    "Kapadokya",
    "Ürgüp"
  ],
  "departureCity": "İstanbul",          // String - Kalkış şehri
  "country": "Türkiye",                  // String - Ülke
  "region": "İç Anadolu",               // String - Bölge
  
  // ========== GÖRSEL İÇERİK ==========
  "images": [                            // Array - Tur görselleri (ESKİ: resimURLleri veya imageUrls)
    "https://storage.googleapis.com/.../image1.jpg",
    "https://storage.googleapis.com/.../image2.jpg",
    "https://storage.googleapis.com/.../image3.jpg"
  ],
  "coverImage": "https://...",          // String - Kapak görseli (ESKİ: thumbnailUrl)
  "videoUrl": "https://...",            // String - Tanıtım videosu (opsiyonel)
  
  // ========== ULAŞIM ==========
  "transportationType": "bus",           // String - bus, plane, ship, train (ESKİ: yolculuk_turu)
  "busStops": [                          // Array - Otobüs durakları (ESKİ: otobus_duraklari)
    "Kadıköy",
    "Bakırköy",
    "Şirinevler"
  ],
  "flightDetails": {                     // Object - Uçuş detayları (opsiyonel)
    "airline": "Turkish Airlines",
    "flightNumber": "TK123",
    "departureTime": "08:00",
    "arrivalTime": "09:30"
  },
  
  // ========== TUR DETAYLARI ==========
  "description": "Kapadokya'nın eşsiz...", // String - Genel açıklama (ESKİ: aciklama)
  "shortDescription": "3 gün 2 gece...",    // String - Kısa açıklama
  "itinerary": [                         // Array - Günlük program (ESKİ: turDetaylari veya gunlukProgram)
    {
      "day": 1,
      "title": "İstanbul - Kapadokya",
      "description": "Sabah 07:00'de...",
      "activities": ["Kahvaltı", "Transfer", "Otel check-in"],
      "meals": ["Kahvaltı", "Akşam Yemeği"]
    },
    {
      "day": 2,
      "title": "Kapadokya Turu",
      "description": "Tam gün Kapadokya...",
      "activities": ["Göreme", "Uçhisar", "Avanos"],
      "meals": ["Kahvaltı", "Öğle Yemeği", "Akşam Yemeği"]
    }
  ],
  
  // ========== DAHİL OLAN HİZMETLER ==========
  "includedServices": [                  // Array - Fiyata dahil (ESKİ: fiyataDahilHizmetler)
    "Ulaşım",
    "Konaklama",
    "Sabah kahvaltıları",
    "Rehber hizmeti",
    "Müze giriş ücretleri"
  ],
  
  // ========== DAHİL OLMAYAN HİZMETLER ==========
  "excludedServices": [                  // Array - Fiyata dahil değil (ESKİ: fiyataDahilOlmayanHizmetler)
    "Öğle ve akşam yemekleri",
    "Kişisel harcamalar",
    "Ekstra turlar"
  ],
  
  // ========== ÖZELLIKLER ==========
  "highlights": [                        // Array - Tur özellikleri
    "Sıcak hava balonu turu",
    "Yeraltı şehri gezisi",
    "Peri bacaları"
  ],
  "tags": [                             // Array - Etiketler
    "aile-dostu",
    "romantik",
    "kültür-turu",
    "fotoğraf-turu"
  ],
  
  // ========== KONAKLAMA ==========
  "accommodation": {                     // Object - Konaklama bilgisi
    "hotelName": "Cappadocia Cave Hotel",
    "hotelStars": 4,
    "roomType": "Standart Oda",
    "address": "Ürgüp, Nevşehir"
  },
  
  // ========== POLİTİKALAR ==========
  "cancellationPolicy": "15 gün öncesine...", // String - İptal politikası
  "ageRestrictions": "0-2 yaş ücretsiz",      // String - Yaş kısıtlamaları
  "requirements": [                      // Array - Gereksinimler
    "Kimlik veya pasaport",
    "Sağlık sigortası"
  ],
  
  // ========== PUANLAMA ==========
  "rating": 4.5,                         // Number - Ortalama puan
  "reviewCount": 142,                    // Number - Yorum sayısı
  "favoriteCount": 89,                   // Number - Favori sayısı
  
  // ========== METAVERİ ==========
  "createdAt": Timestamp,                // Timestamp - Oluşturulma tarihi
  "updatedAt": Timestamp,                // Timestamp - Güncellenme tarihi
  "createdBy": "admin_user_id",         // String - Oluşturan kullanıcı
  "isPromoted": false,                   // Boolean - Öne çıkarılmış mı?
  "viewCount": 1250                      // Number - Görüntülenme sayısı
}
```

### Kategori Değerleri (category field)

| Yeni Değer | Eski Koleksiyon Adı | Açıklama |
|-----------|-------------------|----------|
| `popular` | populer_turlar | Popüler turlar |
| `europe` | avrupa_turlari | Avrupa turları |
| `sea_vacation` | deniz_tatilleri | Deniz tatilleri |
| `black_sea` | karadeniz_turlari | Karadeniz turları |
| `anatolia` | anadolu_turlari | Anadolu turları |
| `religious` | hac_umre_turlari | Hac & Umre turları |
| `gastronomy` | gastronomi_turlari | Gastronomi turları |
| `yacht` | yatvetekne_turlari | Yat & Tekne turları |
| `health` | saglik_turlari | Sağlık turları |

### Örnek Sorgu (Firestore)

```javascript
// Kategori bazlı sorgulama
db.collection('tours')
  .where('category', '==', 'popular')
  .where('isActive', '==', true)
  .orderBy('startDate', 'desc')
  .limit(10)
  .get();

// Acente bazlı sorgulama
db.collection('tours')
  .where('agencyId', '==', 'company_user_id')
  .get();

// Fiyat aralığı sorgulama
db.collection('tours')
  .where('pricePerPerson', '>=', 1000)
  .where('pricePerPerson', '<=', 5000)
  .get();

// Müsait turlar
db.collection('tours')
  .where('availableSeats', '>', 0)
  .where('startDate', '>', new Date())
  .get();
```

---

## 👤 Users Collection

### Collection Path
```
/users/{userId}
```

### Root Document Structure

```javascript
{
  // ========== TEMEL BİLGİLER ==========
  "userId": "unique_user_id",
  "email": "user@example.com",
  "phoneNumber": "+905551234567",
  "userType": "customer",              // customer, agency, admin
  "isActive": true,
  "isEmailVerified": true,
  
  // ========== METAVERİ ==========
  "createdAt": Timestamp,
  "lastLoginAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Subcollection: user_info/bilgiler (Kullanıcı Bilgileri)

**Path:** `/users/{userId}/user_info/bilgiler`

```javascript
{
  // ESKİ YOL: kullanici_bilgileri/bilgiler
  // YENİ YOL: user_info/bilgiler
  
  "ad": "Ahmet",                        // String - İsim
  "soyad": "Yılmaz",                    // String - Soyisim
  "dogumTarihi": Timestamp,             // Timestamp - Doğum tarihi
  "cinsiyet": "erkek",                  // String - erkek, kadın
  "tcKimlikNo": "12345678901",          // String - TC Kimlik No
  "adres": "İstanbul, Kadıköy...",      // String - Adres
  "sehir": "İstanbul",                  // String - Şehir
  "ulke": "Türkiye",                    // String - Ülke
  "profilFotografi": "https://...",    // String - Profil fotoğrafı URL
  "biyografi": "Seyahat tutkunuyum",   // String - Kısa biyografi
  "updatedAt": Timestamp
}
```

### Subcollection: user_info/acente_bilgileri (Acente Bilgileri)

**Path:** `/users/{userId}/user_info/acente_bilgileri`

```javascript
{
  // ESKİ YOL: kullanici_bilgileri/acente_bilgileri
  // YENİ YOL: user_info/acente_bilgileri
  
  "acente_id": "unique_company_id",     // String - Acente ID
  "acente_adi": "Gezgin Turizm",        // String - Acente adı
  "firma_logo": "https://...",          // String - Firma logosu
  "acente_slogani": "Hayalleriniz...", // String - Slogan
  "vergi_no": "1234567890",             // String - Vergi numarası
  "vergi_dairesi": "Kadıköy",          // String - Vergi dairesi
  "firma_adresi": "İstanbul...",       // String - Firma adresi
  "firma_telefon": "+902161234567",     // String - Firma telefonu
  "firma_email": "info@gezgin.com",     // String - Firma email
  "yetkili_adi": "Mehmet Yılmaz",      // String - Yetkili kişi adı
  "yetkili_telefon": "+905551234567",   // String - Yetkili telefonu
  "tur_sayisi": 25,                     // Number - Toplam tur sayısı
  "ortalama_puan": 4.5,                 // Number - Ortalama puan
  "toplam_degerlendirme": 142,          // Number - Toplam değerlendirme sayısı
  "kurulusTarihi": Timestamp,           // Timestamp - Kuruluş tarihi
  "lisansNo": "A-12345",                // String - TÜRSAB lisans no
  "website": "https://gezgin.com",      // String - Web sitesi
  "socialMedia": {                      // Object - Sosyal medya hesapları
    "facebook": "gezginturizm",
    "instagram": "@gezginturizm",
    "twitter": "@gezginturizm"
  },
  "aciklama": "1995'ten beri...",      // String - Firma açıklaması
  "isVerified": true,                   // Boolean - Onaylı acente mi?
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## 🎫 Reservations Structure

### Collection Path
```
/users/{userId}/reservations/{reservationId}
```

### Document Structure

```javascript
{
  // ESKİ YOL: rezervasyonlar/ (root collection)
  // YENİ YOL: users/{userId}/reservations/ (subcollection)
  
  // ========== TEMEL BİLGİLER ==========
  "reservationId": "unique_reservation_id",
  "userId": "user_id",
  "tourId": "tour_id",
  
  // ========== TUR BİLGİLERİ ==========
  "tourTitle": "Kapadokya Turu",       // String - Tur adı
  "companyId": "agency_id",             // String - Acente ID (ESKİ: acenta_id)
  "companyName": "Gezgin Turizm",       // String - Acente adı
  
  // ========== TARİH VE SÜRE ==========
  "tourStartDate": Timestamp,           // Timestamp - Tur başlangıç
  "tourEndDate": Timestamp,             // Timestamp - Tur bitiş
  "reservationDate": Timestamp,         // Timestamp - Rezervasyon tarihi
  
  // ========== YOLCU BİLGİLERİ ==========
  "passengers": [                       // Array - Yolcular
    {
      "type": "adult",                  // adult, child, infant
      "name": "Ahmet Yılmaz",
      "tcNo": "12345678901",
      "birthDate": Timestamp,
      "gender": "erkek"
    },
    {
      "type": "child",
      "name": "Ayşe Yılmaz",
      "tcNo": "98765432109",
      "birthDate": Timestamp,
      "gender": "kadın"
    }
  ],
  "adultCount": 2,                      // Number - Yetişkin sayısı
  "childCount": 1,                      // Number - Çocuk sayısı
  "infantCount": 0,                     // Number - Bebek sayısı
  "totalPassengers": 3,                 // Number - Toplam yolcu
  
  // ========== FİYATLANDIRMA ==========
  "pricePerPerson": 2500.0,            // Number - Kişi başı fiyat
  "totalPrice": 6250.0,                 // Number - Toplam tutar
  "discount": 250.0,                    // Number - İndirim tutarı
  "finalPrice": 6000.0,                 // Number - Ödenecek tutar
  "currency": "TRY",
  
  // ========== ÖDEME BİLGİLERİ ==========
  "paymentStatus": "completed",         // String - pending, completed, failed, refunded
  "paymentMethod": "credit_card",       // String - credit_card, bank_transfer, cash
  "paymentDate": Timestamp,
  "paymentData": {                      // Object - Ödeme detayları
    "transactionId": "TXN123456",
    "cardLast4": "1234",
    "installment": 3
  },
  
  // ========== REZERVASYON DURUMU ==========
  "status": "confirmed",                // String - pending, confirmed, cancelled, completed
  "confirmationCode": "BNT-2025-12345", // String - Onay kodu
  "cancellationReason": "",             // String - İptal nedeni (varsa)
  "cancelledAt": null,                  // Timestamp - İptal tarihi
  
  // ========== İLETİŞİM ==========
  "contactName": "Ahmet Yılmaz",
  "contactPhone": "+905551234567",
  "contactEmail": "ahmet@example.com",
  "emergencyContact": {
    "name": "Mehmet Yılmaz",
    "phone": "+905559876543",
    "relation": "Kardeş"
  },
  
  // ========== EK BİLGİLER ==========
  "busStop": "Kadıköy",                 // String - Seçilen durak (varsa)
  "specialRequests": "Vejetaryen yemek", // String - Özel istekler
  "notes": "Admin notu...",             // String - Admin notları
  
  // ========== METAVERİ ==========
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "createdBy": "user_id",
  "lastModifiedBy": "admin_id"
}
```

---

## ⭐ Reviews & Ratings

### Collection Path
```
/users/{userId}/degerlendirmeler/{reviewId}
```

### Document Structure

```javascript
{
  "reviewId": "unique_review_id",
  "userId": "user_id",
  "userName": "Ahmet Yılmaz",
  "userPhoto": "https://...",
  
  // ========== PUANLAMA ==========
  "tourId": "tour_id",                  // String - Tur ID
  "tourName": "Kapadokya Turu",         // String - Tur adı
  "acenta_id": "agency_id",             // String - Acente ID (backward compatibility)
  "agencyId": "agency_id",              // String - Acente ID (yeni)
  "agencyName": "Gezgin Turizm",        // String - Acente adı
  
  "rating": 5,                          // Number - Genel puan (1-5)
  "tourRating": 5,                      // Number - Tur puanı
  "guideRating": 4,                     // Number - Rehber puanı
  "accommodationRating": 5,             // Number - Konaklama puanı
  "transportRating": 4,                 // Number - Ulaşım puanı
  
  // ========== YORUM ==========
  "comment": "Harika bir deneyimdi...", // String - Yorum metni
  "title": "Muhteşem bir tur",          // String - Yorum başlığı
  "pros": [                             // Array - Artılar
    "Profesyonel rehber",
    "Temiz otel"
  ],
  "cons": [                             // Array - Eksiler
    "Yemekler ortalama"
  ],
  
  // ========== MEDYA ==========
  "images": [                           // Array - Yorum görselleri
    "https://...",
    "https://..."
  ],
  
  // ========== DURUM ==========
  "isApproved": true,                   // Boolean - Onaylı mı?
  "isVisible": true,                    // Boolean - Görünür mü?
  "helpfulCount": 12,                   // Number - Yararlı bulan sayısı
  "reportCount": 0,                     // Number - Şikayet sayısı
  
  // ========== METAVERİ ==========
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "tripDate": Timestamp,                // Timestamp - Tur tarihi
  "verifiedPurchase": true              // Boolean - Doğrulanmış alım mı?
}
```

---

## 💬 Chat System

### Tour Chats Collection

**Path:** `/tour_chats/{chatId}`

```javascript
{
  "chatId": "unique_chat_id",
  "tourId": "tour_id",
  "tourName": "Kapadokya Turu",
  "agencyId": "agency_id",
  "agencyName": "Gezgin Turizm",
  "participants": ["user_id", "agency_id"], // Array - Katılımcılar
  "lastMessage": "Merhaba, tur hakkında...",
  "lastMessageTime": Timestamp,
  "unreadCount": {                      // Object - Okunmamış mesaj sayıları
    "user_id": 2,
    "agency_id": 0
  },
  "isActive": true,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Chat Messages Collection

**Path:** `/chat_messages/{messageId}`

```javascript
{
  "messageId": "unique_message_id",
  "chatId": "chat_id",                  // Reference to tour_chats
  "tourId": "tour_id",
  "senderId": "user_id",
  "senderName": "Ahmet Yılmaz",
  "senderType": "customer",             // customer, agency, admin
  "messageType": "text",                // text, image, file
  "content": "Merhaba, tur hakkında...",
  "imageUrl": null,                     // String - Görsel URL (varsa)
  "fileUrl": null,                      // String - Dosya URL (varsa)
  "isRead": false,
  "readAt": null,
  "createdAt": Timestamp
}
```

---

## 🎉 Campaigns

### Collection Path
```
/kampanyalar/{campaignId}
```

### Document Structure

```javascript
{
  "campaignId": "unique_campaign_id",
  "title": "Yaz İndirimi",
  "description": "%20 indirim fırsatı",
  "discountPercentage": 20,
  "discountAmount": 500,                // Sabit indirim tutarı (opsiyonel)
  "code": "YAZ2025",                    // Kampanya kodu
  "imageUrl": "https://...",
  
  "startDate": Timestamp,
  "endDate": Timestamp,
  
  "applicableTours": ["tour_id1", "tour_id2"], // Boşsa tüm turlar
  "applicableCategories": ["popular", "europe"], // Boşsa tüm kategoriler
  "minPurchaseAmount": 1000,            // Minimum alışveriş tutarı
  "maxUsageCount": 100,                 // Maksimum kullanım sayısı
  "usageCount": 23,                     // Mevcut kullanım sayısı
  "usedBy": ["user_id1", "user_id2"],  // Kullanan kullanıcılar
  
  "isActive": true,
  "createdAt": Timestamp,
  "createdBy": "admin_id"
}
```

---

## 🔄 Field Mapping (Eski → Yeni)

### Tours Collection Field Mapping

| Eski Field | Yeni Field | Tip | Açıklama |
|-----------|-----------|-----|----------|
| `tur_adi` | `title` | String | Tur adı |
| `fiyat` | `pricePerPerson` | Number | Kişi başı fiyat |
| `kapasite` | `maxCapacity` | Number | Maksimum kapasite |
| `kalan_kontenjan` | `availableSeats` | Number | Müsait koltuk |
| `tarih` | `startDate` | Timestamp | Başlangıç tarihi |
| `acenta_id` | `agencyId` | String | Acente ID |
| `acenta_adi` | `agencyName` | String | Acente adı |
| `turungidecegiSehir` | `destinationCities` | Array | Gidilecek şehirler |
| `yolculuk_turu` | `transportationType` | String | Ulaşım tipi |
| `resimURLleri` | `images` | Array | Görsel URL'leri |
| `thumbnailUrl` | `coverImage` | String | Kapak görseli |
| `turDetaylari` | `itinerary` | Array | Günlük program |
| `gunlukProgram` | `itinerary` | Array | Günlük program |
| `fiyataDahilHizmetler` | `includedServices` | Array | Dahil hizmetler |
| `fiyataDahilOlmayanHizmetler` | `excludedServices` | Array | Dahil olmayan hizmetler |
| `otobus_duraklari` | `busStops` | Array | Otobüs durakları |
| `aciklama` | `description` | String | Açıklama |

### Users Collection Field Mapping

| Eski Path | Yeni Path | Açıklama |
|----------|----------|----------|
| `/users/{id}/kullanici_bilgileri/bilgiler` | `/users/{id}/user_info/bilgiler` | Kullanıcı bilgileri |
| `/users/{id}/kullanici_bilgileri/acente_bilgileri` | `/users/{id}/user_info/acente_bilgileri` | Acente bilgileri |
| `/users/{id}/rezervasyonlar/{id}` | `/users/{id}/reservations/{id}` | Rezervasyonlar |

### Category Mapping

| Eski Collection | Yeni Category Value |
|----------------|-------------------|
| `populer_turlar` | `popular` |
| `avrupa_turlari` | `europe` |
| `deniz_tatilleri` | `sea_vacation` |
| `karadeniz_turlari` | `black_sea` |
| `anadolu_turlari` | `anatolia` |
| `hac_umre_turlari` | `religious` |
| `gastronomi_turlari` | `gastronomy` |
| `yatvetekne_turlari` | `yacht` |
| `saglik_turlari` | `health` |
| `turlar` | `general` |

---

## 💻 Code Examples

### Flutter/Dart Examples

#### 1. Tur Sorgulama (Yeni Yapı)

```dart
// ✅ DOĞRU - Yeni yapı
Future<List<Map<String, dynamic>>> getToursFromCategory(String category) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('tours')
      .where('category', isEqualTo: category)
      .where('isActive', isEqualTo: true)
      .orderBy('startDate', descending: false)
      .get();
  
  return snapshot.docs.map((doc) => doc.data()).toList();
}

// ❌ YANLIŞ - Eski yapı (KULLANMAYIN)
Future<List<Map<String, dynamic>>> getToursFromCategoryOld(String category) async {
  // Eski koleksiyon isimleri artık yok
  final snapshot = await FirebaseFirestore.instance
      .collection('populer_turlar') // ❌ Bu collection artık yok
      .get();
  
  return snapshot.docs.map((doc) => doc.data()).toList();
}
```

#### 2. Acente Bilgisi Alma (Yeni Yapı)

```dart
// ✅ DOĞRU - Yeni yapı
Future<Map<String, dynamic>?> getAgencyInfo(String userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('user_info') // ✅ YENİ
      .doc('acente_bilgileri')
      .get();
  
  return doc.data();
}

// ❌ YANLIŞ - Eski yapı (KULLANMAYIN)
Future<Map<String, dynamic>?> getAgencyInfoOld(String userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('kullanici_bilgileri') // ❌ ESKİ
      .doc('acente_bilgileri')
      .get();
  
  return doc.data();
}
```

#### 3. Tur Verisi Okuma (Backward Compatibility)

```dart
// ✅ EN İYİ YÖNTEM - Hem eski hem yeni field'leri kontrol et
String getTourTitle(Map<String, dynamic> tourData) {
  // Önce yeni field, sonra eski field, son olarak default
  return tourData['title'] ?? tourData['tur_adi'] ?? 'Bilinmiyor';
}

int getTourPrice(Map<String, dynamic> tourData) {
  final price = tourData['pricePerPerson'] ?? tourData['fiyat'] ?? 0;
  return price is int ? price : (price as double).toInt();
}

List<String> getDestinationCities(Map<String, dynamic> tourData) {
  final cities = tourData['destinationCities'] ?? tourData['turungidecegiSehir'];
  if (cities is List) {
    return cities.map((c) => c.toString()).toList();
  }
  return [];
}

String getAgencyId(Map<String, dynamic> tourData) {
  return tourData['agencyId'] ?? tourData['acenta_id'] ?? '';
}
```

#### 4. Acente Tur Sayısı (Yeni Yapı)

```dart
// ✅ DOĞRU - Yeni yapı
Future<int> getAgencyTourCount(String agencyId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('tours')
      .where('agencyId', isEqualTo: agencyId) // ✅ YENİ
      .get();
  
  return snapshot.docs.length;
}

// ❌ YANLIŞ - Eski yapı (KULLANMAYIN)
Future<int> getAgencyTourCountOld(String agencyId) async {
  int totalCount = 0;
  
  // 9 farklı koleksiyondan sayma - artık gerek yok!
  final collections = [
    'populer_turlar', 'avrupa_turlari', 'deniz_tatilleri',
    // ... diğer koleksiyonlar
  ];
  
  for (final collection in collections) {
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('acenta_id', isEqualTo: agencyId) // ❌ ESKİ
        .get();
    totalCount += snapshot.docs.length;
  }
  
  return totalCount;
}
```

#### 5. Rezervasyon Oluşturma (Yeni Yapı)

```dart
// ✅ DOĞRU - Yeni yapı
Future<void> createReservation({
  required String userId,
  required String tourId,
  required Map<String, dynamic> tourData,
  required int adultCount,
  required int childCount,
}) async {
  final reservationData = {
    'userId': userId,
    'tourId': tourId,
    'tourTitle': tourData['title'] ?? tourData['tur_adi'], // Backward compatibility
    'companyId': tourData['agencyId'] ?? tourData['acenta_id'], // ✅ YENİ
    'companyName': tourData['agencyName'] ?? tourData['acenta_adi'],
    'tourStartDate': tourData['startDate'] ?? tourData['tarih'],
    'adultCount': adultCount,
    'childCount': childCount,
    'totalPassengers': adultCount + childCount,
    'pricePerPerson': tourData['pricePerPerson'] ?? tourData['fiyat'], // ✅ YENİ
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  };
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('reservations') // ✅ YENİ (subcollection)
      .add(reservationData);
}
```

### JavaScript/Admin Examples

#### 1. Toplu Migrasyon Script'i

```javascript
// Admin SDK kullanarak eski koleksiyonlardan yeni yapıya migrasyon
const admin = require('firebase-admin');
const db = admin.firestore();

async function migrateTours() {
  const oldCollections = [
    'populer_turlar',
    'avrupa_turlari',
    'deniz_tatilleri',
    // ... diğer koleksiyonlar
  ];
  
  const categoryMapping = {
    'populer_turlar': 'popular',
    'avrupa_turlari': 'europe',
    'deniz_tatilleri': 'sea_vacation',
    // ... diğer mappingler
  };
  
  for (const oldCollection of oldCollections) {
    const snapshot = await db.collection(oldCollection).get();
    
    for (const doc of snapshot.docs) {
      const oldData = doc.data();
      
      // Yeni field yapısına çevir
      const newData = {
        tourId: doc.id,
        title: oldData.tur_adi,
        category: categoryMapping[oldCollection],
        pricePerPerson: oldData.fiyat,
        maxCapacity: oldData.kapasite,
        availableSeats: oldData.kalan_kontenjan || oldData.kapasite,
        startDate: oldData.tarih,
        agencyId: oldData.acenta_id,
        agencyName: oldData.acenta_adi,
        destinationCities: oldData.turungidecegiSehir || [],
        transportationType: oldData.yolculuk_turu,
        images: oldData.resimURLleri || oldData.imageUrls || [],
        coverImage: oldData.thumbnailUrl || oldData.coverImage,
        itinerary: oldData.turDetaylari || oldData.gunlukProgram || [],
        includedServices: oldData.fiyataDahilHizmetler || [],
        excludedServices: oldData.fiyataDahilOlmayanHizmetler || [],
        busStops: oldData.otobus_duraklari || [],
        description: oldData.aciklama,
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // ... diğer fieldlar
      };
      
      // Yeni tours koleksiyonuna ekle
      await db.collection('tours').doc(doc.id).set(newData);
      
      console.log(`✅ Migrated: ${doc.id} from ${oldCollection}`);
    }
  }
  
  console.log('🎉 Migration completed!');
}
```

#### 2. Kullanıcı Bilgileri Migrasyon

```javascript
async function migrateUserInfo() {
  const usersSnapshot = await db.collection('users').get();
  
  for (const userDoc of usersSnapshot.docs) {
    // Eski yapıdan oku
    const oldBilgiler = await userDoc.ref
      .collection('kullanici_bilgileri')
      .doc('bilgiler')
      .get();
    
    const oldAcenteBilgileri = await userDoc.ref
      .collection('kullanici_bilgileri')
      .doc('acente_bilgileri')
      .get();
    
    // Yeni yapıya yaz
    if (oldBilgiler.exists) {
      await userDoc.ref
        .collection('user_info') // ✅ YENİ
        .doc('bilgiler')
        .set(oldBilgiler.data());
    }
    
    if (oldAcenteBilgileri.exists) {
      await userDoc.ref
        .collection('user_info') // ✅ YENİ
        .doc('acente_bilgileri')
        .set(oldAcenteBilgileri.data());
    }
    
    console.log(`✅ Migrated user: ${userDoc.id}`);
  }
}
```

---

## 🔍 Sorgu Örnekleri (Admin Panel için)

### 1. Tüm Turları Listele

```javascript
const tours = await db.collection('tours')
  .orderBy('createdAt', 'desc')
  .limit(50)
  .get();
```

### 2. Kategori Bazlı Turlar

```javascript
const popularTours = await db.collection('tours')
  .where('category', '==', 'popular')
  .where('isActive', '==', true)
  .get();
```

### 3. Acente Turları

```javascript
const agencyTours = await db.collection('tours')
  .where('agencyId', '==', 'AGENCY_USER_ID')
  .orderBy('startDate', 'asc')
  .get();
```

### 4. Fiyat Aralığı

```javascript
const midRangeTours = await db.collection('tours')
  .where('pricePerPerson', '>=', 1000)
  .where('pricePerPerson', '<=', 5000)
  .get();
```

### 5. Müsait Turlar

```javascript
const availableTours = await db.collection('tours')
  .where('availableSeats', '>', 0)
  .where('startDate', '>', new Date())
  .where('isActive', '==', true)
  .get();
```

### 6. Kullanıcı Rezervasyonları

```javascript
const userReservations = await db.collection('users')
  .doc(userId)
  .collection('reservations')
  .orderBy('createdAt', 'desc')
  .get();
```

### 7. Acente Bilgileri

```javascript
const agencyInfo = await db.collection('users')
  .doc(userId)
  .collection('user_info') // ✅ YENİ
  .doc('acente_bilgileri')
  .get();
```

### 8. Tur Yorumları

```javascript
// Belirli bir tura ait yorumlar
const tourReviews = await db.collectionGroup('degerlendirmeler')
  .where('tourId', '==', 'TOUR_ID')
  .where('isApproved', '==', true)
  .orderBy('createdAt', 'desc')
  .get();
```

---

## ⚠️ Önemli Notlar

### 1. Backward Compatibility
- Mevcut kodda **hem eski hem yeni field'ler** kontrol edilmelidir
- Örnek: `data['title'] ?? data['tur_adi'] ?? 'Varsayılan'`
- Bu yaklaşım, migrasyon sürecinde hata riskini azaltır

### 2. Migration Strategy
- Önce **READ işlemlerini** güncelleyin (backward compatible)
- Ardından **WRITE işlemlerini** yeni yapıya çevirin
- Eski koleksiyonları hemen silmeyin, bir süre saklayın
- Migration script'lerini test ortamında deneyin

### 3. Index Requirements
Firestore'da aşağıdaki indeksler oluşturulmalı:

```
tours:
  - category + isActive + startDate (ASC)
  - agencyId + startDate (ASC)
  - pricePerPerson (ASC) + availableSeats (DESC)
  - category + pricePerPerson (ASC)

users/{userId}/reservations:
  - status + createdAt (DESC)
  - tourStartDate (ASC)
```

### 4. Security Rules Önerisi

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Tours - Herkes okuyabilir, sadece acente/admin yazabilir
    match /tours/{tourId} {
      allow read: if true;
      allow write: if request.auth != null && 
        (request.auth.token.userType == 'agency' || 
         request.auth.token.userType == 'admin');
    }
    
    // Users - Kullanıcı sadece kendi verisini okuyabilir/yazabilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /user_info/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /reservations/{reservationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /degerlendirmeler/{reviewId} {
        allow read: if true;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Kampanyalar - Herkes okuyabilir, sadece admin yazabilir
    match /kampanyalar/{campaignId} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.token.userType == 'admin';
    }
  }
}
```

### 5. Admin Panel için Öneriler

Admin panelinde yapılması gerekenler:

1. **Dashboard**
   - Toplam tur sayısı: `tours` koleksiyonundan
   - Kategori bazlı dağılım: `category` field'ına göre group by
   - Aktif acente sayısı: `users` → `user_info/acente_bilgileri`

2. **Tur Yönetimi**
   - Tur listesi: `tours` koleksiyonundan çek
   - Tur ekleme/düzenleme: Yeni field yapısını kullan
   - Kategori seçimi: Dropdown'da yeni kategori değerlerini göster

3. **Acente Yönetimi**
   - Acente listesi: `users` → `user_info/acente_bilgileri`
   - Acente turları: `tours` koleksiyonunda `agencyId` filtresi

4. **Rezervasyon Yönetimi**
   - Tüm rezervasyonlar için: `collectionGroup('reservations')` kullan
   - Kullanıcı bazlı: `users/{userId}/reservations`

---

## 📞 Destek

Sorularınız için:
- **Email:** support@banatuur.com
- **Dokümantasyon:** Bu dosya
- **Son Güncellenme:** 28 Ekim 2025

---

## 📝 Versiyon Geçmişi

| Versiyon | Tarih | Değişiklikler |
|----------|-------|--------------|
| 2.0.0 | 28 Ekim 2025 | Yeni unified yapı (tours/ collection) |
| 1.5.0 | - | user_info/ yapısına geçiş |
| 1.0.0 | - | İlk eski yapı (9 ayrı collection) |

---

**🎯 ÖNEMLİ:** Admin projenizde tüm kod güncellemelerinde bu dökümanı referans alın. Eski yapı (populer_turlar, avrupa_turlari, vs.) artık kullanılmıyor!
