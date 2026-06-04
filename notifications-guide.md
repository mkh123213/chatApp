# دليل نظام الإشعارات - تطبيق ALKHATEEB CHAT

## المقدمة

هذا الدليل يشرح بالتفصيل كيف يعمل نظام الإشعارات في التطبيق، ويغطي إشعارات المحادثات الفردية، المحادثات الجماعية، والمكالمات. سيتم شرح كل مكون على حدة مع توضيح كيفية ربطها ببعض.

---

## البنية العامة لنظام الإشعارات

نظام الإشعارات يتكون من ثلاث طبقات رئيسية:

```
┌─────────────────────────────────────────────────────────┐
│                    تطبيق Flutter                         │
│                                                         │
│  ChatNotificationService (إرسال الإشعارات)              │
│  NotificationSaveService (حفظ الإشعارات في Firestore)   │
│  Firebase Messaging      (استقبال الإشعارات)            │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Supabase Edge Function                      │
│                                                         │
│  send-notification (وظيفة إرسال الإشعارات)              │
│  تستخدم FCM v1 HTTP API                                │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│         Firebase Cloud Messaging (FCM)                   │
│                                                         │
│  يوصل الإشعار لجهاز المستخدم المستهدف                  │
│  عبر FCM Token المخزن في Firestore                     │
└─────────────────────────────────────────────────────────┘
```

---

## الخطوة الأولى: إدارة FCM Token

### ما هو FCM Token؟

كل جهاز يسجل دخول على التطبيق يحصل على `FCM Token` فريد من Firebase. هذا التوكن هو "عنوان" الجهاز لاستقبال الإشعارات. بدونه لا يمكن إرسال أي إشعار لهذا الجهاز.

### أين يتم حفظ التوكن؟

يتم حفظ التوكن في مستند المستخدم في Firestore:

```
Firestore: users/{userId}
{
  "name": "أحمد",
  "email": "ahmed@example.com",
  "fcmToken": "dKj3nF8x...طويل جداً...",    ← هذا هو التوكن
  "activeChatId": "",                         ← معرف المحادثة المفتوحة حالياً
  "activeGroupId": ""                         ← معرف المجموعة المفتوحة حالياً
}
```

### كيف يتم حفظ وتحديث التوكن؟

الملف المسؤول: `lib/core/service/push_notification/chat_notification_service.dart`

```dart
Future<void> saveFcmToken({required String userId}) async {
  // 1. الحصول على التوكن الحالي من Firebase
  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  // 2. حفظ التوكن في مستند المستخدم في Firestore
  await _firestore.doc('users/$userId').set(
    {'fcmToken': token},
    SetOptions(merge: true),  // merge حتى لا نحذف البيانات الأخرى
  );

  // 3. الاستماع لتحديث التوكن تلقائياً (يحصل عند إعادة تثبيت التطبيق أو مسح البيانات)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    _firestore.doc('users/$userId').set(
      {'fcmToken': newToken},
      SetOptions(merge: true),
    );
  });
}
```

### متى يتم استدعاء هذه الدالة؟

- عند تسجيل الدخول بنجاح
- عند فتح التطبيق والمستخدم مسجل دخول مسبقاً

### حذف التوكن عند تسجيل الخروج

```dart
Future<void> removeFcmToken({required String userId}) async {
  await _firestore.doc('users/$userId').update(
    {'fcmToken': FieldValue.delete()},
  );
}
```

هذا يمنع وصول إشعارات للمستخدم بعد تسجيل خروجه.

---

## الخطوة الثانية: Supabase Edge Function (الخادم)

### ما هي وظيفتها؟

التطبيق لا يرسل الإشعارات مباشرة عبر FCM. بدلاً من ذلك، يرسل طلب HTTP إلى Supabase Edge Function التي تتعامل مع FCM نيابة عنه.

### لماذا نستخدم Edge Function بدل الإرسال المباشر؟

1. **الأمان**: مفاتيح FCM الخاصة (Service Account Private Key) تبقى على الخادم فقط
2. **المرونة**: يمكن تعديل منطق الإشعارات بدون تحديث التطبيق
3. **التحكم**: يمكن إضافة فلترة أو rate limiting على الخادم

### الملف: `supabase/functions/send-notification/index.ts`

#### البيانات المطلوبة (Request Body):

```json
{
  "token": "fcm_token_of_receiver",     // مطلوب - توكن جهاز المستقبل
  "title": "اسم المرسل",               // اختياري - عنوان الإشعار
  "body": "محتوى الرسالة",             // اختياري - نص الإشعار
  "data": {                             // مطلوب - بيانات إضافية للتوجيه
    "route": "chat",                    // نوع الإشعار: chat, group, call
    "chatId": "abc123"                  // معرف المحادثة/المجموعة/المكالمة
  },
  "dataOnly": false,                    // اختياري - إشعار صامت بدون عرض
  "priority": "high"                    // اختياري - أولوية الإشعار
}
```

#### كيف تعمل الدالة؟

```
1. تستقبل الطلب (POST فقط)
2. تتحقق من وجود token
3. تنشئ JWT موقع باستخدام Service Account Private Key
4. تطلب Access Token من Google OAuth2
5. تبني رسالة FCM حسب نوع الإشعار (chat/group/call)
6. ترسل الرسالة عبر FCM v1 HTTP API
7. ترجع النتيجة للتطبيق
```

#### التعامل مع أنواع الإشعارات المختلفة:

الدالة تفرق بين ثلاث حالات:

**حالة المكالمة (`data.route === "call"`):**
```json
{
  "android": {
    "priority": "high",
    "notification": {
      "sound": "default",
      "channel_id": "call-notifications"
    }
  },
  "notification": {
    "title": "اسم المتصل",
    "body": "مكالمة صوتية واردة"
  }
}
```
- أولوية عالية دائماً حتى يصل الإشعار فوراً
- قناة إشعارات خاصة بالمكالمات
- على iOS: `interruption-level: time-sensitive` لتجاوز وضع عدم الإزعاج

**حالة إشعار صامت (`dataOnly === true`):**
- لا يظهر إشعار للمستخدم
- يُستخدم لتحديث البيانات في الخلفية

**حالة الرسائل العادية (chat/group):**
```json
{
  "android": {
    "priority": "normal",
    "notification": {
      "sound": "default",
      "channel_id": "chat-notifications"
    }
  },
  "notification": {
    "title": "اسم المرسل أو اسم المجموعة",
    "body": "محتوى الرسالة"
  }
}
```

#### متغيرات البيئة المطلوبة على Supabase:

| المتغير | الوصف |
|---------|-------|
| `FCM_CLIENT_EMAIL` | إيميل Service Account من Firebase |
| `FCM_PRIVATE_KEY` | المفتاح الخاص لـ Service Account |
| `FCM_PROJECT_ID` | معرف مشروع Firebase |

---

## إشعارات المحادثات الفردية (Single Chat)

### متى يتم إرسال الإشعار؟

يتم إرسال إشعار في كل مرة يرسل فيها المستخدم رسالة في محادثة فردية. الأنواع المدعومة:

| نوع الرسالة | ما يظهر في الإشعار |
|-------------|-------------------|
| نص (text) | نص الرسالة نفسه |
| صورة (image) | "Image" |
| ملف (file) | اسم الملف الأصلي |
| رسالة صوتية (voice) | "Voice message" |
| ملصق (sticker) | "Sticker" |
| GIF | "GIF" |

### مسار الكود - من إرسال الرسالة حتى وصول الإشعار:

#### 1. المستخدم يرسل رسالة نصية

الملف: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`

```dart
Future<void> sendTextMessage({...}) async {
  // أولاً: إنشاء الرسالة وحفظها في Firestore
  final message = MessageModel(
    id: messageId,
    chatId: chatId,
    senderId: senderId,
    receiverId: receiverId,
    text: text,
    type: 'text',
    // ... باقي الحقول
  );

  await _dataBaseService.setData(
    path: 'chats/$chatId/messages/$messageId',
    data: message.toJson(),
  );

  // ثانياً: تحديث آخر رسالة في المحادثة
  await _updateChatLastMessage(
    chatId: chatId,
    lastMessage: text,
    lastMessageType: 'text',
    time: now,
  );

  // ثالثاً: إرسال الإشعار ← هذا هو السطر المهم
  ChatNotificationService.instance.sendMessageNotification(
    receiverId: receiverId,
    chatId: chatId,
    senderName: getCurrentUser().name ?? senderEmail,
    message: text,
    type: 'text',
  );
}
```

#### 2. دالة إرسال إشعار الرسالة الفردية

الملف: `lib/core/service/push_notification/chat_notification_service.dart`

```dart
Future<void> sendMessageNotification({
  required String receiverId,
  required String chatId,
  required String senderName,
  required String message,
  required String type,
}) async {
  try {
    // الخطوة 1: جلب بيانات المستقبل من Firestore
    final receiverDoc = await _firestore.doc('users/$receiverId').get();
    final data = receiverDoc.data();
    if (data == null) return;

    // الخطوة 2: التحقق - هل المستقبل يقرأ نفس المحادثة الآن؟
    // إذا كان المستقبل فاتح المحادثة حالياً، لا نرسل إشعار
    final activeChatId = data['activeChatId'] as String? ?? '';
    if (activeChatId == chatId) return;  // ← لا إشعار

    // الخطوة 3: جلب FCM Token
    final fcmToken = data['fcmToken'] as String?;
    if (fcmToken == null || fcmToken.isEmpty) return;  // ← لا توكن، لا إشعار

    // الخطوة 4: تحديد نص الإشعار حسب نوع الرسالة
    String body;
    switch (type) {
      case 'image':
        body = 'Image';
      case 'file':
        body = 'File';
      default:
        body = message;  // للنصوص العادية
    }

    // الخطوة 5: إرسال عبر Edge Function
    await _sendViaEdgeFunction(
      token: fcmToken,
      title: senderName,       // عنوان الإشعار = اسم المرسل
      body: body,              // محتوى الإشعار = نص الرسالة أو نوعها
      data: {
        'route': 'chat',       // لتحديد وجهة التنقل عند الضغط على الإشعار
        'chatId': chatId,
      },
    );
  } catch (e) {
    debugPrint('Failed to send message notification: $e');
  }
}
```

### ملخص تدفق إشعار المحادثة الفردية:

```
المرسل يكتب رسالة
        │
        ▼
MessagesRemoteDataSource.sendTextMessage()
        │
        ├── 1. حفظ الرسالة في Firestore: chats/{chatId}/messages/{messageId}
        ├── 2. تحديث lastMessage في المحادثة: chats/{chatId}
        └── 3. ChatNotificationService.sendMessageNotification()
                │
                ├── جلب بيانات المستقبل من: users/{receiverId}
                ├── التحقق: هل activeChatId == chatId ؟
                │   ├── نعم → لا إشعار (المستقبل يقرأ المحادثة)
                │   └── لا → نكمل
                ├── جلب fcmToken
                │   ├── فارغ → لا إشعار
                │   └── موجود → نكمل
                └── _sendViaEdgeFunction()
                        │
                        ▼
                Supabase Edge Function
                        │
                        ▼
                FCM v1 HTTP API
                        │
                        ▼
                جهاز المستقبل يعرض الإشعار
```

### حقل `activeChatId` - كيف يمنع الإشعارات المكررة؟

عندما يفتح المستخدم محادثة معينة، يتم تحديث حقل `activeChatId` في مستنده على Firestore بمعرف المحادثة. وعندما يخرج من المحادثة يتم مسح هذا الحقل.

هذا يعني:
- **المستخدم فاتح المحادثة**: `activeChatId = "chat_abc"` → لا إشعار
- **المستخدم في الشاشة الرئيسية أو محادثة أخرى**: `activeChatId = ""` → يصل إشعار

---

## إشعارات المحادثات الجماعية (Group Chat)

### الفرق عن المحادثات الفردية

في المحادثة الفردية، الإشعار يذهب لشخص واحد. في المحادثة الجماعية، الإشعار يجب أن يصل لجميع أعضاء المجموعة ماعدا المرسل.

### مسار الكود:

#### 1. إرسال رسالة في المجموعة

الملف: `lib/features/groups/data/datasources/groups_remote_data_source.dart`

```dart
Future<void> sendGroupMessage({
  required String groupId,
  required String senderId,
  required String senderEmail,
  required String text,
}) async {
  // 1. حفظ الرسالة في Firestore
  await _dataBaseService.setData(
    path: 'groups/$groupId/messages/$messageId',
    data: {
      'id': messageId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'text': text,
      'createdAt': now,
    },
  );

  // 2. تحديث آخر رسالة في المجموعة
  await _dataBaseService.setData(
    path: 'groups/$groupId',
    data: {
      'lastMessage': text,
      'lastMessageTime': now,
    },
  );

  // 3. جلب بيانات المجموعة لمعرفة الأعضاء
  final groupDoc = await FirebaseFirestore.instance
      .doc('groups/$groupId').get();
  final groupData = groupDoc.data();

  if (groupData != null) {
    final members = List<String>.from(groupData['members'] ?? []);
    final groupName = groupData['name'] as String? ?? 'Group';

    // 4. إرسال الإشعارات ← هذا السطر المهم
    ChatNotificationService.instance.sendGroupMessageNotification(
      groupId: groupId,
      groupName: groupName,
      senderId: senderId,
      senderName: getCurrentUser().name ?? senderEmail,
      message: text,
      memberIds: members,
    );
  }
}
```

#### 2. دالة إرسال إشعار المجموعة

الملف: `lib/core/service/push_notification/chat_notification_service.dart`

```dart
Future<void> sendGroupMessageNotification({
  required String groupId,
  required String groupName,
  required String senderId,
  required String senderName,
  required String message,
  required List<String> memberIds,
}) async {
  try {
    // الخطوة 1: استبعاد المرسل من القائمة
    final otherMembers = memberIds.where((id) => id != senderId);

    // الخطوة 2: لكل عضو في المجموعة (ماعدا المرسل)
    for (final memberId in otherMembers) {
      // جلب بيانات العضو
      final memberDoc = await _firestore.doc('users/$memberId').get();
      final data = memberDoc.data();
      if (data == null) continue;

      // التحقق: هل العضو يقرأ نفس المجموعة الآن؟
      final activeGroupId = data['activeGroupId'] as String? ?? '';
      if (activeGroupId == groupId) continue;  // ← العضو فاتح المجموعة، لا إشعار

      // جلب FCM Token
      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) continue;

      // إرسال الإشعار عبر Edge Function
      await _sendViaEdgeFunction(
        token: fcmToken,
        title: groupName,                    // عنوان الإشعار = اسم المجموعة
        body: '$senderName: $message',       // المحتوى = "اسم المرسل: نص الرسالة"
        data: {
          'route': 'group',                  // لتحديد وجهة التنقل
          'groupId': groupId,
        },
      );
    }
  } catch (e) {
    debugPrint('Failed to send group notification: $e');
  }
}
```

### ملخص تدفق إشعار المحادثة الجماعية:

```
المرسل يكتب رسالة في المجموعة
        │
        ▼
GroupsRemoteDataSource.sendGroupMessage()
        │
        ├── 1. حفظ الرسالة: groups/{groupId}/messages/{messageId}
        ├── 2. تحديث lastMessage: groups/{groupId}
        ├── 3. جلب قائمة الأعضاء من groups/{groupId}
        └── 4. ChatNotificationService.sendGroupMessageNotification()
                │
                └── لكل عضو (ماعدا المرسل):
                        │
                        ├── جلب بيانات العضو من: users/{memberId}
                        ├── التحقق: هل activeGroupId == groupId ؟
                        │   ├── نعم → تخطي هذا العضو
                        │   └── لا → نكمل
                        ├── جلب fcmToken
                        │   ├── فارغ → تخطي
                        │   └── موجود → نكمل
                        └── _sendViaEdgeFunction()
                                │
                                ▼
                        Supabase Edge Function
                                │
                                ▼
                        FCM → جهاز العضو
```

### شكل الإشعار الذي يصل:

**للمحادثة الفردية:**
```
┌─────────────────────────┐
│ أحمد                     │  ← اسم المرسل
│ مرحبا، كيف حالك؟         │  ← نص الرسالة
└─────────────────────────┘
```

**للمحادثة الجماعية:**
```
┌─────────────────────────┐
│ فريق العمل               │  ← اسم المجموعة
│ أحمد: مرحبا، كيف حالكم؟  │  ← اسم المرسل: نص الرسالة
└─────────────────────────┘
```

---

## إشعارات المكالمات

### كيف تختلف عن إشعارات الرسائل؟

إشعارات المكالمات تحتاج معاملة خاصة لأنها:
1. يجب أن تصل فوراً (أولوية عالية)
2. تحتاج تظهر كشاشة مكالمة واردة (عبر CallKit)
3. يجب أن تعمل حتى لو كان الهاتف في وضع عدم الإزعاج (على iOS)

### مسار الكود:

#### 1. بدء المكالمة

الملف: `lib/features/calls/data/datasources/calls_remote_data_source.dart`

```dart
Future<CallModel> startCall({
  required ChatModel chat,
  required CurrentUserModel caller,
  required String type,  // 'audio' أو 'video'
}) async {
  // ... إنشاء CallModel وحفظه في Firestore ...

  // إرسال إشعار المكالمة
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

#### 2. دالة إرسال إشعار المكالمة

```dart
Future<void> sendCallNotification({
  required String receiverId,
  required String callId,
  required String callerName,
  required String callerPhotoUrl,
  required String callType,
}) async {
  try {
    // جلب بيانات المستقبل
    final receiverDoc = await _firestore.doc('users/$receiverId').get();
    final data = receiverDoc.data();
    if (data == null) return;

    final fcmToken = data['fcmToken'] as String?;
    if (fcmToken == null || fcmToken.isEmpty) return;

    final callTypeLabel = callType == 'video' ? 'Video' : 'Audio';

    // إرسال بأولوية عالية
    await _sendViaEdgeFunction(
      token: fcmToken,
      title: callerName,
      body: 'Incoming $callTypeLabel Call',
      data: {
        'route': 'call',                    // ← يخبر Edge Function أن هذا إشعار مكالمة
        'callId': callId,
        'callerName': callerName,
        'callerPhotoUrl': callerPhotoUrl,
        'callType': callType,
      },
      priority: 'high',                     // ← أولوية عالية
    );
  } catch (e) {
    debugPrint('Failed to send call notification: $e');
  }
}
```

#### 3. استقبال إشعار المكالمة وعرض شاشة CallKit

الملف: `lib/core/service/call_service/callkit_service.dart`

عندما يصل الإشعار للمستقبل، يتم عرض شاشة المكالمة الواردة الأصلية (Native Call UI):

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
    type: isVideo ? 1 : 0,        // 0 = صوتي، 1 = فيديو
    duration: 30000,               // 30 ثانية مهلة الرد
    textAccept: 'Accept',
    textDecline: 'Decline',
    android: const AndroidParams(
      isCustomNotification: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      isShowFullLockedScreen: true,  // ← يظهر حتى لو الشاشة مقفلة
    ),
    ios: const IOSParams(
      supportsVideo: true,
      ringtonePath: 'system_ringtone_default',
    ),
  );

  await FlutterCallkitIncoming.showCallkitIncoming(params);
}
```

#### 4. التعامل مع أحداث المكالمة

```dart
void _onCallKitEvent(CallEvent? event) {
  switch (event.event) {
    case Event.actionCallAccept:     // المستخدم قبل المكالمة
      _handleAccept(callId);         // → تحديث Firestore: status = 'accepted'
      break;
    case Event.actionCallDecline:    // المستخدم رفض المكالمة
      _handleDecline(callId);        // → تحديث Firestore: status = 'rejected'
      break;
    case Event.actionCallTimeout:    // انتهت المهلة بدون رد
      _handleTimeout(callId);        // → تحديث Firestore: status = 'missed'
      break;
  }
}
```

---

## دالة الإرسال المشتركة (`_sendViaEdgeFunction`)

كل أنواع الإشعارات تمر عبر هذه الدالة:

```dart
Future<void> _sendViaEdgeFunction({
  required String token,
  String? title,
  String? body,
  required Map<String, String> data,
  bool dataOnly = false,
  String? priority,
}) async {
  try {
    await Supabase.instance.client.functions.invoke(
      'send-notification',     // اسم Edge Function على Supabase
      body: {
        'token': token,        // FCM Token للمستقبل
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        'data': data,          // بيانات التنقل (route, chatId/groupId/callId)
        'dataOnly': dataOnly,  // هل إشعار صامت؟
        if (priority != null) 'priority': priority,
      },
    );
  } catch (e) {
    debugPrint('Edge function error: $e');
  }
}
```

---

## هيكل Firestore المستخدم

### المجموعات (Collections):

```
Firestore Database
│
├── users/                          ← بيانات المستخدمين
│   └── {userId}/
│       ├── name
│       ├── email
│       ├── photoUrl
│       ├── fcmToken               ← توكن الإشعارات
│       ├── activeChatId           ← المحادثة الفردية المفتوحة حالياً
│       └── activeGroupId          ← المجموعة المفتوحة حالياً
│
├── chats/                          ← المحادثات الفردية
│   └── {chatId}/
│       ├── users: [userId1, userId2]
│       ├── lastMessage
│       ├── lastMessageType
│       ├── lastMessageTime
│       └── messages/               ← رسائل المحادثة (sub-collection)
│           └── {messageId}/
│               ├── senderId
│               ├── receiverId
│               ├── text
│               ├── type
│               ├── isRead          ← حالة القراءة
│               └── createdAt
│
├── groups/                         ← المحادثات الجماعية
│   └── {groupId}/
│       ├── name
│       ├── members: [userId1, userId2, ...]
│       ├── admins: [userId1]
│       ├── lastMessage
│       ├── lastMessageTime
│       └── messages/               ← رسائل المجموعة (sub-collection)
│           └── {messageId}/
│               ├── senderId
│               ├── senderEmail
│               ├── text
│               ├── readBy: [userId1, userId2]  ← من قرأ الرسالة
│               └── createdAt
│
├── calls/                          ← سجل المكالمات
│   └── {callId}/
│       ├── callerId
│       ├── receiverId
│       ├── status                  ← ringing/accepted/rejected/ended/missed
│       ├── type                    ← audio/video
│       └── channelId              ← معرف قناة Agora
│
└── global_notifications/           ← إشعارات عامة محفوظة
    └── {notificationId}/
        ├── user_id
        ├── title
        ├── body
        ├── isSeen
        └── created_at
```

---

## قنوات الإشعارات على Android

التطبيق يستخدم قناتين منفصلتين:

| القناة | معرفها | الاستخدام |
|--------|--------|----------|
| إشعارات المحادثات | `chat-notifications` | رسائل المحادثات الفردية والجماعية |
| إشعارات المكالمات | `call-notifications` | المكالمات الواردة |

هذا يسمح للمستخدم بالتحكم في كل نوع على حدة من إعدادات النظام.

---

## وضع عدم الإزعاج (Do Not Disturb)

الملف: `lib/core/service/dnd/dnd_service.dart`

التطبيق يوفر وضع "عدم الإزعاج" الذي يُخزن محلياً في SharedPreferences:

```dart
class DndService {
  final ValueNotifier<bool> isEnabled = ValueNotifier(false);

  void init() {
    isEnabled.value = SharedPref().getBoolean(PrefKeys.doNotDisturb) ?? false;
  }

  Future<void> toggle() async {
    isEnabled.value = !isEnabled.value;
    await SharedPref().setBoolean(PrefKeys.doNotDisturb, isEnabled.value);
  }
}
```

**ملاحظة مهمة**: وضع DnD في الكود الحالي يعمل على مستوى العرض فقط (يمنع عرض الإشعارات المحلية). الإشعارات من FCM ستستمر بالوصول لأن الفلترة تحدث على جانب العميل وليس الخادم.

---

## حفظ الإشعارات

الملف: `lib/core/service/push_notification/notification_save_service.dart`

عند استقبال إشعار، يتم حفظه في Firestore لعرضه لاحقاً:

```dart
class NotificationSaveService {
  static Future<void> save(RemoteMessage message) async {
    final userId = SharedPref().getInt(PrefKeys.userId);
    if (userId == null || userId == 0) return;

    fierStore.setData(
      path: 'global_notifications/${message.messageId}',
      data: {
        'notification_id': message.messageId,
        'user_id': userId,
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'isSeen': false,
      },
    );
  }
}
```

---

## ملخص شامل

| الميزة | المحادثة الفردية | المحادثة الجماعية | المكالمة |
|--------|-----------------|-------------------|---------|
| عنوان الإشعار | اسم المرسل | اسم المجموعة | اسم المتصل |
| محتوى الإشعار | نص الرسالة أو نوعها | "اسم المرسل: نص الرسالة" | "Incoming Audio/Video Call" |
| المستقبلون | شخص واحد | جميع الأعضاء ماعدا المرسل | شخص واحد |
| فحص التكرار | activeChatId | activeGroupId | لا يوجد |
| الأولوية | عادية | عادية | عالية |
| route | `chat` | `group` | `call` |
| البيانات الإضافية | chatId | groupId | callId, callerName, callerPhotoUrl, callType |
| قناة Android | chat-notifications | chat-notifications | call-notifications |
