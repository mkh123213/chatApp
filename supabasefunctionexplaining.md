# دليل Supabase في تطبيق ALKHATEEB CHAT

## المقدمة — ما هو Supabase ولماذا نستخدمه؟

Supabase هو بديل مفتوح المصدر لـ Firebase يوفر قاعدة بيانات PostgreSQL، تخزين ملفات (Storage)، مصادقة (Auth)، ودوال خادم (Edge Functions).

في هذا التطبيق، **لا نستخدم Supabase كبديل لـ Firebase** بل نستخدمه **بجانب Firebase** لسببين محددين:

| الخدمة | نستخدمها لـ | لماذا لا Firebase؟ |
|--------|-------------|-------------------|
| **Supabase Storage** | تخزين الملفات (صور، ملفات، تسجيلات صوتية) | Firebase Storage أغلى + Supabase Storage أسهل في الإعداد وأرخص |
| **Supabase Edge Functions** | وظائف خادم (إرسال إشعارات، توليد توكن Agora) | Firebase Cloud Functions تحتاج خطة Blaze المدفوعة + Node.js، بينما Supabase Edge Functions مجانية وتستخدم Deno |

---

## هيكل مجلد Supabase

```
supabase/
├── .temp/
│   └── linked-project.json          ← معلومات المشروع المربوط
└── functions/
    ├── send-notification/
    │   └── index.ts                  ← دالة إرسال الإشعارات عبر FCM
    └── agora-token/
        └── index.ts                  ← دالة توليد توكن Agora للمكالمات
```

### ملف المشروع المربوط — `linked-project.json`

```json
{
  "ref": "nkzezuvubeloiglhdpfu",
  "name": "chatapp",
  "organization_id": "sfplxizngkclyuojntss"
}
```

- **ref**: معرف المشروع على Supabase (يظهر في الرابط: `https://nkzezuvubeloiglhdpfu.supabase.co`)
- **name**: اسم المشروع
- **organization_id**: معرف المنظمة

---

## الاتصال بـ Supabase من التطبيق

### التهيئة في `main.dart`

```dart
await Supabase.initialize(
  url: 'https://nkzezuvubeloiglhdpfu.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

| المعامل | الوصف |
|---------|-------|
| `url` | رابط مشروع Supabase (من لوحة التحكم > Settings > API) |
| `anonKey` | مفتاح عام (anon key) — آمن للاستخدام في التطبيق لأن Supabase يتحكم بالصلاحيات عبر Row Level Security |

بعد التهيئة، يمكنك الوصول لـ Supabase في أي مكان عبر:
```dart
Supabase.instance.client              // ← العميل الرئيسي
Supabase.instance.client.storage      // ← خدمة التخزين
Supabase.instance.client.functions    // ← Edge Functions
```

---

## الجزء الأول: Supabase Storage (تخزين الملفات)

### ما هو Storage؟

Supabase Storage هو نظام تخزين ملفات مبني على Amazon S3. يسمح لك برفع وتحميل وحذف الملفات منظمة في "دلاء" (Buckets) و"مجلدات".

### هيكل التخزين في التطبيق

اسم الدلو (Bucket): **`chatapp`**

```
chatapp/                                    ← الدلو الرئيسي
│
├── chats/                                  ← ملفات المحادثات الفردية
│   └── {chatId}/
│       └── messages/
│           ├── images/                     ← صور الرسائل
│           │   └── 1717400000000.jpg
│           ├── files/                      ← ملفات مرفقة
│           │   └── 1717400000000_document.pdf
│           └── audio/                      ← رسائل صوتية
│               └── 1717400000000.m4a
│
├── groups/                                 ← ملفات المجموعات
│   └── {groupId}/
│       ├── image/                          ← صورة المجموعة
│       │   └── 1717400000000.jpg
│       └── messages/
│           ├── images/                     ← صور رسائل المجموعة
│           └── files/                      ← ملفات رسائل المجموعة
│
├── statuses/                               ← صور الحالات (Stories)
│   └── {userId}/
│       └── 1717400000000.jpg
│
└── images/                                 ← صور عامة (صور الملف الشخصي مثلاً)
    └── {ownerId}/
        └── 1717400000000.jpg
```

### الخدمة المسؤولة — `SupabaseStorageService`

الملف: `lib/core/service/supabase/supabase_storage_service.dart`

هذه الخدمة تغلف كل عمليات التخزين. كل دالة ترفع ملف وترجع `UploadedFileData` يحتوي على:

```dart
class UploadedFileData {
  final String url;           // رابط عام للملف (يمكن لأي شخص الوصول)
  final String storagePath;   // مسار الملف في Storage (للحذف لاحقاً)
  final String fileName;      // اسم الملف
}
```

### دوال الرفع المتاحة

| الدالة | الاستخدام | المسار في Storage |
|--------|----------|-------------------|
| `uploadChatImage()` | صورة في محادثة فردية | `chats/{chatId}/messages/images/{timestamp}.jpg` |
| `uploadChatFile()` | ملف في محادثة فردية | `chats/{chatId}/messages/files/{timestamp}_{name}` |
| `uploadChatAudio()` | رسالة صوتية في محادثة فردية | `chats/{chatId}/messages/audio/{timestamp}.m4a` |
| `uploadGroupImage()` | صورة المجموعة | `groups/{groupId}/image/{timestamp}.jpg` |
| `uploadMessageImage()` | صورة في رسالة مجموعة | `groups/{groupId}/messages/images/{timestamp}.jpg` |
| `uploadMessageFile()` | ملف في رسالة مجموعة | `groups/{groupId}/messages/files/{timestamp}_{name}` |
| `uploadStatusImage()` | صورة حالة (Story) | `statuses/{userId}/{timestamp}.jpg` |
| `uploadImage()` | رفع صورة عامة | `{folder}/{ownerId}/{timestamp}.jpg` |
| `removeFile()` | حذف ملف | يستقبل `storagePath` ويحذف الملف |
| `getPublicUrl()` | الحصول على رابط عام | يبني الرابط من اسم المجلد والملف |

### كيف يعمل الرفع — شرح خطوة بخطوة

لنأخذ مثال رفع صورة في محادثة فردية:

```dart
Future<UploadedFileData> uploadChatImage({
  required String chatId,
  required File file,
}) async {
  // الخطوة 1: تنظيف معرف المحادثة (إزالة الأحرف الخاصة)
  final cleanChatId = _cleanPathPart(chatId);

  // الخطوة 2: إنشاء اسم فريد للملف باستخدام الـ timestamp
  final extension = _safeExtension(file.path);  // .jpg, .png, etc.
  final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
  // مثال: "1717400000000.jpg"

  // الخطوة 3: بناء المسار الكامل
  final storagePath = 'chats/$cleanChatId/messages/images/$fileName';
  // مثال: "chats/userId1_userId2/messages/images/1717400000000.jpg"

  // الخطوة 4: رفع الملف إلى Supabase Storage
  await _client.storage.from(bucketName).upload(
    storagePath,
    file,
    fileOptions: const FileOptions(
      cacheControl: '3600',    // كاش ساعة واحدة
      upsert: false,           // لا تستبدل ملف موجود بنفس الاسم
    ),
  );

  // الخطوة 5: الحصول على الرابط العام
  final publicUrl = _client.storage.from(bucketName).getPublicUrl(storagePath);
  // مثال: "https://nkzezuvubeloiglhdpfu.supabase.co/storage/v1/object/public/chatapp/chats/userId1_userId2/messages/images/1717400000000.jpg"

  // الخطوة 6: إرجاع البيانات
  return UploadedFileData(
    url: publicUrl,
    storagePath: storagePath,
    fileName: fileName,
  );
}
```

### تنظيف أسماء المسارات

```dart
String _cleanPathPart(String value) {
  return value
      .trim()                                    // إزالة المسافات
      .replaceAll(RegExp(r'[^\w.\-]'), '_')      // استبدال الأحرف الخاصة بـ _
      .replaceAll(RegExp(r'_+'), '_');            // دمج عدة _ متتالية
}
```

هذا يمنع أخطاء Storage الناتجة عن أحرف خاصة في أسماء المستخدمين أو معرفات المحادثات.

### حذف الملفات

عند حذف رسالة تحتوي على ملف (صورة، ملف، صوت)، يتم حذف الملف من Storage أيضاً:

```dart
Future<void> removeFile({required String storagePath}) async {
  final cleaned = storagePath.trim();
  if (cleaned.isEmpty) return;
  await _client.storage.from(bucketName).remove([cleaned]);
}
```

### مسار التدفق الكامل — من رفع الصورة حتى ظهورها

```
المستخدم يختار صورة من المعرض
        │
        ▼
SendMessageCubit.sendImageMessage()
        │
        ▼
MessagesRemoteDataSource.sendImageMessage()
        │
        ├── 1. SupabaseStorageService.uploadChatImage()
        │       ├── رفع الملف إلى Supabase Storage
        │       └── إرجاع UploadedFileData (url, storagePath, fileName)
        │
        ├── 2. إنشاء MessageModel مع:
        │       ├── type: 'image'
        │       ├── mediaUrl: uploadResult.url       ← الرابط العام
        │       └── storagePath: uploadResult.storagePath  ← للحذف لاحقاً
        │
        ├── 3. حفظ الرسالة في Firestore
        │       path: chats/{chatId}/messages/{messageId}
        │
        └── 4. إرسال إشعار للمستقبل
                ChatNotificationService.sendMessageNotification()

                          ⇩

المستقبل يستقبل الرسالة عبر Firestore Stream
        │
        ▼
واجهة المستخدم تعرض الصورة عبر:
  CachedNetworkImage(imageUrl: message.mediaUrl)
        │
        ▼
  الصورة تُحمَّل من: https://nkzezuvubeloiglhdpfu.supabase.co/storage/v1/object/public/chatapp/...
```

---

## الجزء الثاني: Edge Functions (دوال الخادم)

### ما هي Edge Functions؟

Edge Functions هي دوال تعمل على خادم Supabase (ليس على جهاز المستخدم). تُكتب بلغة TypeScript وتعمل على بيئة Deno. تستخدم عندما تحتاج:

1. **إخفاء مفاتيح سرية**: مثل مفاتيح FCM أو Agora — لا يجب أن تكون في التطبيق
2. **تنفيذ عمليات لا يمكن الوثوق بالعميل فيها**: مثل توليد توكنات مصادقة
3. **التواصل مع APIs خارجية**: مثل FCM v1 API الذي يحتاج Service Account

### كيف يتم استدعاء Edge Function من Flutter؟

```dart
final response = await Supabase.instance.client.functions.invoke(
  'function-name',        // ← اسم الدالة (اسم المجلد في supabase/functions/)
  body: {                 // ← البيانات المرسلة (JSON)
    'key': 'value',
  },
);
```

هذا يرسل طلب POST إلى:
```
https://nkzezuvubeloiglhdpfu.supabase.co/functions/v1/function-name
```

---

## الدالة الأولى: `send-notification` — إرسال الإشعارات

### ما وظيفتها؟

ترسل إشعارات Push عبر Firebase Cloud Messaging (FCM v1 API) لأجهزة المستخدمين. تُستخدم لـ:
- إشعارات الرسائل في المحادثات الفردية
- إشعارات الرسائل في المجموعات
- إشعارات المكالمات الواردة

### لماذا نحتاج Edge Function لهذا؟

FCM v1 API يحتاج **Access Token** من Google OAuth2، والحصول على هذا التوكن يتطلب **Service Account Private Key**. هذا المفتاح **سري جداً** ولا يجب أن يكون في التطبيق أبداً. لذلك نضعه على الخادم (Edge Function) والتطبيق يرسل طلب للـ Edge Function التي تتعامل مع FCM نيابة عنه.

### متغيرات البيئة المطلوبة على Supabase

| المتغير | الوصف | من أين تحصل عليه |
|---------|-------|------------------|
| `FCM_CLIENT_EMAIL` | إيميل Service Account | Firebase Console > Project Settings > Service Accounts |
| `FCM_PRIVATE_KEY` | المفتاح الخاص (RSA) | نفس المكان — حمّل ملف JSON وانسخ الحقل `private_key` |
| `FCM_PROJECT_ID` | معرف مشروع Firebase | Firebase Console > Project Settings > General |

### كيفية تعيين المتغيرات

من خلال Supabase CLI:
```bash
supabase secrets set FCM_CLIENT_EMAIL="firebase-adminsdk-xxxxx@project-id.iam.gserviceaccount.com"
supabase secrets set FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEv..."
supabase secrets set FCM_PROJECT_ID="your-project-id"
```

أو من لوحة تحكم Supabase:
**Dashboard > Edge Functions > Manage Secrets**

### شرح الكود سطراً بسطر

#### القسم 1: دوال مساعدة لتشفير Base64 URL-safe

```typescript
function base64url(data: Uint8Array): string {
  return btoa(String.fromCharCode(...data))
    .replace(/\+/g, "-")      // استبدال + بـ -
    .replace(/\//g, "_")      // استبدال / بـ _
    .replace(/=+$/, "");      // حذف = من النهاية
}

function base64urlEncode(str: string): string {
  return base64url(new TextEncoder().encode(str));
}
```

JWT يستخدم Base64 URL-safe (بدون `+`, `/`, `=`) لأن هذه الأحرف لها معاني خاصة في URLs.

#### القسم 2: الحصول على Access Token من Google

```typescript
async function getAccessToken(): Promise<string> {
  // 1. قراءة بيانات Service Account من متغيرات البيئة
  const clientEmail = Deno.env.get("FCM_CLIENT_EMAIL")!;
  const rawKey = Deno.env.get("FCM_PRIVATE_KEY")!;
  const privateKeyPem = rawKey.replace(/\\n/g, "\n");  // إصلاح أسطر المفتاح
  const now = Math.floor(Date.now() / 1000);

  // 2. بناء JWT Header
  const header = base64urlEncode(JSON.stringify({
    alg: "RS256",    // خوارزمية التوقيع
    typ: "JWT"
  }));

  // 3. بناء JWT Payload
  const payload = base64urlEncode(JSON.stringify({
    iss: clientEmail,                                           // المُصدر
    scope: "https://www.googleapis.com/auth/firebase.messaging", // الصلاحية المطلوبة
    aud: "https://oauth2.googleapis.com/token",                  // الجمهور
    iat: now,                                                    // وقت الإصدار
    exp: now + 3600,                                             // انتهاء الصلاحية (ساعة)
  }));

  // 4. تحويل المفتاح الخاص من PEM إلى bytes
  const pemBody = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  // 5. استيراد المفتاح كـ CryptoKey
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8", keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false, ["sign"]
  );

  // 6. توقيع JWT
  const signInput = new TextEncoder().encode(`${header}.${payload}`);
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", cryptoKey, signInput)
  );
  const jwt = `${header}.${payload}.${base64url(signature)}`;

  // 7. طلب Access Token من Google OAuth2
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;  // ← هذا التوكن صالح لمدة ساعة
}
```

#### مخطط عملية الحصول على Access Token:

```
Edge Function
    │
    ├── 1. قراءة Service Account (email + private key)
    ├── 2. بناء JWT وتوقيعه بالمفتاح الخاص
    ├── 3. إرسال JWT لـ Google OAuth2
    │       POST https://oauth2.googleapis.com/token
    │
    ▼
Google OAuth2
    │
    └── 4. التحقق من JWT → إرجاع Access Token
            { "access_token": "ya29.c.c0ASRK..." }
```

#### القسم 3: الدالة الرئيسية — استقبال الطلب وإرسال الإشعار

```typescript
Deno.serve(async (req: Request) => {
  // قبول POST فقط
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // قراءة البيانات من الطلب
  const { token, title, body, data, dataOnly, priority } = await req.json();

  // التحقق من وجود FCM token
  if (!token) {
    return new Response(JSON.stringify({ error: "token is required" }), { status: 400 });
  }

  // الحصول على Access Token
  const accessToken = await getAccessToken();
  const projectId = Deno.env.get("FCM_PROJECT_ID")!;

  // تحديد نوع الإشعار
  const isCall = data?.route === "call";
```

#### القسم 4: بناء رسالة FCM حسب النوع

الدالة تبني رسالة مختلفة حسب ثلاث حالات:

**حالة 1: مكالمة واردة (`isCall === true`)**
```typescript
// Android
android: {
  priority: "high",                          // أولوية عالية — يوصل فوراً
  notification: {
    sound: "default",
    channel_id: "call-notifications",        // قناة إشعارات المكالمات
  },
}
// iOS
apns: {
  payload: {
    aps: {
      "content-available": 1,
      alert: { title: "اسم المتصل", body: "Incoming Video Call" },
      sound: "default",
      "interruption-level": "time-sensitive", // يتجاوز وضع عدم الإزعاج
    },
  },
  headers: {
    "apns-push-type": "alert",
    "apns-priority": "10",                   // أعلى أولوية
  },
}
// + notification مرئي
notification: {
  title: "اسم المتصل",
  body: "Incoming Audio Call",
}
```

**حالة 2: إشعار صامت (`dataOnly === true`)**
```typescript
// Android
android: { priority: "high" }    // بدون notification — صامت
// iOS
apns: {
  payload: { aps: { "content-available": 1 } },    // background refresh
  headers: { "apns-push-type": "background", "apns-priority": "5" },
}
// لا يوجد notification — البيانات فقط
```

**حالة 3: رسالة عادية (محادثة فردية أو جماعية)**
```typescript
// Android
android: {
  priority: "normal",
  notification: {
    sound: "default",
    channel_id: "chat-notifications",        // قناة إشعارات المحادثات
  },
}
// iOS
apns: {
  payload: { aps: { sound: "default", "content-available": 1 } },
  headers: { "apns-push-type": "alert", "apns-priority": "10" },
}
// + notification مرئي
notification: {
  title: "اسم المرسل",
  body: "نص الرسالة",
}
```

#### القسم 5: إرسال الرسالة عبر FCM v1 API

```typescript
const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

const response = await fetch(fcmUrl, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${accessToken}`,    // ← التوكن من getAccessToken()
  },
  body: JSON.stringify({ message }),
});
```

### التدفق الكامل للإشعار

```
تطبيق Flutter (المرسل)
    │
    ├── ChatNotificationService.sendMessageNotification()
    │       أو sendGroupMessageNotification()
    │       أو sendCallNotification()
    │
    └── _sendViaEdgeFunction()
            │
            │  POST https://nkzezuvubeloiglhdpfu.supabase.co/functions/v1/send-notification
            │  Body: { token, title, body, data, dataOnly, priority }
            │
            ▼
    Supabase Edge Function (send-notification)
            │
            ├── 1. getAccessToken()
            │       ├── بناء JWT من Service Account
            │       └── طلب Access Token من Google OAuth2
            │
            ├── 2. بناء رسالة FCM حسب النوع (call/dataOnly/message)
            │
            └── 3. إرسال عبر FCM v1 API
                    POST https://fcm.googleapis.com/v1/projects/{id}/messages:send
                    │
                    ▼
            Firebase Cloud Messaging
                    │
                    ▼
            جهاز المستقبل يعرض الإشعار
```

### البيانات التي يرسلها التطبيق لـ Edge Function

**لرسالة محادثة فردية:**
```json
{
  "token": "fcm_token_للمستقبل",
  "title": "أحمد",
  "body": "مرحبا كيف حالك",
  "data": {
    "route": "chat",
    "chatId": "userId1_userId2"
  }
}
```

**لرسالة مجموعة:**
```json
{
  "token": "fcm_token_للعضو",
  "title": "فريق العمل",
  "body": "أحمد: مرحبا",
  "data": {
    "route": "group",
    "groupId": "abc123"
  }
}
```

**لمكالمة واردة:**
```json
{
  "token": "fcm_token_للمستقبل",
  "title": "أحمد",
  "body": "Incoming Audio Call",
  "data": {
    "route": "call",
    "callId": "xyz789",
    "callerName": "أحمد",
    "callerPhotoUrl": "https://...",
    "callType": "audio"
  },
  "priority": "high"
}
```

---

## الدالة الثانية: `agora-token` — توليد توكن المكالمات

### ما وظيفتها؟

تولّد توكن مؤقت (صالح لساعة واحدة) يسمح للمستخدم بالانضمام لقناة Agora RTC للمكالمات الصوتية والمرئية.

### لماذا نحتاج Edge Function لهذا؟

توليد التوكن يحتاج **App Certificate** وهو سر يجب ألا يكون في التطبيق. إذا وضعته في التطبيق، أي شخص يفك تجميع الـ APK يمكنه استخدامه لإنشاء توكنات والانضمام لأي قناة.

### متغيرات البيئة المطلوبة على Supabase

| المتغير | الوصف | من أين تحصل عليه |
|---------|-------|------------------|
| `AGORA_APP_ID` | معرف تطبيق Agora | Agora Console > Project Management > App ID |
| `AGORA_APP_CERTIFICATE` | شهادة التطبيق السرية | نفس المكان — فعّلها إذا لم تكن مفعلة |

### شرح الكود بالكامل

```typescript
// استيراد مكتبة توليد التوكن الرسمية من Agora
import { RtcTokenBuilder, RtcRole } from "npm:agora-token@2.0.3";

// قراءة المتغيرات السرية
const APP_ID = Deno.env.get("AGORA_APP_ID")!;
const APP_CERTIFICATE = Deno.env.get("AGORA_APP_CERTIFICATE")!;
const TOKEN_EXPIRY_SECONDS = 3600;   // صلاحية التوكن: ساعة واحدة

Deno.serve(async (req: Request) => {
  // قبول POST فقط
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    // قراءة البيانات من الطلب
    const { channelName, uid, role } = await req.json();

    // channelName مطلوب — بدونه لا يمكن توليد توكن
    if (!channelName) {
      return new Response(
        JSON.stringify({ error: "channelName is required" }),
        { status: 400 }
      );
    }

    // تحديد الدور:
    // publisher = يرسل ويستقبل صوت/فيديو (المشاركون في المكالمة)
    // subscriber = يستقبل فقط (المشاهدون — غير مستخدم حالياً)
    const tokenRole = role === "subscriber"
      ? RtcRole.SUBSCRIBER
      : RtcRole.PUBLISHER;

    const userUid = uid ?? 0;    // معرف رقمي للمستخدم
    const expireTime = Math.floor(Date.now() / 1000) + TOKEN_EXPIRY_SECONDS;

    // توليد التوكن باستخدام المكتبة الرسمية
    const token = RtcTokenBuilder.buildTokenWithUid(
      APP_ID,           // معرف التطبيق
      APP_CERTIFICATE,  // الشهادة السرية
      channelName,      // اسم القناة (مثل: "call_abc123")
      userUid,          // معرف المستخدم الرقمي
      tokenRole,        // publisher أو subscriber
      expireTime,       // وقت انتهاء الصلاحية (privilege expire)
      expireTime        // وقت انتهاء التوكن (token expire)
    );

    // إرجاع التوكن مع معلومات إضافية
    return new Response(
      JSON.stringify({
        token,                                  // التوكن المولّد
        appId: APP_ID,                          // معرف التطبيق (عام — يحتاجه SDK)
        expiresIn: TOKEN_EXPIRY_SECONDS         // صلاحية بالثواني
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("Error:", e);
    return new Response(
      JSON.stringify({ error: (e as Error).message }),
      { status: 500 }
    );
  }
});
```

### من يستدعي هذه الدالة في Flutter؟

الملف: `lib/core/service/call_service/agora_token_service.dart`

```dart
class AgoraTokenService {
  Future<String> generateToken({
    required String channelName,    // مثل: "call_abc123"
    required int uid,               // معرف رقمي مشتق من Firebase UID
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'agora-token',                // ← اسم Edge Function
      body: {
        'channelName': channelName,
        'uid': uid,
        'role': 'publisher',
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['token'] as String;
  }
}
```

### التدفق الكامل — من بدء المكالمة حتى الانضمام للقناة

```
المستخدم يضغط "اتصال"
        │
        ▼
CallScreen._initializeCall()
        │
        ├── 1. حساب UID رقمي من Firebase UID
        │       uid = _stableUidHash(getCurrentUser().uid)
        │
        ├── 2. AgoraTokenService.generateToken()
        │       │
        │       │  POST https://nkzezuvubeloiglhdpfu.supabase.co/functions/v1/agora-token
        │       │  Body: { channelName: "call_abc123", uid: 1234567, role: "publisher" }
        │       │
        │       ▼
        │   Supabase Edge Function (agora-token)
        │       │
        │       ├── قراءة APP_ID و APP_CERTIFICATE من المتغيرات السرية
        │       ├── توليد التوكن بمكتبة agora-token
        │       └── إرجاع: { token: "007eJx...", appId: "f12ce5...", expiresIn: 3600 }
        │       │
        │       ▼
        │   Flutter يستقبل التوكن
        │
        ├── 3. تهيئة Agora Engine
        │       _callProvider.initialize()
        │
        └── 4. الانضمام للقناة بالتوكن
                _callProvider.joinChannel(
                  channelId: "call_abc123",
                  token: "007eJx...",         ← التوكن من Edge Function
                  uid: 1234567,
                  isVideo: false,
                )
                │
                ▼
            خوادم Agora RTC
            (الصوت/الفيديو ينتقل مباشرة بين المستخدمين)
```

---

## نشر Edge Functions

### كيف يتم النشر؟

عبر Supabase CLI:

```bash
# نشر كل الدوال
supabase functions deploy

# أو نشر دالة محددة
supabase functions deploy send-notification
supabase functions deploy agora-token
```

### متطلبات النشر

1. **Supabase CLI** مثبت: `npm install -g supabase`
2. **تسجيل الدخول**: `supabase login`
3. **ربط المشروع**: `supabase link --project-ref nkzezuvubeloiglhdpfu`
4. **تعيين المتغيرات السرية** (مرة واحدة):
```bash
supabase secrets set FCM_CLIENT_EMAIL="..."
supabase secrets set FCM_PRIVATE_KEY="..."
supabase secrets set FCM_PROJECT_ID="..."
supabase secrets set AGORA_APP_ID="..."
supabase secrets set AGORA_APP_CERTIFICATE="..."
```

---

## ملخص شامل — كل خدمات Supabase في التطبيق

```
┌─────────────────────────────────────────────────────────────────┐
│                      Supabase في التطبيق                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   Supabase Storage                        │   │
│  │                                                          │   │
│  │  Bucket: chatapp                                         │   │
│  │                                                          │   │
│  │  يخزن:                                                   │   │
│  │  • صور رسائل المحادثات الفردية                           │   │
│  │  • ملفات ورسائل صوتية المحادثات الفردية                  │   │
│  │  • صور وملفات رسائل المجموعات                            │   │
│  │  • صور المجموعات                                         │   │
│  │  • صور الحالات (Stories)                                  │   │
│  │  • صور الملفات الشخصية                                   │   │
│  │                                                          │   │
│  │  Flutter ← SupabaseStorageService                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Edge Function: send-notification              │   │
│  │                                                          │   │
│  │  الوظيفة: إرسال إشعارات Push عبر FCM v1 API             │   │
│  │                                                          │   │
│  │  يستخدم:                                                 │   │
│  │  • FCM_CLIENT_EMAIL (متغير بيئة)                        │   │
│  │  • FCM_PRIVATE_KEY (متغير بيئة)                         │   │
│  │  • FCM_PROJECT_ID (متغير بيئة)                          │   │
│  │                                                          │   │
│  │  يدعم 3 أنواع:                                           │   │
│  │  • إشعار رسالة محادثة (route: chat)                      │   │
│  │  • إشعار رسالة مجموعة (route: group)                     │   │
│  │  • إشعار مكالمة واردة (route: call) — أولوية عالية       │   │
│  │                                                          │   │
│  │  Flutter ← ChatNotificationService._sendViaEdgeFunction  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               Edge Function: agora-token                  │   │
│  │                                                          │   │
│  │  الوظيفة: توليد توكن مؤقت لقنوات Agora RTC              │   │
│  │                                                          │   │
│  │  يستخدم:                                                 │   │
│  │  • AGORA_APP_ID (متغير بيئة)                            │   │
│  │  • AGORA_APP_CERTIFICATE (متغير بيئة)                   │   │
│  │                                                          │   │
│  │  صلاحية التوكن: ساعة واحدة                               │   │
│  │  الأدوار: publisher (إرسال + استقبال) / subscriber       │   │
│  │                                                          │   │
│  │  Flutter ← AgoraTokenService.generateToken()             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  المشروع: chatapp                                               │
│  الرابط: https://nkzezuvubeloiglhdpfu.supabase.co              │
│  Ref: nkzezuvubeloiglhdpfu                                      │
└─────────────────────────────────────────────────────────────────┘
```
