<div dir="rtl">

# core_config

حزمة (Package) **متكاملة** تعمل كـ "نواة جاهزة" لأي تطبيق Flutter جديد.
على عكس حزمة [`core_extensions`](../core_extensions/README.md) الخفيفة، هذه الحزمة **إطار كامل (Framework)** يجلب معه:
الثيم والألوان والخطوط، الخدمات (Firebase / Supabase / Agora)، الـ Widgets الجاهزة، إدارة الحالة (Cubit)، الترجمة، والأدوات المساعدة.

> **الفكرة:** بدل أن تعيد بناء البنية التحتية في كل مشروع، تبني تطبيقك **فوق** هذه الحزمة وتستفيد من كل شيء جاهز.

> ⚠️ **مهم:** هذه الحزمة ثقيلة لأنها تجلب Firebase و Supabase و Agora وغيرها.
> استخدمها فقط عندما تريد بناء تطبيق كامل عليها. أما إذا أردت فقط Extensions بسيطة، فاستخدم [`core_extensions`](../core_extensions/README.md).

---

## المحتويات
1. [التثبيت](#التثبيت)
2. [طريقة الاستيراد](#طريقة-الاستيراد)
3. [الثيم والألوان (Theme)](#الثيم-والالوان-theme)
4. [إدارة الحالة (App Cubit)](#ادارة-الحالة-app-cubit)
5. [الترجمة (Localization)](#الترجمة-localization)
6. [الخدمات (Services)](#الخدمات-services)
7. [الـ Widgets الجاهزة](#الـ-widgets-الجاهزة)
8. [التنبيهات والحوارات (Toast / Dialogs)](#التنبيهات-والحوارات-toast--dialogs)
9. [الأدوات المساعدة (Utils)](#الأدوات-المساعدة-utils)
10. [Extensions](#extensions)
11. [الفرق بين core_config و core_extensions](#الفرق-بين-core_config-و-core_extensions)
12. [هيكل الحزمة](#هيكل-الحزمة)

---

## التثبيت

الحزمة محلية موجودة داخل مجلد `packages/`. أضِفها في `pubspec.yaml` الخاص بالتطبيق:

</div>

```yaml
dependencies:
  core_config:
    path: packages/core_config
```

<div dir="rtl">

ثم:

</div>

```bash
flutter pub get
```

<div dir="rtl">

> لأن الحزمة تستخدم Firebase و Supabase و Agora، تأكد من إعداد هذه الخدمات في تطبيقك (ملفات `google-services.json` / `GoogleService-Info.plist` و ملف `.env` لمتغيرات Supabase وغيرها).

---

## طريقة الاستيراد

استيراد واحد يكفي لتفعيل **كل** مكوّنات الحزمة:

</div>

```dart
import 'package:core_config/core_config.dart';
```

<div dir="rtl">

---

## الثيم والألوان (Theme)

الحزمة تعرّف نظام ثيم كامل يعتمد على `ThemeExtension`، ويحتوي على ألوان فاتحة وداكنة، وخطوط، وصور.

| المكوّن | الوصف |
|---|---|
| `AppTheme` | يبني `ThemeData` للوضع الفاتح والداكن |
| `MyColors` | `ThemeExtension` يحمل كل ألوان التطبيق |
| `MyAssets` | `ThemeExtension` يحمل مسارات الصور حسب الوضع |
| `ColorsLight` / `ColorsDark` | ثوابت الألوان |
| `FontFamilyHelper` / `FontWeightHelper` | الخطوط وأوزانها |
| `AppImages` | مسارات الصور |

**طريقة الاستخدام داخل `MaterialApp`:**

</div>

```dart
MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
  home: const HomeScreen(),
);
```

<div dir="rtl">

**الوصول للألوان داخل أي Widget** (عبر `context_extension` الخاص بالحزمة):

</div>

```dart
final colors = Theme.of(context).extension<MyColors>()!;

Container(
  color: colors.primary,
  child: Text('مرحباً', style: TextStyle(color: colors.onPrimary)),
);
```

<div dir="rtl">

> 🔴 **انتبه:** لكي تعمل `MyColors` يجب أن يكون تطبيقك مبنياً على ثيم هذه الحزمة (أي تستخدم `AppTheme.light()/dark()` منها).
> إذا كان تطبيقك يعرّف `MyColors` خاصاً به، فلا تخلط بين الاثنين.

---

## إدارة الحالة (App Cubit)

`AppCubit` جاهز لإدارة **الثيم** و **اللغة** في التطبيق.

| المكوّن | الوصف |
|---|---|
| `AppCubit` | تبديل الوضع (فاتح/داكن) وتغيير اللغة |
| `CurrentUserModel` | نموذج المستخدم الحالي |
| `getCurrentUser()` | دالة مساعدة لجلب المستخدم الحالي |

**مثال:**

</div>

```dart
BlocProvider(
  create: (_) => AppCubit(),
  child: BlocBuilder<AppCubit, AppState>(
    builder: (context, state) {
      return MaterialApp(
        themeMode: state.themeMode,
        locale: state.locale,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
      );
    },
  ),
);
```

<div dir="rtl">

---

## الترجمة (Localization)

| المكوّن | الوصف |
|---|---|
| `AppLocalizations` | تحميل ملفات الترجمة والوصول للنصوص |
| `AppLocalizationsDelegate` | الـ Delegate المطلوب في `MaterialApp` |

**مثال:**

</div>

```dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizationsDelegate(),
    // delegates أخرى...
  ],
  supportedLocales: const [Locale('ar'), Locale('en')],
);

// الاستخدام:
final text = AppLocalizations.of(context)!.translate('app_name');
```

<div dir="rtl">

---

## الخدمات (Services)

أهم ما في الحزمة — خدمات جاهزة للبنية التحتية:

| الخدمة | الوصف |
|---|---|
| `AuthServiceFirebase` | تسجيل الدخول/الخروج عبر Firebase Auth |
| `FirestoreService` | عمليات القراءة/الكتابة على Cloud Firestore |
| `AgoraCallProviderService` / `CallProviderService` | المكالمات الصوتية/المرئية عبر Agora |
| `ConnectivityController` | مراقبة حالة الاتصال بالإنترنت |
| `FirebaseCloudMessaging` | إشعارات Firebase (FCM) |
| `LocalNotificationService` | الإشعارات المحلية |
| `HiveDatabase` | تخزين محلي عبر Hive |
| `SharedPref` + `PrefKeys` | تخزين القيم البسيطة عبر SharedPreferences |
| `SupabaseStorageService` | رفع/تنزيل الملفات من Supabase Storage |
| `PickImageUtils` | اختيار الصور من المعرض/الكاميرا |
| `DioFactory` | تهيئة Dio لطلبات الشبكة |
| `EnvVariable` | قراءة متغيرات البيئة (`.env`) |

**مثال (Firestore):**

</div>

```dart
final firestore = FirestoreService();
await firestore.setData(path: 'users/123', data: {'name': 'Sami'});
```

<div dir="rtl">

**مثال (SharedPreferences):**

</div>

```dart
await SharedPref().setBool(key: PrefKeys.isDarkMode, value: true);
final isDark = SharedPref().getBool(key: PrefKeys.isDarkMode);
```

<div dir="rtl">

---

## الـ Widgets الجاهزة

| الـ Widget | الوصف |
|---|---|
| `CustomButton` | زر أساسي |
| `CustomLinearButton` | زر بتدرّج لوني |
| `CustomOutLineButton` | زر بإطار |
| `CustomTextField` | حقل إدخال جاهز |
| `CustomDropDown` | قائمة منسدلة |
| `CustomProgressHud` | طبقة تحميل فوق الشاشة |
| `AppBackButton` | زر رجوع |
| `CustomerAppBar` | شريط علوي جاهز |
| `TextApp` | نص بأنماط موحّدة |
| `EmptyScreen` | شاشة "لا توجد بيانات" |
| `LoadingShimmer` | تأثير تحميل (Shimmer) |
| `CustomWebView` | عرض صفحة ويب |
| `NoNetworkScreen` | شاشة عند انقطاع الإنترنت |
| `UnderBuildScreen` | شاشة "قيد الإنشاء" |
| `CustomBottomSheet` | قائمة سفلية جاهزة |

**مثال:**

</div>

```dart
CustomButton(
  text: 'تسجيل الدخول',
  onPressed: () {},
);

CustomTextField(
  hintText: 'البريد الإلكتروني',
  controller: emailController,
);
```

<div dir="rtl">

---

## التنبيهات والحوارات (Toast / Dialogs)

| المكوّن | الوصف |
|---|---|
| `showToast(...)` | إظهار رسالة Toast سريعة |
| `CustomDialogs` | حوارات جاهزة (تأكيد / تحميل / خطأ) |

**مثال:**

</div>

```dart
showToast(message: 'تم الحفظ بنجاح');
```

<div dir="rtl">

---

## الأدوات المساعدة (Utils)

| الأداة | الوصف |
|---|---|
| `AppRegex` | تعبيرات نمطية للتحقق (بريد، هاتف، كلمة مرور...) |
| `AppValues` | قيم ثابتة (مسافات، مقاسات افتراضية) |
| `Spacing` | مسافات جاهزة |
| `AppInfo` | معلومات التطبيق (الإصدار...) |
| `AppBlocObserver` | مراقبة كل تغييرات الـ Bloc/Cubit |
| `openFileUrl(...)` | فتح رابط/ملف خارجي |

**مثال:**

</div>

```dart
// في main.dart
Bloc.observer = AppBlocObserver();

// تحقق من صحة بريد إلكتروني
final isValid = AppRegex.isEmailValid(email);
```

<div dir="rtl">

---

## Extensions

الحزمة تحتوي أيضاً على Extensions خاصة بها (نصوص، تواريخ، `BuildContext` مرتبط بثيم الحزمة):

| المكوّن | الوصف |
|---|---|
| `ContextExt` | `context.color` / `context.assets` / `context.translate` / تنقّل |
| `StringFormate` | تنسيقات النصوص |
| `DateEx` | تنسيقات التواريخ |

> ملاحظة: `ContextExt` هنا مرتبطة بثيم وترجمة **هذه الحزمة**. إذا كان تطبيقك يعرّف ثيماً خاصاً به، استخدم Extensions تطبيقك بدلاً منها لتجنّب التعارض.

---

## الفرق بين core_config و core_extensions

| | `core_config` | `core_extensions` |
|---|---|---|
| النوع | إطار متكامل (Framework) | مكتبة أدوات خفيفة |
| الاعتماديات | ثقيلة (Firebase, Supabase, Agora...) | خفيفة (flutter + intl فقط) |
| يجلب ثيم/خدمات/Widgets | ✅ نعم | ❌ لا |
| طريقة الاستخدام | تبني تطبيقك **فوقه** وتتبنّى ثيمه وخدماته | تضعها في **أي** تطبيق دون التزام |
| متى تستخدمه؟ | مشروع جديد كامل على هذه النواة | تريد فقط Extensions جاهزة |

> 💡 القاعدة: **`core_config`** للبنية التحتية الكاملة، **`core_extensions`** للأدوات العامة الخفيفة.

---

## هيكل الحزمة

</div>

```
packages/core_config/
├── pubspec.yaml
├── README.md                       # هذا الملف
└── lib/
    ├── core_config.dart            # الملف الرئيسي (Barrel)
    └── src/
        ├── app_cubit/              # إدارة الثيم واللغة
        ├── common/                 # Widgets / dialogs / toast / loading
        ├── extensions/             # context / string / date
        ├── language/               # الترجمة
        ├── models/                 # النماذج
        ├── routes/                 # المسارات
        ├── service/                # Firebase / Supabase / Agora / Hive ...
        ├── style/                  # الألوان / الخطوط / الثيم / الصور
        └── utils/                  # Regex / values / observer ...
```
