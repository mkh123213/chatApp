<div dir="rtl">

# دليل البدء السريع — ZegoCloud Call Kit (مع دعوات المكالمات)

ترجمة وشرح مفصّل لخطوات دمج **Zego UIKit Prebuilt Call** مع **دعوات المكالمات (Call Invitation)** في تطبيق Flutter.

> 🔗 المصدر الرسمي: <https://www.zegocloud.com/docs/uikit/callkit-flutter/quick-start-(with-call-invitation)>
> 📦 الحزمة المستخدمة في هذا المشروع: `zego_uikit_prebuilt_call`

---

## المتطلبات المسبقة

قبل البدء يجب:

1. إنشاء مشروع **UIKit** من [لوحة تحكم ZEGOCLOUD](https://console.zegocloud.com).
2. الحصول على **AppID** و **AppSign** من اللوحة.
3. إنشاء **resourceID** في اللوحة (مطلوب لدعوات المكالمات في وضع عدم الاتصال — Offline).
4. (اختياري) تنزيل [الكود النموذجي الرسمي](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter).

> ⚠️ **مهم:** اختبر على **جهاز حقيقي**، لأن المحاكي (Simulator/Emulator) لا يدعم دعوات المكالمات في وضع عدم الاتصال.

---

## الخطوة 1: إضافة الاعتماديات (Dependencies)

نفّذ الأوامر التالية في جذر المشروع:

</div>

```bash
flutter pub add zego_uikit_prebuilt_call
flutter pub add zego_uikit_signaling_plugin
flutter pub get
```

<div dir="rtl">

| الحزمة | الدور |
|---|---|
| `zego_uikit_prebuilt_call` | واجهة المكالمة الجاهزة |
| `zego_uikit_signaling_plugin` | إضافة الإشارات (Signaling) المطلوبة للدعوات |

---

## الخطوة 2: استيراد الـ SDK

أضِف هذه الاستيرادات في ملفاتك:

</div>

```dart
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
```

<div dir="rtl">

---

## الخطوة 3: تهيئة خدمة الدعوات في `main.dart`

عرّف `navigatorKey` ومرّره للخدمة، ثم فعّل واجهة الاتصال الخاصة بالنظام:

</div>

```dart
final navigatorKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  await ZegoUIKit().initLog().then((value) async {
    await ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    runApp(MyApp(navigatorKey: navigatorKey));
  });
}

class MyApp extends StatefulWidget {
  final GlobalKey navigatorKey;
  const MyApp({required this.navigatorKey, Key? key}) : super(key: key);

  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      // ... باقي الإعدادات
    );
  }
}
```

<div dir="rtl">

> 🔑 **مهم:** يجب تمرير نفس `navigatorKey` إلى `MaterialApp.navigatorKey` حتى تستطيع الخدمة فتح شاشة المكالمة تلقائياً.

---

## الخطوة 4: التهيئة عند تسجيل الدخول / الإلغاء عند الخروج

استدعِ `init()` **بعد** تسجيل دخول المستخدم، و `uninit()` عند تسجيل الخروج:

</div>

```dart
Future<void> onUserLogin() async {
  await ZegoUIKitPrebuiltCallInvitationService().init(
    appID: yourAppID,        // من لوحة التحكم (int)
    appSign: yourAppSign,    // من لوحة التحكم (String)
    userID: currentUser.id,
    userName: currentUser.name,
    plugins: [ZegoUIKitSignalingPlugin()],
  );
}

void onUserLogout() {
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}
```

<div dir="rtl">

> 📌 في هذا المشروع: استدعِ `onUserLogin()` بعد نجاح `AuthService` (مثلاً في Cubit المصادقة)، و `onUserLogout()` ضمن عملية تسجيل الخروج.

---

## الخطوة 5 (اختيارية): تأجيل الدخول التلقائي للمكالمات في وضع عدم الاتصال

إذا أردت التحكم بلحظة فتح شاشة المكالمة القادمة من إشعار Offline، اضبط `autoEnterAcceptedOfflineCall` على `false`:

</div>

```dart
await ZegoUIKitPrebuiltCallInvitationService().init(
  // ... باقي المعاملات
  offline: ZegoCallInvitationOfflineConfig(
    autoEnterAcceptedOfflineCall: false,
  ),
);
```

<div dir="rtl">

ثم افتح المكالمة يدوياً بعد جاهزية التطبيق:

</div>

```dart
class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
    });
  }
}
```

<div dir="rtl">

---

## الخطوة 6: زر إرسال الدعوة للمكالمة

ضع هذا الزر في أي مكان لبدء مكالمة (صوتية أو مرئية):

</div>

```dart
ZegoSendCallInvitationButton(
  isVideoCall: true,                  // true = مرئية، false = صوتية
  resourceID: "zegouikit_call",       // نفس الاسم المُنشأ في اللوحة
  invitees: [
    ZegoUIKitUser(
      id: targetUserID,
      name: targetUserName,
    ),
  ],
)
```

<div dir="rtl">

---

## مرجع المعاملات (Parameters)

| المعامل | النوع | الوصف |
|---|---|---|
| `appID` | `int` | من لوحة تحكم ZEGOCLOUD |
| `appSign` | `String` | من لوحة تحكم ZEGOCLOUD |
| `userID` | `String` | معرّف المستخدم (أحرف/أرقام/`_`، بحد أقصى 32 بايت) |
| `userName` | `String` | الاسم الظاهر (UTF-8، بحد أقصى 256 بايت) |
| `plugins` | `List` | ثابت: `[ZegoUIKitSignalingPlugin()]` |
| `resourceID` | `String` | يُنشأ في اللوحة لدعوات وضع عدم الاتصال |
| `isVideoCall` | `bool` | `true` للمرئية، `false` للصوتية |
| `invitees` | `List` | المستلمون كقائمة `ZegoUIKitUser` |

---

## إعدادات المنصّات (Android / iOS)

> هذه الخطوات مطلوبة لعمل المكالمات والإشعارات بشكل صحيح. راجع التوثيق الرسمي للتفاصيل الكاملة لأنها تتغير حسب إصدار الحزمة:

- **الأذونات (Permissions):** الكاميرا والميكروفون على المنصّتين.
- **Android:** ضبط `minSdkVersion`، وإعدادات الخدمة الأمامية (Foreground Service) للمكالمات، وأذونات الإشعارات.
- **iOS:** تفعيل **Background Modes** (الصوت/VoIP)، وإعداد **PushKit/CallKit** للمكالمات في وضع عدم الاتصال.

---

## ملخّص الترتيب الصحيح

1. `setNavigatorKey` ثم `useSystemCallingUI` في `main()` **قبل** `runApp`.
2. تمرير نفس `navigatorKey` إلى `MaterialApp`.
3. `init(...)` بعد تسجيل الدخول، و `uninit()` عند الخروج.
4. وضع `ZegoSendCallInvitationButton` حيث تريد بدء المكالمة.

</div>
