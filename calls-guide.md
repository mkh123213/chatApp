# دليل نظام المكالمات - تطبيق ALKHATEEB CHAT

## المقدمة

هذا الدليل يشرح بالتفصيل الكامل كيف يعمل نظام المكالمات الصوتية والمرئية في التطبيق. يغطي كل شيء من لحظة ضغط المستخدم على زر الاتصال حتى انتهاء المكالمة، بما في ذلك البنية التحتية، إدارة الحالات، واجهة المستخدم، سجل المكالمات، والتعامل مع الحالات الاستثنائية.

---

## التقنيات المستخدمة

| التقنية | الدور |
|---------|-------|
| **Agora RTC Engine** | محرك الصوت والفيديو الفعلي - ينقل الصوت والصورة بين المستخدمين في الوقت الحقيقي |
| **Supabase Edge Function (agora-token)** | يولّد توكن آمن لدخول قناة Agora |
| **Cloud Firestore** | يخزن بيانات المكالمة (من يتصل بمن، الحالة، المدة) ويوفر الاستماع في الوقت الحقيقي |
| **flutter_callkit_incoming** | يعرض شاشة المكالمة الواردة الأصلية (Native) على Android و iOS - حتى لو الشاشة مقفلة |
| **Firebase Cloud Messaging (FCM)** | يرسل إشعار للمستقبل بوجود مكالمة واردة |
| **permission_handler** | يطلب صلاحيات الميكروفون والكاميرا |
| **BLoC / Cubit** | يدير حالة المكالمة في واجهة المستخدم |

---

## البنية العامة للنظام

```
┌────────────────────────────────────────────────────────────────┐
│                      جهاز المتصل (Caller)                      │
│                                                                │
│  StartCallCubit → CallsRemoteDataSource.startCall()            │
│      │                                                         │
│      ├── 1. يتحقق من عدم وجود مكالمة نشطة                     │
│      ├── 2. ينشئ CallModel ويحفظه في Firestore                 │
│      ├── 3. يرسل إشعار مكالمة عبر FCM                         │
│      └── 4. يفتح CallScreen → يتصل بقناة Agora                │
└────────────────────────────┬───────────────────────────────────┘
                             │
                    Firestore (real-time)
                    + FCM Notification
                             │
                             ▼
┌────────────────────────────────────────────────────────────────┐
│                    جهاز المستقبل (Receiver)                     │
│                                                                │
│  IncomingCallCubit يستمع لمكالمات واردة في Firestore           │
│      │                                                         │
│      ├── يظهر IncomingCallDialog (داخل التطبيق)                │
│      └── CallKitService يظهر شاشة مكالمة واردة (Native)        │
│          │                                                     │
│          ├── قبول → acceptCall() → فتح CallScreen → Agora      │
│          ├── رفض → rejectCall() → تحديث Firestore              │
│          └── انتهاء المهلة → missCall() → تحديث Firestore      │
└────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────┐
│                      قناة Agora RTC                            │
│                                                                │
│  كلا الطرفين متصلان بنفس channelId                            │
│  الصوت والفيديو ينتقلان مباشرة عبر خوادم Agora                │
└────────────────────────────────────────────────────────────────┘
```

---

## الملفات المسؤولة عن المكالمات

```
lib/
├── core/service/call_service/
│   ├── call_provider_service.dart          ← واجهة مجردة لأي مزود مكالمات
│   ├── agora_call_provider_service.dart    ← التنفيذ الفعلي باستخدام Agora
│   ├── agora_token_service.dart            ← جلب التوكن من Supabase
│   └── callkit_service.dart               ← إظهار شاشة المكالمة الواردة (Native)
│
├── core/service/pending_navigation/
│   └── pending_navigation_service.dart     ← التنقل المعلق (عند قبول مكالمة من CallKit)
│
├── constants/
│   └── agora_constants.dart                ← Agora App ID
│
├── features/calls/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── calls_remote_data_source.dart   ← كل عمليات Firestore للمكالمات
│   │   ├── models/
│   │   │   ├── call_model.dart                 ← نموذج بيانات المكالمة
│   │   │   └── call_status.dart                ← ثوابت حالات المكالمة
│   │   └── repositories/
│   │       └── calls_repo.dart                 ← يمرر الطلبات للـ data source
│   │
│   └── presentation/
│       ├── bloc/
│       │   ├── start_call_cubit/               ← بدء مكالمة جديدة
│       │   ├── incoming_call_cubit/            ← الاستماع للمكالمات الواردة
│       │   ├── active_call_cubit/              ← إدارة المكالمة النشطة
│       │   └── calls_history_cubit/            ← سجل المكالمات
│       ├── screens/
│       │   ├── call_screen.dart                ← شاشة المكالمة الرئيسية
│       │   └── calls_history_screen.dart       ← شاشة سجل المكالمات
│       ├── refactor/
│       │   ├── call_body.dart                  ← جسم شاشة المكالمة
│       │   └── calls_history_body.dart         ← جسم شاشة السجل
│       └── widgets/
│           ├── active_call_bloc_consumer.dart   ← يستمع لحالة المكالمة النشطة
│           ├── call_controls.dart              ← أزرار التحكم (كتم، سماعة، كاميرا، إنهاء)
│           ├── call_header.dart                ← رأس المكالمة (اسم، صورة، حالة، مؤقت)
│           ├── call_video_view.dart            ← عرض الفيديو (محلي + بعيد)
│           ├── call_history_card.dart           ← بطاقة مكالمة في السجل
│           ├── calls_history_bloc_consumer.dart ← عرض قائمة السجل مع التجميع بالتاريخ
│           ├── incoming_call_dialog.dart        ← نافذة المكالمة الواردة (داخل التطبيق)
│           └── incoming_call_overlay.dart       ← التحكم بظهور/إخفاء نافذة المكالمة
│
supabase/functions/
    └── agora-token/
        └── index.ts                            ← Edge Function لتوليد توكن Agora
```

---

## نموذج بيانات المكالمة (CallModel)

الملف: `lib/features/calls/data/models/call_model.dart`

كل مكالمة تُمثَّل بكائن `CallModel` يحتوي على:

```dart
class CallModel {
  final String id;               // معرف المكالمة الفريد
  final String chatId;           // معرف المحادثة بين المستخدمين (userId1_userId2 مرتب أبجدياً)
  final String callerId;         // معرف المتصل
  final String callerName;       // اسم المتصل
  final String callerEmail;      // إيميل المتصل
  final String? callerPhotoUrl;  // صورة المتصل
  final String receiverId;       // معرف المستقبل
  final String receiverName;     // اسم المستقبل
  final String receiverEmail;    // إيميل المستقبل
  final String? receiverPhotoUrl;// صورة المستقبل
  final String type;             // نوع المكالمة: 'audio' أو 'video'
  final String status;           // حالة المكالمة (انظر الحالات أدناه)
  final DateTime? startedAt;     // وقت بدء الرنين
  final DateTime? acceptedAt;    // وقت قبول المكالمة
  final DateTime? endedAt;       // وقت انتهاء المكالمة
  final int durationInSeconds;   // مدة المكالمة بالثواني
  final String channelId;        // معرف قناة Agora (call_{callId})
  final DateTime? createdAt;     // وقت الإنشاء
  final DateTime? updatedAt;     // وقت آخر تحديث
}
```

### هيكل البيانات في Firestore:

```
calls/{callId}
{
  "id": "abc123",
  "chatId": "userId1_userId2",
  "callerId": "userId1",
  "callerName": "أحمد",
  "callerEmail": "ahmed@example.com",
  "callerPhotoUrl": "https://...",
  "receiverId": "userId2",
  "receiverName": "محمد",
  "receiverEmail": "mohammed@example.com",
  "receiverPhotoUrl": "https://...",
  "type": "audio",
  "status": "ringing",
  "startedAt": Timestamp,
  "acceptedAt": null,
  "endedAt": null,
  "durationInSeconds": 0,
  "channelId": "call_abc123",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## حالات المكالمة (Call Status)

الملف: `lib/features/calls/data/models/call_status.dart`

```dart
class CallStatus {
  static const String ringing  = 'ringing';    // المكالمة ترن عند المستقبل
  static const String accepted = 'accepted';   // المستقبل قبل المكالمة
  static const String rejected = 'rejected';   // المستقبل رفض المكالمة
  static const String ended    = 'ended';      // المكالمة انتهت بشكل طبيعي
  static const String missed   = 'missed';     // المستقبل لم يرد (انتهت المهلة)
}
```

### مخطط تحولات الحالة:

```
                    ┌──────────┐
                    │  ringing │ ← الحالة الأولى عند إنشاء المكالمة
                    └────┬─────┘
                         │
            ┌────────────┼────────────┐
            │            │            │
            ▼            ▼            ▼
      ┌──────────┐ ┌──────────┐ ┌──────────┐
      │ accepted │ │ rejected │ │  missed  │
      └────┬─────┘ └──────────┘ └──────────┘
           │         (نهائي)      (نهائي)
           │
           ▼
      ┌──────────┐
      │  ended   │
      └──────────┘
        (نهائي)
```

- **ringing → accepted**: المستقبل ضغط "قبول"
- **ringing → rejected**: المستقبل ضغط "رفض"
- **ringing → missed**: مرت 30 ثانية بدون رد، أو التطبيق أُغلق، أو انتهت مهلة CallKit
- **accepted → ended**: أحد الطرفين أنهى المكالمة

---

## المرحلة الأولى: بدء المكالمة (Caller Side)

### 1. المستخدم يضغط زر الاتصال

عندما يكون المستخدم في محادثة فردية، يمكنه الضغط على أيقونة الهاتف أو الكاميرا لبدء مكالمة صوتية أو مرئية.

### 2. StartCallCubit يعالج الطلب

الملف: `lib/features/calls/presentation/bloc/start_call_cubit/start_call_cubit.dart`

```dart
class StartCallCubit extends Cubit<StartCallState> {
  final CallsRepo _callsRepo;

  Future<void> startAudioCall({required ChatModel chat}) async {
    await _startCall(chat: chat, type: 'audio');
  }

  Future<void> startVideoCall({required ChatModel chat}) async {
    await _startCall(chat: chat, type: 'video');
  }

  Future<void> _startCall({required ChatModel chat, required String type}) async {
    emit(const StartCallLoading());    // ← عرض مؤشر تحميل
    try {
      final currentUser = getCurrentUser();

      // التحقق: لا يمكنك الاتصال بنفسك
      final friendId = chat.users.firstWhere((id) => id != currentUser.uid);
      if (friendId == currentUser.uid) {
        emit(const StartCallError(message: 'Cannot call yourself.'));
        return;
      }

      // إنشاء المكالمة عبر الـ Repository
      final call = await _callsRepo.startCall(
        chat: chat,
        caller: currentUser,
        type: type,
      );

      emit(StartCallSuccess(call: call));  // ← نجاح → ينتقل لشاشة المكالمة
    } catch (e) {
      emit(StartCallError(message: e.toString()));
    }
  }
}
```

### حالات StartCallCubit:

```
StartCallInitial → الحالة الأولى
StartCallLoading → جارٍ إنشاء المكالمة
StartCallSuccess(call) → تم الإنشاء بنجاح، يحمل بيانات المكالمة
StartCallError(message) → فشل الإنشاء
```

### 3. CallsRemoteDataSource ينشئ المكالمة

الملف: `lib/features/calls/data/datasources/calls_remote_data_source.dart`

هذا هو المكان الذي يحدث فيه كل العمل الفعلي:

```dart
Future<CallModel> startCall({
  required ChatModel chat,
  required CurrentUserModel caller,
  required String type,
}) async {
  // الخطوة 1: تحديد المستقبل
  final receiverId = chat.users.firstWhere((id) => id != caller.uid);

  // الخطوة 2: إنشاء chatId موحد (مرتب أبجدياً لضمان التوحيد)
  final ids = [caller.uid, receiverId]..sort();
  final chatId = ids.join('_');

  // الخطوة 3: التحقق من عدم وجود مكالمة نشطة بين المستخدمين
  final hasActive = await hasActiveCallBetweenUsers(chatId: chatId);
  if (hasActive) {
    throw Exception('A call is already active between you and this user.');
  }

  // الخطوة 4: جلب بيانات المستقبل (اسمه، صورته) من Firestore
  final receiverDoc = await _dataBaseService.getDocument(
    path: 'users/$receiverId',
    builder: (data, id) => data,
  );

  // الخطوة 5: إنشاء معرف فريد للمكالمة وقناة Agora
  final callId = FirebaseFirestore.instance.collection('calls').doc().id;
  final channelId = 'call_$callId';   // ← اسم قناة Agora مشتق من معرف المكالمة

  // الخطوة 6: إنشاء نموذج المكالمة
  final callModel = CallModel(
    id: callId,
    chatId: chatId,
    callerId: caller.uid,
    callerName: caller.name ?? '',
    callerEmail: caller.email ?? '',
    callerPhotoUrl: caller.photoUrl,
    receiverId: receiverId,
    receiverName: receiverName,
    receiverEmail: receiverEmail,
    receiverPhotoUrl: receiverPhotoUrl,
    type: type,                        // 'audio' أو 'video'
    status: CallStatus.ringing,        // ← الحالة الأولية: "يرن"
    startedAt: now,
    durationInSeconds: 0,
    channelId: channelId,
    createdAt: now,
    updatedAt: now,
  );

  // الخطوة 7: حفظ المكالمة في Firestore
  await _dataBaseService.setData(
    path: 'calls/$callId',
    data: callModel.toJson(),
  );

  // الخطوة 8: إرسال إشعار للمستقبل
  ChatNotificationService.instance.sendCallNotification(
    receiverId: receiverId,
    callId: callId,
    callerName: caller.name ?? caller.email ?? '',
    callerPhotoUrl: caller.photoUrl ?? '',
    callType: type,
  );

  return callModel;
}
```

### التحقق من وجود مكالمة نشطة:

```dart
Future<bool> hasActiveCallBetweenUsers({required String chatId}) async {
  // البحث عن مكالمات بحالة ringing أو accepted بين نفس المستخدمين
  final result = await _dataBaseService.getCollection(
    path: 'calls',
    queryBuilder: (query) => query
        .where('chatId', isEqualTo: chatId)
        .where('status', whereIn: ['ringing', 'accepted']),
    builder: (data, documentId) => {'id': documentId, ...data},
  );

  if (result.isEmpty) return false;

  // تنظيف المكالمات القديمة التي لم تُنهَ بشكل صحيح
  final now = DateTime.now();
  for (final call in result) {
    final status = call['status'];
    final startTime = (call['startedAt'] as Timestamp?)?.toDate();

    if (startTime == null) {
      await _markCallAsMissed(call['id']);  // لا يوجد وقت بدء = مكالمة تالفة
      continue;
    }

    final elapsed = now.difference(startTime);

    // مكالمة ترن منذ أكثر من 60 ثانية = فائتة
    if (status == 'ringing' && elapsed.inSeconds > 60) {
      await _markCallAsMissed(call['id']);
    }
    // مكالمة مقبولة منذ أكثر من 24 ساعة = منتهية (التطبيق أُغلق)
    else if (status == 'accepted' && elapsed.inHours > 24) {
      await _markCallAsEnded(call['id']);
    }
    // غير ذلك = مكالمة نشطة فعلاً
    else {
      return true;
    }
  }
  return false;
}
```

هذه الآلية تحل مشكلة شائعة: إذا أُغلق التطبيق بشكل مفاجئ أثناء مكالمة (قتل التطبيق، انقطاع الإنترنت، إيقاف الشاشة)، تبقى المكالمة في Firestore بحالة `ringing` أو `accepted` إلى الأبد. التنظيف التلقائي يعالج هذه الحالة.

---

## المرحلة الثانية: توليد توكن Agora

### لماذا نحتاج توكن؟

Agora يتطلب توكن مؤقت للسماح للمستخدم بالانضمام لقناة. التوكن يُولَّد على الخادم (لأن يحتاج App Certificate السري) ويصلح لمدة ساعة واحدة.

### AgoraTokenService (العميل)

الملف: `lib/core/service/call_service/agora_token_service.dart`

```dart
class AgoraTokenService {
  Future<String> generateToken({
    required String channelName,    // اسم القناة (call_{callId})
    required int uid,               // معرف رقمي فريد للمستخدم
  }) async {
    // يرسل طلب لـ Supabase Edge Function
    final response = await Supabase.instance.client.functions.invoke(
      'agora-token',
      body: {
        'channelName': channelName,
        'uid': uid,
        'role': 'publisher',    // publisher = يمكنه إرسال صوت/فيديو
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['token'] as String;
  }
}
```

### Supabase Edge Function (الخادم)

الملف: `supabase/functions/agora-token/index.ts`

```typescript
const APP_ID = Deno.env.get("AGORA_APP_ID")!;
const APP_CERTIFICATE = Deno.env.get("AGORA_APP_CERTIFICATE")!;
const TOKEN_EXPIRY_SECONDS = 3600;   // صلاحية التوكن: ساعة واحدة

Deno.serve(async (req: Request) => {
  const { channelName, uid, role } = await req.json();

  // تحديد الدور: publisher (يرسل ويستقبل) أو subscriber (يستقبل فقط)
  const tokenRole = role === "subscriber" ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;
  const userUid = uid ?? 0;
  const expireTime = Math.floor(Date.now() / 1000) + TOKEN_EXPIRY_SECONDS;

  // بناء التوكن باستخدام مكتبة agora-token الرسمية
  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID,
    APP_CERTIFICATE,
    channelName,
    userUid,
    tokenRole,
    expireTime,
    expireTime
  );

  return Response({ token, appId: APP_ID, expiresIn: TOKEN_EXPIRY_SECONDS });
});
```

### متغيرات البيئة المطلوبة على Supabase:

| المتغير | الوصف |
|---------|-------|
| `AGORA_APP_ID` | معرف تطبيق Agora (نفس القيمة في `agora_constants.dart`) |
| `AGORA_APP_CERTIFICATE` | الشهادة السرية من لوحة تحكم Agora |

### كيف يتم حساب UID الرقمي؟

Agora يتطلب معرف رقمي (int) للمستخدم، لكن Firebase يستخدم معرفات نصية. الحل هو استخدام دالة هاش حتمية (FNV-1a):

```dart
// دالة هاش FNV-1a 32-bit — تعطي نفس النتيجة على كل الأجهزة
static int _stableUidHash(String s) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    hash ^= s.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
}
```

لماذا لا نستخدم `String.hashCode`؟ لأن `hashCode` في Dart قد يعطي نتائج مختلفة على أجهزة مختلفة أو إصدارات مختلفة من Dart. الدالة أعلاه حتمية وتعطي نفس النتيجة دائماً.

---

## المرحلة الثالثة: واجهة مزود المكالمات (Call Provider)

### الواجهة المجردة

الملف: `lib/core/service/call_service/call_provider_service.dart`

```dart
abstract class CallProviderService {
  Future<void> initialize();                    // تهيئة المحرك
  Future<void> joinChannel({...});              // الانضمام لقناة
  Future<void> leaveChannel();                  // مغادرة القناة
  Future<void> toggleMute(bool muted);          // كتم/إلغاء كتم الميكروفون
  Future<void> toggleSpeaker(bool speakerOn);   // تشغيل/إيقاف السماعة الخارجية
  Future<void> toggleCamera(bool cameraOn);     // تشغيل/إيقاف الكاميرا
  Future<void> switchCamera();                  // تبديل الكاميرا (أمامية/خلفية)
  dynamic get engine;                           // محرك Agora (للفيديو)
  int? get remoteUid;                           // معرف المستخدم البعيد
  Stream<int?> get onRemoteUserChanged;         // تنبيه عند دخول/خروج المستخدم البعيد
  Future<void> dispose();                       // تنظيف الموارد
}
```

هذه واجهة مجردة - يمكن استبدال Agora بأي مزود آخر (مثل Twilio أو WebRTC) بدون تغيير باقي الكود.

### التنفيذ: AgoraCallProviderService

الملف: `lib/core/service/call_service/agora_call_provider_service.dart`

```dart
class AgoraCallProviderService implements CallProviderService {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _joined = false;
  StreamController<int?> _remoteUidController = StreamController<int?>.broadcast();

  @override
  Future<void> initialize() async {
    // إعادة تعيين الحالة
    _joined = false;
    _remoteUid = null;

    // إنشاء محرك Agora
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,    // ← معرف التطبيق من agora_constants.dart
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // تسجيل مستمعي الأحداث
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _joined = true;     // ← تم الانضمام للقناة بنجاح
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        _remoteUid = remoteUid;
        _remoteUidController.add(remoteUid);    // ← المستخدم الآخر دخل القناة
      },
      onUserOffline: (connection, remoteUid, reason) {
        _remoteUid = null;
        _remoteUidController.add(null);          // ← المستخدم الآخر غادر القناة
      },
    ));
  }

  @override
  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool isVideo,
  }) async {
    final engine = _engine;
    if (engine == null) return;

    await engine.enableAudio();                  // تفعيل الصوت دائماً
    if (isVideo) {
      await engine.enableVideo();                // تفعيل الفيديو إذا كانت مكالمة مرئية
      await engine.startPreview();               // بدء معاينة الكاميرا
    }

    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: ChannelMediaOptions(
        autoSubscribeAudio: true,               // استقبال صوت الآخرين تلقائياً
        autoSubscribeVideo: isVideo,            // استقبال فيديو الآخرين
        publishMicrophoneTrack: true,           // بث صوتي
        publishCameraTrack: isVideo,            // بث الكاميرا
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);     // كتم الميكروفون المحلي
  }

  @override
  Future<void> toggleSpeaker(bool speakerOn) async {
    await _engine?.setEnableSpeakerphone(speakerOn);  // السماعة الخارجية
  }

  @override
  Future<void> toggleCamera(bool cameraOn) async {
    await _engine?.muteLocalVideoStream(!cameraOn);   // إيقاف بث الكاميرا
  }

  @override
  Future<void> switchCamera() async {
    await _engine?.switchCamera();                    // تبديل أمامية/خلفية
  }

  @override
  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();                         // تحرير موارد المحرك
    _engine = null;
  }
}
```

---

## المرحلة الرابعة: شاشة المكالمة (CallScreen)

الملف: `lib/features/calls/presentation/screens/call_screen.dart`

هذا هو أهم ملف في نظام المكالمات. يدير كل شيء من التهيئة حتى التنظيف.

### دورة الحياة الكاملة:

```
initState()
    │
    ├── 1. تسجيل WidgetsBindingObserver (لمراقبة حالة التطبيق)
    ├── 2. جلب CallProviderService و CallsRepo من GetIt
    ├── 3. إنشاء ActiveCallCubit والاستماع للمكالمة في Firestore
    ├── 4. الاستماع لحالات ActiveCallCubit
    └── 5. _initializeCall()
            │
            ├── طلب صلاحيات (ميكروفون + بلوتوث + كاميرا إذا فيديو)
            │   ├── مرفوض → SnackBar + إغلاق الشاشة
            │   └── مقبول → نكمل
            │
            ├── حساب UID الرقمي من Firebase UID
            ├── جلب توكن Agora من Supabase Edge Function
            ├── تهيئة CallProviderService (Agora)
            ├── الانضمام لقناة Agora
            │
            ├── _listenForRemoteUserLeave()
            │   └── يستمع لـ onRemoteUserChanged
            │       إذا المستخدم البعيد غادر → إنهاء المكالمة
            │
            └── _startMissedCallTimerIfCaller()
                └── إذا أنا المتصل + الحالة ringing
                    → مؤقت 30 ثانية → missCall()
```

### طلب الصلاحيات:

```dart
Future<void> _initializeCall() async {
  final isVideo = widget.call.type == CallType.video;

  // تحديد الصلاحيات المطلوبة
  final permissions = <Permission>[
    Permission.microphone,        // مطلوب دائماً
    Permission.bluetoothConnect,  // للسماعات اللاسلكية
  ];
  if (isVideo) permissions.add(Permission.camera);  // مطلوب للفيديو فقط

  final statuses = await permissions.request();

  // التحقق من القبول
  final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
  final cameraGranted = !isVideo || (statuses[Permission.camera]?.isGranted ?? false);

  if (!micGranted || !cameraGranted) {
    // الصلاحيات مرفوضة → عرض رسالة وإغلاق الشاشة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Microphone and camera permissions are required')),
    );
    Navigator.of(context).pop();
    return;
  }

  // ... متابعة التهيئة
}
```

### مؤقت المكالمة الفائتة (Caller Side):

```dart
void _startMissedCallTimerIfCaller() {
  final currentUserId = getCurrentUser().uid;

  // فقط المتصل هو من يبدأ المؤقت
  if (widget.call.callerId == currentUserId &&
      widget.call.status == CallStatus.ringing) {
    _missedCallTimer = Timer(const Duration(seconds: 30), () {
      // بعد 30 ثانية بدون رد → تعليم المكالمة كفائتة
      if (mounted) {
        _activeCallCubit.missCall(call: widget.call);
      }
    });
  }
}
```

### اكتشاف مغادرة المستخدم البعيد:

```dart
void _listenForRemoteUserLeave() {
  _remoteUserSub = _callProvider.onRemoteUserChanged.listen((uid) {
    if (uid != null) {
      _remoteUserJoined = true;      // ← الطرف الآخر انضم
    } else if (_remoteUserJoined && uid == null) {
      _endCallIfActive();            // ← الطرف الآخر غادر بعد أن كان موجوداً
    }
  });
}
```

الشرط `_remoteUserJoined && uid == null` مهم لأن:
- في البداية `uid = null` (لا أحد انضم بعد) — لا نريد إنهاء المكالمة
- بعد انضمام الطرف الآخر `uid = 12345` ثم مغادرته `uid = null` — نريد إنهاء المكالمة

### التعامل مع إغلاق التطبيق:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.detached) {
    _endCallOnTermination();    // ← التطبيق أُغلق
  }
}

Future<void> _endCallOnTermination() async {
  if (_callEnded) return;       // ← منع الإنهاء المزدوج
  _callEnded = true;

  final call = _latestCall ?? widget.call;

  if (call.status == CallStatus.ringing || call.status == CallStatus.missed) {
    await _callsRepo.missCall(callId: call.id);   // ← لم يتم الرد = فائتة
  } else if (call.status == CallStatus.accepted) {
    // حساب المدة من وقت القبول حتى الآن
    final duration = call.acceptedAt != null
        ? DateTime.now().difference(call.acceptedAt!).inSeconds
        : 0;
    await _callsRepo.endCall(callId: call.id, durationInSeconds: duration);
  }
}
```

### تنظيف الموارد عند الخروج:

```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _remoteUserSub?.cancel();          // إلغاء الاستماع للمستخدم البعيد
  _activeCallStateSub?.cancel();     // إلغاء الاستماع لحالة المكالمة
  _missedCallTimer?.cancel();        // إلغاء مؤقت المكالمة الفائتة
  _endCallOnTermination();           // إنهاء المكالمة إذا لم تنته بعد
  _callProvider.dispose();           // تحرير موارد Agora
  _activeCallCubit.close();          // إغلاق الـ Cubit
  super.dispose();
}
```

---

## المرحلة الخامسة: استقبال المكالمة (Receiver Side)

### 1. IncomingCallCubit يستمع لمكالمات واردة

الملف: `lib/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_cubit.dart`

```dart
class IncomingCallCubit extends Cubit<IncomingCallState> {
  void listenForIncomingCalls({required String currentUserId}) {
    emit(const IncomingCallListening());

    // الاستماع لمكالمات بحالة 'ringing' حيث أنا المستقبل
    _subscription = _callsRepo
        .listenForIncomingCalls(currentUserId: currentUserId)
        .listen((call) {
      if (call != null) {
        emit(IncomingCallReceived(call: call));  // ← مكالمة واردة!
      } else {
        emit(const IncomingCallNone());           // ← لا مكالمات
      }
    });
  }
}
```

### الاستعلام في Firestore:

```dart
Stream<CallModel?> listenForIncomingCalls({required String currentUserId}) {
  return _dataBaseService.collectionStream<CallModel>(
    path: 'calls',
    queryBuilder: (query) => query
        .where('receiverId', isEqualTo: currentUserId)   // أنا المستقبل
        .where('status', isEqualTo: 'ringing'),           // المكالمة ترن
    builder: (data, documentId) => CallModel.fromFirestore(id: documentId, data: data),
  ).map((calls) => calls.isNotEmpty ? calls.first : null);
}
```

### حالات IncomingCallCubit:

```
IncomingCallInitial    → لم يبدأ الاستماع بعد
IncomingCallListening  → جارٍ الاستماع
IncomingCallReceived   → مكالمة واردة (يحمل CallModel)
IncomingCallNone       → لا مكالمات واردة حالياً
IncomingCallError      → خطأ
```

### 2. عرض نافذة المكالمة الواردة (داخل التطبيق)

الملف: `lib/features/calls/presentation/widgets/incoming_call_overlay.dart`

```dart
class IncomingCallOverlay {
  static bool _isDialogShowing = false;

  static void show(BuildContext context, CallModel call) {
    if (_isDialogShowing) return;        // ← منع عرض أكثر من نافذة
    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,         // ← لا يمكن إغلاقها بالضغط خارجها
      builder: (_) => IncomingCallDialog(call: call),
    ).then((_) => _isDialogShowing = false);
  }
}
```

### 3. نافذة المكالمة الواردة

الملف: `lib/features/calls/presentation/widgets/incoming_call_dialog.dart`

تعرض:
- صورة المتصل (أو أيقونة افتراضية)
- اسم المتصل
- إيميل المتصل
- نوع المكالمة (صوتية/مرئية)
- زر قبول (أخضر) وزر رفض (أحمر)

**عند الضغط على "قبول":**
```dart
Future<void> _acceptCall(BuildContext context) async {
  navigator.pop();                                          // إغلاق النافذة
  await sl<CallsRepo>().acceptCall(callId: call.id);       // تحديث Firestore: status = 'accepted'
  navigator.pushNamed(AppRoutes.callScreen, arguments: call); // فتح شاشة المكالمة
}
```

**عند الضغط على "رفض":**
```dart
Future<void> _rejectCall(BuildContext context) async {
  Navigator.of(context).pop();                              // إغلاق النافذة
  await sl<CallsRepo>().rejectCall(callId: call.id);       // تحديث Firestore: status = 'rejected'
}
```

### 4. شاشة المكالمة الواردة الأصلية (CallKit)

الملف: `lib/core/service/call_service/callkit_service.dart`

عندما يصل إشعار FCM بمكالمة واردة (حتى لو التطبيق مغلق أو الشاشة مقفلة)، يتم عرض شاشة المكالمة الأصلية للنظام:

```dart
Future<void> showIncomingCall({
  required String callId,
  required String callerName,
  required String callerAvatar,
  required bool isVideo,
}) async {
  final params = CallKitParams(
    id: callId,
    nameCaller: callerName,
    avatar: callerAvatar,
    type: isVideo ? 1 : 0,           // 0 = صوتي، 1 = فيديو
    duration: 30000,                  // 30 ثانية مهلة الرد
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,         // عرض إشعار مكالمة فائتة
      isShowCallback: true,           // زر معاودة الاتصال
      subtitle: 'Missed call',
    ),
    android: const AndroidParams(
      isCustomNotification: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      isShowFullLockedScreen: true,   // ← يظهر فوق شاشة القفل
    ),
    ios: const IOSParams(
      supportsVideo: true,
      audioSessionActive: true,
      ringtonePath: 'system_ringtone_default',
    ),
  );

  await FlutterCallkitIncoming.showCallkitIncoming(params);
}
```

### التعامل مع أحداث CallKit:

```dart
void _onCallKitEvent(CallEvent? event) {
  final callId = (event.body as Map)['id'] as String;

  switch (event.event) {
    case Event.actionCallAccept:
      _handleAccept(callId);    // المستخدم قبل المكالمة من شاشة النظام
      break;
    case Event.actionCallDecline:
      _handleDecline(callId);   // المستخدم رفض المكالمة من شاشة النظام
      break;
    case Event.actionCallTimeout:
      _handleTimeout(callId);   // انتهت مهلة 30 ثانية
      break;
  }
}
```

**عند القبول من CallKit:**
```dart
Future<void> _handleAccept(String callId) async {
  // 1. تحديث حالة المكالمة في Firestore مباشرة
  await FirebaseFirestore.instance.doc('calls/$callId').update({
    'status': 'accepted',
    'acceptedAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });

  // 2. حفظ التنقل المعلق — عندما يفتح التطبيق سينتقل لشاشة المكالمة
  PendingNavigationService.instance.setPendingCall(callId);
}
```

لماذا نستخدم `PendingNavigationService`؟ لأن CallKit يعمل على مستوى النظام، وقد يكون التطبيق مغلقاً. عندما يُفتح التطبيق بعد قبول المكالمة، يتحقق من `PendingNavigationService` وينتقل لشاشة المكالمة تلقائياً.

---

## المرحلة السادسة: المكالمة النشطة (ActiveCallCubit)

الملف: `lib/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart`

هذا الـ Cubit يدير حالة المكالمة أثناء المكالمة:

```dart
class ActiveCallCubit extends Cubit<ActiveCallState> {
  final CallsRepo _callsRepo;
  final CallProviderService _callProviderService;

  // الاستماع لتغييرات المكالمة في Firestore (real-time)
  void listenToCall({required String callId}) {
    emit(const ActiveCallLoading());

    _callSubscription = _callsRepo.listenToCall(callId: callId).listen((call) {
      // إذا المكالمة انتهت/رُفضت/فائتة → إرسال حالة "انتهت"
      if (call.status == CallStatus.ended ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.missed) {
        emit(const ActiveCallEnded());
      } else {
        emit(ActiveCallActive(call: call));  // ← المكالمة نشطة
      }
    });
  }

  // عمليات التحكم
  Future<void> acceptCall({required CallModel call}) async {
    await _callsRepo.acceptCall(callId: call.id);
  }

  Future<void> rejectCall({required CallModel call}) async {
    await _callsRepo.rejectCall(callId: call.id);
  }

  Future<void> endCall({required CallModel call, required int durationInSeconds}) async {
    await _callsRepo.endCall(callId: call.id, durationInSeconds: durationInSeconds);
  }

  Future<void> missCall({required CallModel call}) async {
    await _callsRepo.missCall(callId: call.id);
  }

  // التحكم بالصوت والفيديو (عبر CallProviderService)
  Future<void> toggleMute(bool muted) async => _callProviderService.toggleMute(muted);
  Future<void> toggleSpeaker(bool on) async => _callProviderService.toggleSpeaker(on);
  Future<void> toggleCamera(bool on) async => _callProviderService.toggleCamera(on);
  Future<void> switchCamera() async => _callProviderService.switchCamera();
}
```

### حالات ActiveCallCubit:

```
ActiveCallInitial  → لم يبدأ الاستماع بعد
ActiveCallLoading  → جارٍ تحميل بيانات المكالمة
ActiveCallActive   → المكالمة نشطة (يحمل CallModel محدث)
ActiveCallEnded    → المكالمة انتهت → يجب إغلاق الشاشة
ActiveCallError    → خطأ
```

---

## المرحلة السابعة: واجهة المستخدم أثناء المكالمة

### ActiveCallBlocConsumer

الملف: `lib/features/calls/presentation/widgets/active_call_bloc_consumer.dart`

يعرض الواجهة المناسبة حسب نوع المكالمة:

```dart
Widget build(BuildContext context) {
  return BlocConsumer<ActiveCallCubit, ActiveCallState>(
    listener: (context, state) {
      if (state is ActiveCallError) {
        ShowToast.showToastErrorTop(message: state.message);
      }
    },
    builder: (context, state) {
      final call = state is ActiveCallActive ? state.call : initialCall;
      final isVideo = call.type == CallType.video;

      return Stack(
        children: [
          // عرض الفيديو (فقط للمكالمات المرئية)
          if (isVideo)
            Positioned.fill(child: CallVideoView(channelId: call.channelId)),

          Column(
            children: [
              // رأس المكالمة (صوتية فقط — المرئية تعرض حالة الاتصال)
              if (!isVideo) CallHeader(call: call),
              if (isVideo && call.status != CallStatus.accepted)
                Text('Connecting...'),

              const Spacer(),

              // أزرار التحكم (أسفل الشاشة)
              CallControls(
                call: call,
                onEndCall: () {
                  if (call.status == CallStatus.ringing) {
                    // المكالمة لا تزال ترن → تعليمها كفائتة
                    context.read<ActiveCallCubit>().missCall(call: call);
                  } else {
                    // المكالمة مقبولة → إنهاؤها مع حساب المدة
                    final duration = call.acceptedAt != null
                        ? DateTime.now().difference(call.acceptedAt!).inSeconds
                        : 0;
                    context.read<ActiveCallCubit>().endCall(
                      call: call,
                      durationInSeconds: duration,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
```

### CallHeader — رأس المكالمة الصوتية

الملف: `lib/features/calls/presentation/widgets/call_header.dart`

يعرض:
- صورة الطرف الآخر (دائرية)
- اسم الطرف الآخر
- نوع المكالمة (صوتية/مرئية)
- حالة المكالمة (يرن، متصل، انتهت، مرفوضة، فائتة)
- مؤقت المدة (يبدأ عند القبول)

```dart
void _startTimerIfNeeded() {
  if (widget.call.status == CallStatus.accepted && _timer == null) {
    // حساب المدة المنقضية منذ القبول
    if (widget.call.acceptedAt != null) {
      _seconds = DateTime.now().difference(widget.call.acceptedAt!).inSeconds;
    }
    // بدء المؤقت
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';    // مثال: "03:45"
}
```

### CallControls — أزرار التحكم

الملف: `lib/features/calls/presentation/widgets/call_controls.dart`

الأزرار المتاحة:

| الزر | الوظيفة | متاح في |
|------|---------|---------|
| Mute/Unmute | كتم/إلغاء كتم الميكروفون | صوتي + مرئي |
| Speaker | تشغيل/إيقاف السماعة الخارجية | صوتي + مرئي |
| Camera | تشغيل/إيقاف الكاميرا | مرئي فقط |
| Switch | تبديل الكاميرا (أمامية/خلفية) | مرئي فقط |
| End | إنهاء المكالمة (أحمر) | صوتي + مرئي |

### CallVideoView — عرض الفيديو

الملف: `lib/features/calls/presentation/widgets/call_video_view.dart`

يعرض فيديوهين:
1. **فيديو المستخدم البعيد** — يملأ الشاشة بالكامل
2. **فيديو المستخدم المحلي** — نافذة صغيرة في الزاوية العليا اليمنى (120×160)

```dart
Widget build(BuildContext context) {
  return Stack(
    children: [
      // فيديو المستخدم البعيد (يملأ الشاشة)
      _remoteUid != null
          ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channelId),
              ),
            )
          : const Center(child: Text('Waiting for other user...')),

      // فيديو المستخدم المحلي (نافذة صغيرة)
      Positioned(
        top: 16, right: 16,
        width: 120, height: 160,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(uid: 0),  // uid 0 = الكاميرا المحلية
            ),
          ),
        ),
      ),
    ],
  );
}
```

---

## المرحلة الثامنة: إنهاء المكالمة

### السيناريوهات الممكنة لإنهاء المكالمة:

| السيناريو | ما يحدث | الحالة النهائية |
|-----------|---------|----------------|
| المتصل يضغط "إنهاء" أثناء الرنين | `missCall()` | missed |
| المتصل يضغط "إنهاء" أثناء المكالمة | `endCall(duration)` | ended |
| المستقبل يضغط "رفض" | `rejectCall()` | rejected |
| المستقبل يضغط "إنهاء" أثناء المكالمة | `endCall(duration)` | ended |
| انتهاء مهلة 30 ثانية | `missCall()` | missed |
| الطرف الآخر غادر قناة Agora | `endCall(duration)` | ended |
| التطبيق أُغلق أثناء الرنين | `missCall()` | missed |
| التطبيق أُغلق أثناء المكالمة | `endCall(duration)` | ended |
| CallKit timeout (30 ثانية) | `_missCallDirect()` | missed |

### تدفق الإنهاء:

```
المستخدم يضغط "End"
        │
        ▼
ActiveCallBlocConsumer.onEndCall
        │
        ├── الحالة == ringing?
        │   └── نعم → missCall() → Firestore: status = 'missed'
        │
        └── الحالة == accepted?
            └── نعم → endCall(duration) → Firestore: status = 'ended'
                │
                ▼
        CallScreen._handleCallEnded() (عبر الاستماع لـ Firestore)
                │
                ├── _callProvider.leaveChannel()    ← مغادرة قناة Agora
                ├── CallKitService.endAllCalls()     ← إنهاء CallKit
                └── Navigator.pop()                  ← إغلاق الشاشة
```

### عملية التحديث في Firestore:

```dart
// قبول
Future<void> acceptCall({required String callId}) async {
  await _dataBaseService.setData(
    path: 'calls/$callId',
    data: {
      'status': 'accepted',
      'acceptedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
  );
}

// رفض
Future<void> rejectCall({required String callId}) async {
  await _dataBaseService.setData(
    path: 'calls/$callId',
    data: {
      'status': 'rejected',
      'endedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
  );
}

// إنهاء
Future<void> endCall({required String callId, required int durationInSeconds}) async {
  await _dataBaseService.setData(
    path: 'calls/$callId',
    data: {
      'status': 'ended',
      'endedAt': Timestamp.now(),
      'durationInSeconds': durationInSeconds,
      'updatedAt': Timestamp.now(),
    },
  );
}

// فائتة
Future<void> missCall({required String callId}) async {
  await _dataBaseService.setData(
    path: 'calls/$callId',
    data: {
      'status': 'missed',
      'endedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
  );
}
```

---

## المرحلة التاسعة: سجل المكالمات

### CallsHistoryCubit

الملف: `lib/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart`

```dart
class CallsHistoryCubit extends Cubit<CallsHistoryState> {
  void getCallsHistory({required String currentUserId}) {
    emit(const CallsHistoryLoading());

    _subscription = _callsRepo
        .getCallsHistory(currentUserId: currentUserId)
        .listen((calls) {
      if (calls.isEmpty) {
        emit(const CallsHistoryEmpty());
      } else {
        emit(CallsHistoryLoaded(calls: calls));
      }
    });
  }

  // حذف مكالمة واحدة
  Future<void> deleteCallRecord({required String callId}) async {
    await _callsRepo.deleteCallRecord(callId: callId);
  }

  // حذف كل السجل
  Future<void> deleteAllCallHistory({required String currentUserId}) async {
    await _callsRepo.deleteAllCallHistory(currentUserId: currentUserId);
  }
}
```

### كيف يتم جلب السجل؟

المشكلة: Firestore لا يدعم `OR` queries مباشرة. المستخدم قد يكون المتصل أو المستقبل. الحل: دمج اشتراكين:

```dart
Stream<List<CallModel>> getCallsHistory({required String currentUserId}) {
  // اشتراك 1: المكالمات التي أجريتها
  final callerStream = _dataBaseService.collectionStream(
    path: 'calls',
    queryBuilder: (query) => query.where('callerId', isEqualTo: currentUserId),
    builder: (data, id) => CallModel.fromFirestore(id: id, data: data),
  );

  // اشتراك 2: المكالمات التي استقبلتها
  final receiverStream = _dataBaseService.collectionStream(
    path: 'calls',
    queryBuilder: (query) => query.where('receiverId', isEqualTo: currentUserId),
    builder: (data, id) => CallModel.fromFirestore(id: id, data: data),
  );

  // دمج النتيجتين مع إزالة التكرارات والترتيب
  // يتم استخدام StreamController لدمج الاشتراكين
  final controller = StreamController<List<CallModel>>();
  List<CallModel> callerCalls = [];
  List<CallModel> receiverCalls = [];

  callerStream.listen((calls) {
    callerCalls = calls;
    controller.add(_mergeCalls(callerCalls, receiverCalls));
  });

  receiverStream.listen((calls) {
    receiverCalls = calls;
    controller.add(_mergeCalls(callerCalls, receiverCalls));
  });

  return controller.stream;
}

List<CallModel> _mergeCalls(List<CallModel> a, List<CallModel> b) {
  final Map<String, CallModel> callMap = {};
  for (final call in a) callMap[call.id] = call;
  for (final call in b) callMap[call.id] = call;   // إزالة التكرارات بالـ id

  final merged = callMap.values.toList()
    ..sort((a, b) => (b.createdAt ?? DateTime(1970))
        .compareTo(a.createdAt ?? DateTime(1970)));  // الأحدث أولاً

  return merged;
}
```

### عرض السجل في الواجهة

الملف: `lib/features/calls/presentation/widgets/calls_history_bloc_consumer.dart`

السجل يعرض:
- عنوان "Calls" مع عدد المكالمات
- زر حذف الكل (يظهر فقط عند وجود مكالمات)
- المكالمات مجمعة حسب التاريخ (اليوم، أمس، أو اسم اليوم)
- كل مكالمة يمكن حذفها بالسحب (Swipe to delete)

### بطاقة المكالمة (CallHistoryCard)

الملف: `lib/features/calls/presentation/widgets/call_history_card.dart`

كل بطاقة تعرض:
- صورة الطرف الآخر (أو حرف أول الاسم مع لون عشوائي)
- أيقونة نوع المكالمة (هاتف/كاميرا)
- اسم الطرف الآخر (باللون الأحمر إذا فائتة)
- سهم الاتجاه:
  - `↗` مكالمة صادرة
  - `↙` مكالمة واردة
  - `↵` مكالمة فائتة
  - `↳` مكالمة مرفوضة
- الحالة + الوقت + المدة (مثال: "Ended · 3:45 PM · 5:23")

---

## حقن التبعيات (Dependency Injection)

الملف: `lib/core/di/injection_container.dart`

```dart
Future<void> _initCalls() async {
  sl
    // واجهة مزود المكالمات — Singleton لأن الجميع يشارك نفس محرك Agora
    ..registerLazySingleton<CallProviderService>(
      () => AgoraCallProviderService(),
    )
    // مصدر البيانات — Singleton لأنه يدير الاشتراكات
    ..registerLazySingleton<CallsRemoteDataSource>(
      () => CallsRemoteDataSourceImpl(dataBaseService: sl<DataBaseService>()),
    )
    // المستودع — Singleton لأنه يلف مصدر البيانات
    ..registerLazySingleton<CallsRepo>(
      () => CallsRepoImpl(callsRemoteDataSource: sl<CallsRemoteDataSource>()),
    )
    // الـ Cubits — Factory لأن كل شاشة تحتاج نسخة جديدة
    ..registerFactory<StartCallCubit>(
      () => StartCallCubit(callsRepo: sl<CallsRepo>()),
    )
    ..registerFactory<IncomingCallCubit>(
      () => IncomingCallCubit(callsRepo: sl<CallsRepo>()),
    )
    ..registerFactory<ActiveCallCubit>(
      () => ActiveCallCubit(
        callsRepo: sl<CallsRepo>(),
        callProviderService: sl<CallProviderService>(),
      ),
    )
    ..registerFactory<CallsHistoryCubit>(
      () => CallsHistoryCubit(callsRepo: sl<CallsRepo>()),
    );
}
```

---

## التدفق الكامل — من الألف إلى الياء

### سيناريو: أحمد يتصل بمحمد (مكالمة صوتية)

```
الخطوة 1: أحمد يضغط أيقونة الهاتف في المحادثة
    ↓
الخطوة 2: StartCallCubit.startAudioCall(chat)
    ↓
الخطوة 3: CallsRemoteDataSource.startCall()
    ├── التحقق من عدم وجود مكالمة نشطة
    ├── جلب بيانات محمد من Firestore
    ├── إنشاء CallModel بحالة 'ringing'
    ├── حفظ في Firestore: calls/{callId}
    └── إرسال إشعار FCM لمحمد
    ↓
الخطوة 4: StartCallCubit يرسل StartCallSuccess
    ↓
الخطوة 5: الانتقال لـ CallScreen
    ├── طلب صلاحية الميكروفون
    ├── جلب توكن Agora من Supabase
    ├── تهيئة Agora Engine
    ├── الانضمام لقناة Agora: "call_{callId}"
    └── بدء مؤقت 30 ثانية (مكالمة فائتة)
    ↓
═══════════════════════════════════════════
    ↓
الخطوة 6 (جهاز محمد): IncomingCallCubit يكتشف مكالمة واردة
    ├── Firestore يرسل تحديث: calls/{callId} بحالة 'ringing'
    ├── عرض IncomingCallDialog (إذا التطبيق مفتوح)
    └── CallKitService.showIncomingCall() (إشعار نظام)
    ↓
الخطوة 7: محمد يضغط "قبول"
    ├── Firestore: status = 'accepted', acceptedAt = now
    └── الانتقال لـ CallScreen
        ├── طلب صلاحية الميكروفون
        ├── جلب توكن Agora
        ├── الانضمام لنفس القناة: "call_{callId}"
        └── Agora: onUserJoined → المستخدم البعيد انضم
    ↓
═══════════════════════════════════════════
    ↓
الخطوة 8: المكالمة جارية
    ├── أحمد ومحمد يتحدثان عبر Agora
    ├── CallHeader يعرض المؤقت: 00:00 → 00:01 → ...
    └── أزرار التحكم: كتم، سماعة، إنهاء
    ↓
الخطوة 9: أحمد يضغط "End"
    ├── ActiveCallCubit.endCall(duration: 180)
    ├── Firestore: status = 'ended', durationInSeconds = 180
    ├── CallScreen (أحمد): يستقبل ActiveCallEnded
    │   ├── leaveChannel() (Agora)
    │   ├── endAllCalls() (CallKit)
    │   └── Navigator.pop()
    └── CallScreen (محمد): يستقبل ActiveCallEnded
        ├── أو يكتشف onUserOffline (Agora)
        ├── leaveChannel() (Agora)
        └── Navigator.pop()
    ↓
الخطوة 10: المكالمة تظهر في سجل المكالمات لكليهما
    └── CallsHistoryCubit يستقبل تحديث من Firestore
```

---

## ملخص المكونات والعلاقات

```
┌─────────────────────────────────────────────────────────────────┐
│                        واجهة المستخدم                            │
│                                                                 │
│  CallScreen ──→ CallBody ──→ ActiveCallBlocConsumer             │
│                                  ├── CallHeader (صوتي)          │
│                                  ├── CallVideoView (مرئي)       │
│                                  └── CallControls               │
│                                                                 │
│  IncomingCallOverlay ──→ IncomingCallDialog                     │
│  CallsHistoryScreen ──→ CallsHistoryBlocConsumer                │
│                              └── CallHistoryCard                │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                      إدارة الحالة (Cubits)                       │
│                                                                 │
│  StartCallCubit      → بدء مكالمة جديدة                        │
│  IncomingCallCubit   → الاستماع للمكالمات الواردة               │
│  ActiveCallCubit     → إدارة المكالمة النشطة + التحكم           │
│  CallsHistoryCubit   → سجل المكالمات + الحذف                   │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                      طبقة البيانات                               │
│                                                                 │
│  CallsRepo ──→ CallsRemoteDataSource ──→ Firestore             │
│  CallModel, CallStatus                                          │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                      الخدمات الأساسية                            │
│                                                                 │
│  CallProviderService (واجهة مجردة)                              │
│     └── AgoraCallProviderService (Agora RTC)                    │
│  AgoraTokenService → Supabase Edge Function → Agora Token       │
│  CallKitService → flutter_callkit_incoming (شاشة مكالمة نظام)  │
│  ChatNotificationService → FCM (إشعار المكالمة الواردة)        │
│  PendingNavigationService (تنقل معلق بعد قبول من CallKit)      │
└─────────────────────────────────────────────────────────────────┘
```
