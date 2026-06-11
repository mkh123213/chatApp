<div dir="rtl">

# دليل المكالمات (صوت/فيديو) — ZegoUIKit Prebuilt

هذا الدليل خاص بمشروع **ALKHATEEB CHAT** ويشرح كيف تم تفعيل المكالمات بطريقة التوثيق الرسمي
(`zego_uikit_prebuilt_call` + دعوات المكالمات)، وما الذي تحتاج لإكماله حتى تعمل المكالمات فعلياً.

> 🔗 التوثيق الرسمي: <https://www.zegocloud.com/docs/uikit/callkit-flutter/quick-start-(with-call-invitation)>

---

## 1) ما الذي تغيّر؟ (ملخص الهجرة)

تم استبدال نظام المكالمات القديم (المبني على `zego_express_engine` منخفض المستوى + `flutter_callkit_incoming` + إشارات Firestore يدوية) بنظام **ZegoUIKit الجاهز** الذي يتكفّل بكل شيء: الدعوة، الرنين، شاشة المكالمة، والمكالمات في الخلفية.

| العنصر | الحالة |
|---|---|
| تهيئة خدمة الدعوات (`init`/`uninit`) | ✅ مربوطة عند تسجيل الدخول/الخروج |
| أزرار الاتصال (صوت/فيديو) | ✅ `ZegoSendCallInvitationButton` في شاشة المحادثة |
| مفتاح التنقّل الموحّد | ✅ `appNavigatorKey` مشترك بين `MaterialApp` و Zego |
| سجل المكالمات (History) | ✅ يُكتب من أحداث Zego إلى Firestore |
| النظام القديم | 🗑️ تم حذفه (مع نسخة احتياطية، انظر القسم 7) |

---

## 2) المطلوب منك لتعمل المكالمات (إلزامي)

### أ) مفاتيح Zego في ملفات البيئة

أضِف في `.env.dev` و `.env.prod`:

</div>

```
ZEGO_APP_ID=رقم_التطبيق
ZEGO_APP_SIGN=التوقيع_64_حرف
```

<div dir="rtl">

> بدون هذه المفاتيح لن يتعطّل التطبيق، لكن المكالمات ستكون **معطّلة** وسيظهر تحذير في الـ console.
> احصل على القيم من <https://console.zegocloud.com> ← مشروعك ← AppID / AppSign.

### ب) إنشاء resourceID في لوحة التحكم

أنشئ resource باسم **`zego_call`** (مطابق للثابت `kZegoCallResourceID` في الكود) — مطلوب للمكالمات في وضع عدم الاتصال (Offline / الخلفية).

---

## 3) أين توجد أزرار الاتصال؟

في `lib/features/single_chat/presentation/screens/single_chat_screen.dart` داخل `ChatAppBar.actions`:

</div>

```dart
ZegoSendCallInvitationButton(
  isVideoCall: true,                 // أو false للمكالمة الصوتية
  resourceID: kZegoCallResourceID,   // 'zego_call'
  invitees: [ZegoUIKitUser(id: friendId, name: friendDisplayName)],
  icon: ButtonIcon(icon: const Icon(Icons.videocam)),
)
```

<div dir="rtl">

> لإضافة زر اتصال في شاشة أخرى (مثل شاشة معلومات جهة الاتصال)، انسخ نفس الـ Widget ومرّر `id` و `name` للطرف الآخر.

---

## 4) كيف تتم التهيئة؟

الملف الأساسي: `lib/core/service/call_service/zego_call_invitation_service.dart`

| الحدث | المكان |
|---|---|
| `setNavigatorKey` + `useSystemCallingUI` | `main.dart` (قبل `runApp`) |
| `onUserLogin(...)` بعد تسجيل الدخول | `auth_cubit.dart` (3 طرق دخول) + `main.dart` (عند فتح التطبيق وأنت مسجّل) |
| `onUserLogout()` عند الخروج | `auth_cubit.signOut()` + `app_logout.dart` |

> المعرّف المُستخدم للمستخدم هو `uid` من Firebase، والاسم `name` (أو `uid` إن كان فارغاً).

---

## 5) سجل المكالمات (Call History)

تبقى شاشة سجل المكالمات تعمل كما هي. الملف `zego_call_history_recorder.dart` يستمع لأحداث Zego ويكتب السجلات إلى مجموعة `calls` في Firestore (نفس المجموعة التي تقرأها الشاشة)، باستخدام `callID` كمعرّف للمستند حتى تندمج كتابة المتصل والمستقبِل في سجل واحد.

| حدث Zego | الحالة المسجّلة |
|---|---|
| `onOutgoingCallSent` / `onIncomingCallReceived` | `ringing` |
| `onOutgoingCallAccepted` | `accepted` |
| `onOutgoingCallDeclined` / `RejectedCauseBusy` | `rejected` |
| `onOutgoingCallTimeout` / `onIncomingCallTimeout` / `Canceled` | `missed` |
| `onCallEnd` | `ended` (مع المدة) أو `missed` إن لم تُقبل |

---

## 6) إعدادات المنصّات

### Android — ✅ جاهز
الأذونات موجودة في `AndroidManifest.xml` (RECORD_AUDIO، CAMERA، FOREGROUND_SERVICE، USE_FULL_SCREEN_INTENT، POST_NOTIFICATIONS، SYSTEM_ALERT_WINDOW…) و `minSdk = 24`.

### iOS — ✅ جاهز
`Info.plist` يحتوي على:
- `NSMicrophoneUsageDescription`
- `NSCameraUsageDescription`
- `UIBackgroundModes` ← `voip`

> للمكالمات في الخلفية على iOS قد تحتاج لإعداد PushKit/VoIP إضافي حسب متطلبات حسابك في Zego.

---

## 7) النسخة الاحتياطية والحذف

> ⚠️ المشروع **ليس** مستودع git، لذلك قبل الحذف تم إنشاء نسخة احتياطية كاملة لمجلد `lib`:

</div>

```
_backup_lib_20260611-134728.zip   (في جذر المشروع)
```

<div dir="rtl">

**للاسترجاع** عند الحاجة: فك ضغط هذا الملف فوق مجلد `lib`.

**الملفات المحذوفة** (النظام القديم):
- `lib/core/service/zegocaller/` (4 ملفات — محرّك Zego Express منخفض المستوى)
- `lib/core/service/call_service/callkit_service.dart` و `call_provider_service.dart`
- `lib/features/calls/presentation/bloc/{start_call_cubit, incoming_call_cubit, active_call_cubit}/`
- `lib/features/calls/presentation/screens/call_screen.dart`
- `lib/features/calls/presentation/refactor/call_body.dart`
- `widgets/{call_controls, call_header, call_video_view, incoming_call_dialog, incoming_call_overlay, active_call_bloc_consumer}.dart`

**الحزم المحذوفة من `pubspec.yaml`:** `zego_express_engine` و `flutter_callkit_incoming`.

**ما تم الإبقاء عليه:** طبقة بيانات المكالمات (`call_model`, `calls_repo`, `calls_remote_data_source`) وشاشة السجل (`calls_history_*`).

---

## 8) خطوات الاختبار

1. ضع `ZEGO_APP_ID` و `ZEGO_APP_SIGN` في `.env.dev`.
2. أنشئ resource باسم `zego_call` في لوحة التحكم.
3. شغّل التطبيق على **جهازين حقيقيين** (المحاكي لا يدعم المكالمات في وضع عدم الاتصال).
4. سجّل الدخول بمستخدمين مختلفين، افتح محادثة، واضغط زر الفيديو/الصوت.
5. تحقّق من ظهور المكالمة في تبويب "المكالمات" بعد انتهائها.

</div>
