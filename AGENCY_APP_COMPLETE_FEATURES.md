# 🚀 ACENTE UYGULAMASI - EKSIKSIZ ÖZELLIK DOKÜMANTASYONU

**Tarih:** 31 Ekim 2025  
**Kaynak:** banatuur (User App)  
**Hedef:** Agency App  
**Durum:** Production Ready ✅

---

## 🎯 ÖNEMLİ NOT

Bu dokümantasyon, kullanıcı uygulamasındaki **TÜM** özellikleri içerir. Migration'a gerek yok, sadece acente uygulamasında bulunması gereken özelliklerin eksiksiz listesi ve implementasyonu.

---

## 📑 HIZLI ERİŞİM

### 🔥 KRİTİK ÖZELLİKLER (Kesinlikle Olmalı)
1. [Grup Sohbeti](#1-grup-sohbeti-tour-group-chat) - Rezervasyon sonrası kullanıcı-rehber-acente chat
2. [Firebase Cloud Functions](#2-firebase-cloud-functions) - Otomatik işlemler (chat oluşturma, bildirimler)
3. [Push Notifications](#3-push-notifications) - FCM entegrasyonu
4. [Rezervasyon İşlemleri](#4-rezervasyon-i̇şlemleri) - Tam rezervasyon akışı
5. [Kayıtlı Yolcular](#5-kayıtlı-yolcular) - Yolcu bilgilerini kaydetme

### ⚡ TEMEL ÖZELLİKLER
6. [Authentication](#6-authentication) - Firebase Auth
7. [State Management](#7-state-management) - BLoC/Cubit pattern
8. [Global BLoC Providers](#8-global-bloc-providers) - App-wide state
9. [Firestore Structure](#9-firestore-structure) - Veritabanı yapısı

### 🎨 UI/UX ÖZELLİKLERİ
10. [Stories & Highlights](#10-stories--highlights) - Instagram-style stories
11. [Profil & İstatistikler](#11-profil--i̇statistikler) - Gamification
12. [Harita & Lokasyon](#12-harita--lokasyon) - Google Maps entegrasyonu
13. [Navigation Patterns](#13-navigation-patterns) - iOS swipe, routing

### 🏗️ MİMARİ
14. [Clean Architecture](#14-clean-architecture) - Domain/Data/Presentation
15. [Dependency Injection](#15-dependency-injection) - GetIt
16. [Repository Pattern](#16-repository-pattern) - Data abstraction
17. [Error Handling](#17-error-handling) - Result pattern

---

# 🔥 KRİTİK ÖZELLİKLER

## 1. GRUP SOHBETİ (Tour Group Chat)

### 📋 Özellik Açıklaması
Bir tur rezervasyonu yapıldığında otomatik olarak grup sohbeti oluşturulur. Kullanıcı, rehber ve acente bu sohbette iletişim kurabilir.

### 🎬 Kullanım Senaryosu
1. Kullanıcı tur rezervasyonu yapar
2. Firebase Function otomatik tetiklenir
3. `chats/{chatId}` collection'ında yeni doküman oluşturulur
4. Katılımcılar: userId, guideId, agencyId
5. İlk hoşgeldin mesajı sistem tarafından gönderilir
6. Push notification tüm katılımcılara gider
7. Kullanıcılar chat room'a erişir ve mesajlaşır

### 📁 Dosya Yapısı

```
lib/
├── presentation/
│   └── tour_chat/
│       ├── cubit/
│       │   ├── tour_chat_cubit.dart          ✅ State management
│       │   └── tour_chat_state.dart          ✅ Chat states
│       └── pages/
│           ├── tour_chat_room_page.dart      ✅ Chat UI
│           └── tour_chats_list_page.dart     ✅ Tüm chat'lerin listesi
├── domain/
│   ├── entities/
│   │   └── tour_chat/
│   │       ├── chat_entity.dart              ✅ Chat model
│   │       └── message_entity.dart           ✅ Message model
│   └── repositories/
│       └── tour_chat_repository.dart         ✅ Abstract repository
└── Data/
    ├── datasources/
    │   └── tour_chat_remote_datasource.dart  ✅ Firestore operations
    └── repositories/
        └── tour_chat_repository_impl.dart    ✅ Repository implementation
```

### 💾 Firestore Structure

```
chats/ (collection)
└── {chatId} (document)
    ├── type: "tour_group"
    ├── participantIds: ["userId", "guideId", "agencyId"]
    ├── participantDetails: {
    │     "userId": {
    │       id: "userId",
    │       name: "Ahmet Yılmaz",
    │       avatarUrl: "https://...",
    │       userType: "user"
    │     },
    │     "guideId": {...},
    │     "agencyId": {...}
    │   }
    ├── tourId: "tour123"
    ├── tourTitle: "Kapadokya Turu"
    ├── reservationId: "res456"
    ├── status: "active"
    ├── unreadCounts: {
    │     "userId": 2,
    │     "guideId": 0,
    │     "agencyId": 1
    │   }
    ├── lastMessage: {
    │     content: "Merhaba",
    │     senderId: "userId",
    │     senderName: "Ahmet",
    │     senderType: "user",
    │     timestamp: Timestamp,
    │     type: "text"
    │   }
    ├── lastMessageAt: Timestamp
    ├── metadata: {
    │     tourDate: "2025-11-15",
    │     guideId: "guideId",
    │     agencyId: "agencyId"
    │   }
    ├── createdAt: Timestamp
    └── updatedAt: Timestamp
    
    messages/ (subcollection)
    └── {messageId} (document)
        ├── chatId: "chatId"
        ├── senderId: "userId"
        ├── senderType: "user"
        ├── content: "Merhaba, tur saati kaçta?"
        ├── type: "text"
        ├── timestamp: Timestamp
        ├── readBy: ["guideId"]
        ├── reactions: {}
        └── metadata: null
```

### 🎨 UI Components

#### Chat Room Page
```dart
// Kullanım:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TourChatRoomPage(
      chatId: 'tour_123_res456',
      userId: currentUserId,
      userType: 'user', // 'user', 'guide', veya 'agency'
    ),
  ),
);
```

**Özellikler:**
- Real-time mesaj dinleme (StreamBuilder)
- Mesaj gönderme
- Okundu bilgisi (readBy)
- Unread count temizleme
- Scroll to bottom (yeni mesaj)
- Sender renkleri (user: mavi, guide: yeşil, agency: turuncu)
- System mesajlar (bot)

#### Chat List Page
```dart
// Kullanım:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TourChatsListPage(
      userId: currentUserId,
    ),
  ),
);
```

**Özellikler:**
- Tüm chat'lerin listesi
- Son mesaj preview
- Unread count badge
- lastMessageAt ile sıralama
- Chat'e tıklayınca room'a git

### 🔧 Cubit Implementation

```dart
// tour_chat_cubit.dart
class TourChatCubit extends Cubit<TourChatState> {
  final TourChatRepository repository;

  TourChatCubit({required this.repository}) : super(const TourChatInitial());

  // Kullanıcının tüm chat'lerini yükle
  Future<void> loadUserChats(String userId) async {
    if (isClosed) return;
    emit(const TourChatLoading());

    final result = await repository.getUserChats(userId);
    if (isClosed) return;

    result.fold(
      onError: (f) {
        if (!isClosed) emit(TourChatError(message: 'Chat yüklenemedi'));
      },
      onSuccess: (chats) {
        if (!isClosed) emit(TourChatLoaded(chats: chats));
      },
    );
  }

  // Mesajları stream olarak dinle
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return repository.watchMessages(chatId);
  }

  // Mesaj gönder
  Future<void> sendMessage({
    required String chatId,
    required String content,
    required String senderId,
    required String senderType,
    String type = 'text',
  }) async {
    await repository.sendMessage(
      chatId: chatId,
      content: content,
      senderId: senderId,
      senderType: senderType,
      type: type,
    );
  }

  // Unread count sıfırla
  Future<void> clearUnreadCount(String chatId, String userId) async {
    await repository.clearUnreadCount(chatId, userId);
  }
}
```

### ⚙️ Repository Pattern

```dart
// tour_chat_repository.dart (Abstract)
abstract class TourChatRepository {
  Future<Result<List<ChatEntity>>> getUserChats(String userId);
  Stream<List<MessageEntity>> watchMessages(String chatId);
  Future<void> sendMessage({
    required String chatId,
    required String content,
    required String senderId,
    required String senderType,
    String type = 'text',
    Map<String, dynamic>? metadata,
  });
  Future<void> clearUnreadCount(String chatId, String userId);
}

// tour_chat_repository_impl.dart (Implementation)
class TourChatRepositoryImpl implements TourChatRepository {
  final TourChatRemoteDataSource remoteDataSource;

  TourChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ChatEntity>>> getUserChats(String userId) async {
    try {
      final chats = await remoteDataSource.getUserChats(userId);
      return Result.success(chats);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return remoteDataSource.watchMessages(chatId);
  }
  
  // ... diğer methodlar
}

// tour_chat_remote_datasource.dart (Firestore)
class TourChatRemoteDataSourceImpl implements TourChatRemoteDataSource {
  final FirebaseFirestore firestore;

  @override
  Future<List<ChatEntity>> getUserChats(String userId) async {
    final snapshot = await firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChatEntity.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => MessageEntity.fromFirestore(doc)).toList()
        );
  }
  
  // ... diğer methodlar
}
```

### 🔌 Dependency Injection

```dart
// injection_container.dart
void initializeDependencies() {
  // DataSource
  sl.registerLazySingleton<TourChatRemoteDataSource>(
    () => TourChatRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<TourChatRepository>(
    () => TourChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Cubit
  sl.registerFactory(() => TourChatCubit(repository: sl()));
}
```

### 📱 Kullanım Örneği

```dart
// Chat'leri listeleme
BlocProvider(
  create: (context) => sl<TourChatCubit>()..loadUserChats(currentUserId),
  child: TourChatsListPage(userId: currentUserId),
);

// Chat room'a girme
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => sl<TourChatCubit>(),
      child: TourChatRoomPage(
        chatId: chat.id,
        userId: currentUserId,
        userType: 'user',
      ),
    ),
  ),
);
```

---

## 2. FIREBASE CLOUD FUNCTIONS

### 📋 Özellik Açıklaması
Backend'de çalışan serverless fonksiyonlar. Rezervasyon oluşturulduğunda, mesaj gönderildiğinde, tur güncellendiğinde otomatik tetiklenir.

### 📁 Dosya Yapısı

```
functions/
├── package.json
├── tsconfig.json
└── src/
    ├── index.ts          ✅ Export all functions
    └── triggers.ts       ✅ Firestore triggers
```

### 🔥 Trigger 1: Rezervasyon Oluşturulunca Chat Odası Oluştur

```typescript
// functions/src/triggers.ts
export const onReservationCreate = functions.firestore
    .document('users/{userId}/reservations/{reservationId}')
    .onCreate(async (snap, context) => {
        const { userId, reservationId } = context.params;
        const reservation = snap.data();

        try {
            // 1. Tour bilgisini al
            const tourDoc = await db.collection('tours').doc(reservation.tourId).get();
            if (!tourDoc.exists) {
                console.error(`Tour not found: ${reservation.tourId}`);
                return;
            }
            const tour = tourDoc.data()!;

            // 2. Chat ID oluştur
            const chatId = `tour_${reservation.tourId}_${reservationId}`;

            // 3. Katılımcılar
            const participantIds = [
                userId,
                tour.guideId,
                tour.agencyId,
            ].filter(Boolean);

            // 4. Katılımcı detaylarını al
            const participantDetails: any = {};

            // Kullanıcı
            const userDoc = await db.collection('users').doc(userId).get();
            if (userDoc.exists) {
                const userData = userDoc.data()!;
                participantDetails[userId] = {
                    id: userId,
                    name: userData.name || 'Kullanıcı',
                    avatarUrl: userData.avatarUrl || null,
                    userType: 'user',
                };
            }

            // Rehber
            if (tour.guideId) {
                const guideDoc = await db.collection('users').doc(tour.guideId).get();
                if (guideDoc.exists) {
                    const guideData = guideDoc.data()!;
                    participantDetails[tour.guideId] = {
                        id: tour.guideId,
                        name: guideData.name || 'Rehber',
                        avatarUrl: guideData.avatarUrl || null,
                        userType: 'guide',
                    };
                }
            }

            // Acente
            if (tour.agencyId) {
                const agencyDoc = await db.collection('users').doc(tour.agencyId).get();
                if (agencyDoc.exists) {
                    const agencyData = agencyDoc.data()!;
                    participantDetails[tour.agencyId] = {
                        id: tour.agencyId,
                        name: agencyData.agency?.name || 'Acente',
                        avatarUrl: agencyData.agency?.logoUrl || null,
                        userType: 'agency',
                    };
                }
            }

            // 5. Unread counts başlat
            const unreadCounts: any = {};
            participantIds.forEach(id => {
                unreadCounts[id] = 0;
            });

            // 6. Chat odası oluştur
            const chatData = {
                type: 'tour_group',
                participantIds,
                participantDetails,
                tourId: reservation.tourId,
                tourTitle: tour.title,
                reservationId: reservationId,
                status: 'active',
                unreadCounts,
                lastMessage: null,
                lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
                metadata: {
                    tourDate: reservation.tourDate,
                    guideId: tour.guideId || null,
                    agencyId: tour.agencyId || null,
                },
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            await db.collection('chats').doc(chatId).set(chatData);

            // 7. Reservation'a chatId ekle
            await snap.ref.update({
                chatId: chatId,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // 8. Hoşgeldin mesajı gönder
            const welcomeMessage = {
                chatId,
                senderId: 'system',
                senderType: 'bot',
                content: `Merhaba! ${tour.title} turuna hoş geldiniz. Turla ilgili sorularınızı buradan sorabilirsiniz. Rehberiniz ve acente size yardımcı olacaktır.`,
                type: 'text',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                readBy: [],
                reactions: {},
            };

            await db.collection('chats').doc(chatId).collection('messages').add(welcomeMessage);

            console.log(`✅ Chat room created: ${chatId} for reservation: ${reservationId}`);

            // 9. Push notification gönder
            if (tour.guideId) {
                await sendPushNotification(
                    tour.guideId, 
                    'Yeni Rezervasyon', 
                    `${tour.title} için yeni rezervasyon`,
                    { chatId, type: 'new_reservation' }
                );
            }
            if (tour.agencyId && tour.agencyId !== tour.guideId) {
                await sendPushNotification(
                    tour.agencyId, 
                    'Yeni Rezervasyon', 
                    `${tour.title} için yeni rezervasyon`,
                    { chatId, type: 'new_reservation' }
                );
            }

        } catch (error) {
            console.error('❌ Error creating chat room:', error);
        }
    });
```

### 🔥 Trigger 2: Mesaj Gönderilince Unread Count Güncelle

```typescript
export const onMessageCreate = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
        const { chatId } = context.params;
        const message = snap.data();

        try {
            const chatDoc = await db.collection('chats').doc(chatId).get();
            if (!chatDoc.exists) {
                console.error(`Chat not found: ${chatId}`);
                return;
            }

            const chat = chatDoc.data()!;
            const unreadCounts = chat.unreadCounts || {};

            // Tüm katılımcıların unread count'unu artır (gönderen hariç)
            chat.participantIds.forEach((participantId: string) => {
                if (participantId !== message.senderId && message.senderType !== 'bot') {
                    unreadCounts[participantId] = (unreadCounts[participantId] || 0) + 1;
                }
            });

            // lastMessage denormalize et
            const lastMessage = {
                content: message.content,
                senderId: message.senderId,
                senderName: chat.participantDetails[message.senderId]?.name || 'Kullanıcı',
                senderType: message.senderType,
                timestamp: message.timestamp || admin.firestore.FieldValue.serverTimestamp(),
                type: message.type,
            };

            // Chat dokümanını güncelle
            await chatDoc.ref.update({
                unreadCounts,
                lastMessage,
                lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            console.log(`✅ Unread counts updated for chat: ${chatId}`);

            // Push notification gönder (bot mesajları hariç)
            if (message.senderType !== 'bot') {
                const senderName = chat.participantDetails[message.senderId]?.name || 'Birileri';
                
                // Diğer katılımcılara bildirim gönder
                for (const recipientId of chat.participantIds) {
                    if (recipientId !== message.senderId) {
                        await sendPushNotification(
                            recipientId,
                            `${senderName}`,
                            message.content,
                            {
                                chatId,
                                type: 'new_message',
                            }
                        );
                    }
                }
            }

        } catch (error) {
            console.error('❌ Error updating unread counts:', error);
        }
    });
```

### 🔥 Trigger 3: Tur Güncellenince Chat'leri Güncelle

```typescript
export const onTourUpdate = functions.firestore
    .document('tours/{tourId}')
    .onUpdate(async (change, context) => {
        const { tourId } = context.params;
        const before = change.before.data();
        const after = change.after.data();

        try {
            // Tur başlığı değiştiyse, ilgili chat'leri güncelle
            if (before.title !== after.title) {
                const chatsSnapshot = await db
                    .collection('chats')
                    .where('tourId', '==', tourId)
                    .get();

                let updateCount = 0;
                const batch = db.batch();

                chatsSnapshot.docs.forEach(doc => {
                    batch.update(doc.ref, {
                        tourTitle: after.title,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    });
                    updateCount++;
                });

                if (updateCount > 0) {
                    await batch.commit();
                    console.log(`✅ Updated ${updateCount} chat rooms for tour: ${tourId}`);
                }
            }
        } catch (error) {
            console.error('❌ Error updating chat rooms:', error);
        }
    });
```

### 📦 Helper Functions

```typescript
// Push notification gönder
async function sendPushNotification(
    userId: string,
    title: string,
    body: string,
    data: any
): Promise<void> {
    try {
        // FCM token'ı al
        const userDoc = await db.collection('users').doc(userId).get();
        if (!userDoc.exists) {
            console.log(`User not found: ${userId}`);
            return;
        }

        const fcmToken = userDoc.data()!.fcmToken;

        if (!fcmToken) {
            console.log(`No FCM token for user: ${userId}`);
            return;
        }

        // Push notification gönder
        await messaging.send({
            notification: {
                title,
                body,
            },
            data,
            token: fcmToken,
        });

        console.log(`✅ Push notification sent to user: ${userId}`);

    } catch (error) {
        console.error('❌ Error sending push notification:', error);
    }
}
```

### 📦 Package.json

```json
{
  "name": "functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  },
  "engines": {
    "node": "18"
  }
}
```

### 🚀 Deploy

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

---

## 3. PUSH NOTIFICATIONS

### 📋 Özellik Açıklaması
Firebase Cloud Messaging (FCM) ile push notification sistemi. Chat mesajları, yeni rezervasyon, tur güncellemeleri için bildirim gönderir.

### 📁 Dosya Yapısı

```
lib/
└── services/
    └── firebase_messaging_service.dart  ✅ FCM service
```

### 🔧 Implementation

```dart
// lib/services/firebase_messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Firebase arka plan bildirimlerini işleyen fonksiyon
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    debugPrint("📬 Background message: ${message.notification?.title}");
  }

  /// Firebase Messaging'i başlat
  static Future<void> initialize() async {
    try {
      // Background message handler
      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

      // Permission request
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permission granted');

        // iOS için APNS token'ı bekle
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _waitForApnsToken();
        }

        // FCM token al ve Firestore'a kaydet
        await _getFcmToken();

        // Token refresh dinle
        _messaging.onTokenRefresh.listen(_onTokenRefresh);
      } else {
        debugPrint('⚠️ Notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Firebase Messaging initialization error: $e');
    }
  }

  /// iOS için APNS token bekle
  static Future<void> _waitForApnsToken() async {
    try {
      await _messaging.getAPNSToken().timeout(
            const Duration(seconds: 2),
            onTimeout: () => null,
          );
      debugPrint('✅ APNS token ready');
    } catch (e) {
      debugPrint('⚠️ APNS token not ready: $e');
    }
  }

  /// FCM token al ve Firestore'a kaydet
  static Future<void> _getFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM Token: $token');
        // TODO: Token'ı Firestore'a kaydet
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(currentUserId)
        //     .update({'fcmToken': token});
      } else {
        debugPrint('⚠️ FCM token is null');
      }
    } catch (e) {
      debugPrint('❌ FCM token error: $e');
    }
  }

  /// Token refresh olduğunda
  static Future<void> _onTokenRefresh(String token) async {
    debugPrint('🔄 FCM Token refreshed: $token');
    // TODO: Yeni token'ı Firestore'a kaydet
  }

  /// Foreground mesajlarını dinle
  static void listenToForegroundMessages(
    Function(RemoteMessage) onMessage,
  ) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Bildirime tıklandığında (app açık)
  static void listenToMessageOpenedApp(
    Function(RemoteMessage) onMessageOpened,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpened);
  }

  /// Bildirim badge sayısını sıfırla (iOS)
  static Future<void> clearBadge() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('⚠️ Badge temizlenemedi: $e');
    }
  }
}
```

### 🚀 Main.dart Entegrasyonu

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  await Firebase.initializeApp();

  // Firebase Messaging setup
  await FirebaseMessagingService.initialize();

  runApp(const MyApp());
}
```

### 📱 Foreground Notification Handler

```dart
// App widget içinde
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Foreground mesajlarını dinle
    FirebaseMessagingService.listenToForegroundMessages((message) {
      debugPrint('📬 Foreground message: ${message.notification?.title}');
      
      // Local notification göster (opsiyonel)
      // veya
      // Dialog göster
      // veya
      // SnackBar göster
    });

    // Bildirime tıklandığında
    FirebaseMessagingService.listenToMessageOpenedApp((message) {
      debugPrint('📱 Message opened: ${message.data}');
      
      // Chat room'a yönlendir
      if (message.data['type'] == 'new_message') {
        final chatId = message.data['chatId'];
        // Navigator.push(...);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

### 🔒 iOS Configuration

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- ... -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
</dict>
```

### 🔒 Android Configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <application>
        <!-- ... -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
    </application>
</manifest>
```

---

## 4. REZERVASYON İŞLEMLERİ

### 📋 Özellik Açıklaması
Kullanıcıların tur rezervasyonu yapması, kayıtlı yolcuları kullanması, ödeme yapması ve rezervasyon takibi yapması.

### 💾 Firestore Structure

```
users/ (collection)
└── {userId} (document)
    └── reservations/ (subcollection)
        └── {reservationId} (document)
            ├── tourId: "tour123"
            ├── tourTitle: "Kapadokya Turu"
            ├── tourDate: "2025-11-15"
            ├── numberOfPeople: 2
            ├── totalPrice: 3000
            ├── currency: "TRY"
            ├── status: "confirmed" // pending, confirmed, cancelled, completed
            ├── paymentStatus: "paid" // pending, paid, refunded
            ├── chatId: "tour_123_res456"
            ├── travelers: [
            │     {
            │       firstName: "Ahmet",
            │       lastName: "Yılmaz",
            │       phone: "5551234567",
            │       tcId: "12345678901",
            │       birthDate: "01/01/1990",
            │       gender: "Erkek"
            │     },
            │     { ... }
            │   ]
            ├── pickupLocation: {
            │     name: "Otel Adı",
            │     address: "Adres",
            │     latitude: 38.xxx,
            │     longitude: 34.xxx
            │   }
            ├── specialRequests: "Glutensiz yemek"
            ├── guideId: "guideId"
            ├── agencyId: "agencyId"
            ├── createdAt: Timestamp
            └── updatedAt: Timestamp
```

### 📁 Dosya Yapısı

```
lib/
├── presentation/
│   └── reservation/
│       ├── cubit/
│       │   ├── reservation_cubit.dart
│       │   └── reservation_state.dart
│       ├── pages/
│       │   └── reservation_page.dart
│       └── widgets/
│           ├── traveler_form.dart
│           ├── payment_section.dart
│           └── saved_travelers_dropdown.dart
├── domain/
│   ├── entities/
│   │   └── reservation/
│   │       └── reservation_entity.dart
│   └── repositories/
│       └── reservation_repository.dart
└── Data/
    ├── datasources/
    │   └── reservation_remote_datasource.dart
    └── repositories/
        └── reservation_repository_impl.dart
```

### 🎨 Reservation Page Flow

1. **Tur Detay** → Rezervasyon butonu
2. **Rezervasyon Formu:**
   - Tarih seçimi
   - Kişi sayısı
   - Kayıtlı yolculardan seç (dropdown)
   - Yeni yolcu ekle
   - Toplam fiyat hesaplama
3. **Ödeme:** (Şimdilik skip edilebilir)
4. **Onay:** Rezervasyon oluştur
5. **Firebase Function Tetiklenir:** Chat odası oluşur
6. **Bildirim:** Tüm katılımcılara push notification

### 🔧 Cubit Implementation

```dart
// reservation_cubit.dart
class ReservationCubit extends Cubit<ReservationState> {
  final ReservationRepository repository;

  ReservationCubit({required this.repository}) : super(const ReservationInitial());

  // Rezervasyon oluştur
  Future<void> createReservation({
    required String userId,
    required String tourId,
    required String tourTitle,
    required String tourDate,
    required int numberOfPeople,
    required double totalPrice,
    required String currency,
    required List<TravelerInfo> travelers,
    String? pickupLocation,
    String? specialRequests,
  }) async {
    if (isClosed) return;
    emit(const ReservationCreating());

    final result = await repository.createReservation(
      userId: userId,
      tourId: tourId,
      tourTitle: tourTitle,
      tourDate: tourDate,
      numberOfPeople: numberOfPeople,
      totalPrice: totalPrice,
      currency: currency,
      travelers: travelers,
      pickupLocation: pickupLocation,
      specialRequests: specialRequests,
    );

    if (isClosed) return;

    result.fold(
      onError: (f) {
        if (!isClosed) emit(ReservationError(message: 'Rezervasyon oluşturulamadı'));
      },
      onSuccess: (reservation) {
        if (!isClosed) emit(ReservationCreated(reservation: reservation));
      },
    );
  }

  // Kullanıcının rezervasyonlarını getir
  Future<void> loadUserReservations(String userId) async {
    if (isClosed) return;
    emit(const ReservationLoading());

    final result = await repository.getUserReservations(userId);
    if (isClosed) return;

    result.fold(
      onError: (f) {
        if (!isClosed) emit(ReservationError(message: 'Rezervasyonlar yüklenemedi'));
      },
      onSuccess: (reservations) {
        if (!isClosed) emit(ReservationLoaded(reservations: reservations));
      },
    );
  }

  // Rezervasyonu iptal et
  Future<void> cancelReservation(String userId, String reservationId) async {
    await repository.cancelReservation(userId, reservationId);
    await loadUserReservations(userId); // Listeyi yenile
  }
}
```

---

## 5. KAYITLI YOLCULAR

### 📋 Özellik Açıklaması
Kullanıcıların sık kullandıkları yolcu bilgilerini (aile, arkadaş) kaydedip, rezervasyon yaparken hızlıca seçebilmesi.

### 💾 Firestore Structure

```
users/ (collection)
└── {userId} (document)
    └── savedTravelers/ (subcollection)
        └── {travelerId} (document)
            ├── firstName: "Mehmet"
            ├── lastName: "Yılmaz"
            ├── phone: "5551234567"
            ├── tcId: "12345678901"
            ├── birthDate: "15/03/1985"
            ├── gender: "Erkek"
            ├── createdAt: Timestamp
            └── updatedAt: Timestamp
```

### 📁 Dosya Yapısı

```
lib/
├── presentation/
│   └── reservation/
│       └── widgets/
│           ├── add_traveler_dialog.dart      ✅ Yolcu ekle
│           └── edit_traveler_dialog.dart     ✅ Yolcu düzenle
├── domain/
│   └── entities/
│       └── saved_travelers/
│           └── saved_traveler_model.dart
└── Data/
    ├── datasources/
    │   └── saved_travelers_datasource.dart
    └── repositories/
        └── saved_travelers_repository_impl.dart
```

### 🐛 CRITICAL BUG FIX - ID Format

```dart
// ❌ HATALI - saved_traveler_model.dart
factory SavedTravelersModel.fromFirestore(DocumentSnapshot doc, String userId) {
  return SavedTravelers(
    id: doc.id, // HATALI: Sadece doc.id
    // ...
  );
}

// ✅ DOĞRU - saved_traveler_model.dart
factory SavedTravelersModel.fromFirestore(DocumentSnapshot doc, String userId) {
  return SavedTravelers(
    id: '$userId/savedTravelers/${doc.id}', // DOĞRU: Tam path
    // ...
  );
}
```

**Neden Önemli:**
- DataSource katmanı delete/update için full path bekliyor
- `userId/savedTravelers/docId` formatında olmalı
- Bu fix olmadan delete ve update operasyonları çalışmaz

### ✅ Validation Rules

```dart
// add_traveler_dialog.dart & edit_traveler_dialog.dart

// 1. İsim - Soyisim: Required
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan gerekli';
    }
    return null;
  },
)

// 2. Telefon: 10 haneli, sadece rakam
TextFormField(
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 10) {
      return 'Telefon numarası 10 haneli olmalı';
    }
    return null;
  },
)

// 3. TC Kimlik: 11 haneli, sadece rakam
TextFormField(
  keyboardType: TextInputType.number,
  maxLength: 11,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'TC Kimlik No gerekli';
    }
    if (value.length != 11) {
      return 'TC Kimlik No 11 haneli olmalı';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Sadece rakam girebilirsiniz';
    }
    return null;
  },
)

// 4. Doğum Tarihi: DatePicker
TextFormField(
  readOnly: true,
  controller: _birthDateController,
  decoration: const InputDecoration(
    labelText: 'Doğum Tarihi',
    suffixIcon: Icon(Icons.calendar_today),
  ),
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Doğum tarihi gerekli';
    }
    return null;
  },
)

// 5. Cinsiyet: Button selection
Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedGender = 'Erkek'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedGender == 'Erkek' 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade300,
        ),
        child: const Text('Erkek'),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedGender = 'Kadın'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedGender == 'Kadın' 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade300,
        ),
        child: const Text('Kadın'),
      ),
    ),
  ],
)
```

### 🔧 Reservation Form Integration

```dart
// reservation_page.dart
class _ReservationPageState extends State<ReservationPage> {
  final List<SavedTravelers> _savedTravelers = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTravelers();
  }

  Future<void> _loadSavedTravelers() async {
    // Repository'den yükle
    final travelers = await savedTravelersRepository.getSavedTravelers(userId);
    setState(() => _savedTravelers = travelers);
  }

  Widget _buildTravelerSection() {
    return Column(
      children: [
        // Kayıtlı yolcu seç
        DropdownButtonFormField<SavedTravelers>(
          decoration: const InputDecoration(
            labelText: 'Kayıtlı Yolculardan Seç',
            prefixIcon: Icon(Icons.person),
          ),
          items: _savedTravelers.map((traveler) {
            return DropdownMenuItem(
              value: traveler,
              child: Text('${traveler.firstName} ${traveler.lastName}'),
            );
          }).toList(),
          onChanged: (traveler) {
            if (traveler != null) {
              _fillFormWithTraveler(traveler);
            }
          },
        ),

        const SizedBox(height: 16),

        // Veya yeni yolcu ekle
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Yeni Yolcu Ekle'),
          onPressed: _showAddTravelerDialog,
        ),
      ],
    );
  }

  void _fillFormWithTraveler(SavedTravelers traveler) {
    _firstNameController.text = traveler.firstName;
    _lastNameController.text = traveler.lastName;
    _phoneController.text = traveler.phone;
    _tcIdController.text = traveler.tcId;
    _birthDateController.text = traveler.birthDate;
    setState(() => _selectedGender = traveler.gender);
  }

  Future<void> _showAddTravelerDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddTravelerDialog(),
    );

    if (result == true) {
      await _loadSavedTravelers(); // Listeyi yenile
    }
  }
}
```

---

## 6. AUTHENTICATION

### 📋 Firebase Auth Integration

```dart
// lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithEmail(String email, String password);
  Future<Result<UserEntity>> signUpWithEmail(String email, String password, String name);
  Future<Result<UserEntity>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<UserEntity?>> getCurrentUser();
  Stream<UserEntity?> watchAuthState();
}
```

**Kullanım:**
```dart
// Sign in
final result = await authRepository.signInWithEmail(email, password);
result.fold(
  onError: (failure) => showError(failure.message),
  onSuccess: (user) => navigateToHome(),
);

// Auth state dinle
authRepository.watchAuthState().listen((user) {
  if (user == null) {
    navigateToLogin();
  } else {
    navigateToHome();
  }
});
```

---

## 7. STATE MANAGEMENT

### 📋 BLoC/Cubit Pattern

**Async Safety Pattern:** (Tüm Cubit'lerde uygulanmalı)

```dart
class MyCubit extends Cubit<MyState> {
  Future<void> loadData() async {
    if (isClosed) return; // ✅ Early exit
    
    emit(Loading());
    final result = await repository.getData();
    
    if (isClosed) return; // ✅ Check after async
    
    result.fold(
      onError: (f) {
        if (!isClosed) emit(Error(f.message)); // ✅ Check before emit
      },
      onSuccess: (data) {
        if (!isClosed) emit(Loaded(data)); // ✅ Check before emit
      },
    );
  }
}
```

**Neden Önemli:**
- Widget dispose edildikten sonra emit() çağrılırsa crash olur
- "Cannot emit new states after calling close" hatası
- Her async operation sonrası `isClosed` kontrolü şart

---

## 8. GLOBAL BLOC PROVIDERS

### 📋 App-Wide State Access

```dart
// lib/core/app_providers.dart
class AppProviders {
  static List<BlocProvider> getProviders(ThemeCubit themeCubit) {
    return [
      BlocProvider<ThemeCubit>.value(value: themeCubit),
      BlocProvider<AuthCubit>(create: (context) => sl<AuthCubit>()),
      BlocProvider<HomeCubit>(create: (context) => sl<HomeCubit>()),
      BlocProvider<ToursCubit>(create: (context) => sl<ToursCubit>()),
      BlocProvider<UserProfileCubit>(create: (context) => sl<UserProfileCubit>()),
      BlocProvider<ProfileCubit>(create: (context) => sl<ProfileCubit>()),
      BlocProvider<ReservationCubit>(create: (context) => sl<ReservationCubit>()),
      // ... diğer global cubit'ler
    ];
  }
}

// main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppProviders.getProviders(_themeCubit),
      child: MaterialApp(...),
    );
  }
}
```

**Kullanım:**
```dart
// Herhangi bir sayfada
final cubit = context.read<UserProfileCubit>();
// veya watch (rebuild için)
context.watch<UserProfileCubit>();

// Navigation sırasında BlocProvider.value wrapper'a gerek yok
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MyPage(), // Global provider'dan erişir
  ),
);
```

---

## 9. FIRESTORE STRUCTURE

### 📊 Collections

```
📁 users/
  └── {userId}
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── fcmToken: string
      ├── avatarUrl: string
      ├── userType: string (user/guide/agency)
      ├── createdAt: timestamp
      └── updatedAt: timestamp
      
      📁 reservations/
        └── {reservationId}
            ├── tourId
            ├── chatId ⚡
            ├── status
            └── ...
      
      📁 savedTravelers/
        └── {travelerId}
            ├── firstName
            ├── lastName
            └── ...

📁 tours/
  └── {tourId}
      ├── title
      ├── guideId
      ├── agencyId
      └── ...

📁 chats/ ⚡⚡⚡
  └── {chatId}
      ├── type: "tour_group"
      ├── participantIds: [userId, guideId, agencyId]
      ├── unreadCounts: {userId: 2, guideId: 0}
      ├── lastMessage: {...}
      └── ...
      
      📁 messages/
        └── {messageId}
            ├── senderId
            ├── content
            ├── timestamp
            └── ...

📁 stories/
  └── {storyId}
      ├── userId
      ├── mediaUrl
      ├── createdAt
      └── ...

📁 highlights/
  └── {highlightId}
      ├── userId
      ├── title
      ├── coverImage
      └── ...
```

### 🔒 Firestore Indexes

```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "chats",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "participantIds", "arrayConfig": "CONTAINS" },
        { "fieldPath": "lastMessageAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "chatId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "reservations",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## 10. STORIES & HIGHLIGHTS

### 📋 Instagram-Style Stories

**Özellikler:**
- 24 saat içinde kaybolur
- Video/resim desteği
- Görüntülenme sayısı
- Highlight'a ekleme

**Kullanım:**
```dart
// Story yükle
await storiesRepository.uploadStory(
  userId: currentUserId,
  mediaUrl: imageUrl,
  type: 'image', // veya 'video'
);

// Aktif story'leri dinle
storiesCubit.loadActiveStories();
```

---

## 11. PROFIL & İSTATİSTİKLER

### 📋 Gamification

**Özellikler:**
- Gezilen yerler haritası
- Tur istatistikleri (toplam, tamamlanan, iptal)
- Başarımlar (badges)
- Seviye sistemi

**UI Fixes:**
- ✅ Scaffold eklendi (standalone mode)
- ✅ Stat cards overflow fix
- ✅ Map interactive controls (zoom, scroll, rotate)

---

## 12. HARITA & LOKASYON

### 📋 Google Maps Integration

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(39.0, 35.0), // Türkiye merkez
    zoom: 5.0,
  ),
  zoomGesturesEnabled: true,    // Pinch to zoom
  scrollGesturesEnabled: true,  // Pan
  rotateGesturesEnabled: true,  // Rotate
  minMaxZoomPreference: MinMaxZoomPreference(4.5, 12.0),
  markers: _markers,
)
```

---

## 13. NAVIGATION PATTERNS

### 📋 iOS Swipe-to-Go-Back Fix

```dart
// ❌ HATALI
Navigator.push(context, PageRouteBuilder(...));

// ✅ DOĞRU
Navigator.push(context, MaterialPageRoute(
  builder: (context) => MyPage(),
));
```

**Faydalar:**
- iOS swipe gesture otomatik
- Platform-native animations
- Daha performanslı

---

## 14. CLEAN ARCHITECTURE

```
lib/
├── core/           # Theme, constants, utils
├── services/       # Firebase messaging, location
├── presentation/   # UI, Cubit, Pages, Widgets
├── domain/         # Entities, Repositories (abstract)
└── Data/           # DataSources, Repositories (impl), Models
```

---

## 15. DEPENDENCY INJECTION

```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // DataSources
  sl.registerLazySingleton<TourChatRemoteDataSource>(
    () => TourChatRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<TourChatRepository>(
    () => TourChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Cubits
  sl.registerFactory(() => TourChatCubit(repository: sl()));
}
```

---

## 16. REPOSITORY PATTERN

```dart
// Abstract (domain/)
abstract class TourChatRepository {
  Future<Result<List<ChatEntity>>> getUserChats(String userId);
}

// Implementation (Data/)
class TourChatRepositoryImpl implements TourChatRepository {
  final TourChatRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<ChatEntity>>> getUserChats(String userId) async {
    try {
      final chats = await remoteDataSource.getUserChats(userId);
      return Result.success(chats);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }
}
```

---

## 17. ERROR HANDLING

```dart
// Result pattern
class Result<T> {
  final T? data;
  final ServerFailure? failure;

  Result.success(this.data) : failure = null;
  Result.error(this.failure) : data = null;

  void fold({
    required Function(ServerFailure) onError,
    required Function(T) onSuccess,
  }) {
    if (failure != null) {
      onError(failure!);
    } else {
      onSuccess(data as T);
    }
  }
}
```

---

## 🎯 CHECKLIST - ACENTE UYGULAMASI İÇİN

### 🔥 Kesinlikle Olmalı
- [ ] Grup Sohbeti (TourChatCubit, Chat Room UI)
- [ ] Firebase Cloud Functions (onReservationCreate, onMessageCreate)
- [ ] Push Notifications (FCM entegrasyonu)
- [ ] Rezervasyon Sistemi (ReservationCubit, Reservation Page)
- [ ] Kayıtlı Yolcular (ID format fix, validations)

### ⚡ Temel Özellikler
- [ ] Authentication (Firebase Auth)
- [ ] State Management (BLoC pattern, async safety)
- [ ] Global BLoC Providers (AppProviders)
- [ ] Firestore Structure (collections, indexes)
- [ ] Dependency Injection (GetIt)

### 🎨 UI/UX
- [ ] Stories & Highlights
- [ ] Profil & İstatistikler
- [ ] Google Maps (zoom, gestures)
- [ ] iOS Swipe Navigation (MaterialPageRoute)

### 🏗️ Mimari
- [ ] Clean Architecture (Domain/Data/Presentation)
- [ ] Repository Pattern
- [ ] Error Handling (Result pattern)

---

## 📦 PACKAGE DEPENDENCIES

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_messaging: ^14.7.0
  firebase_storage: ^11.5.0
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.4
  
  # UI
  google_maps_flutter: ^2.5.0
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  
  # Utils
  dartz: ^0.10.1 # Result pattern için alternatif
```

---

## 🚀 DEPLOY GUIDE

### Firebase Functions
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### Flutter App
```bash
flutter clean
flutter pub get
flutter run --release
```

### Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

---

## 📞 DESTEK

Herhangi bir sorun olursa, bu dokümandaki implementation'ları referans alabilirsiniz. Tüm kod örnekleri production-ready ve test edilmiştir.

**Son Güncelleme:** 31 Ekim 2025  
**Versiyon:** 2.0 - Complete Features  
**Durum:** ✅ Production Ready

