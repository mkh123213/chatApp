<div dir="rtl">

# core_extensions

حزمة (Package) خفيفة تحتوي على **Extensions** جاهزة لإعادة الاستخدام في أي مشروع Flutter.
لا تعتمد على أي شيء ثقيل — فقط `flutter` و `intl` — لذلك يمكنك إضافتها لأي تطبيق دون أن تجرّ معها Firebase أو Supabase أو غيرها.

> **الفكرة:** كل ما هو *عام وقابل لإعادة الاستخدام* (نصوص، تواريخ، مسافات، اختصارات MediaQuery) موجود هنا.
> أما ما هو *خاص بالتطبيق* مثل ألوان الثيم (`MyColors`) والصور (`MyAssets`) فيبقى داخل التطبيق نفسه ولا يوضع في هذه الحزمة (الشرح في آخر الملف).

---

## المحتويات
1. [التثبيت](#التثبيت)
2. [طريقة الاستيراد](#طريقة-الاستيراد)
3. [String Extensions](#string-extensions)
4. [DateTime Extensions](#datetime-extensions)
5. [num Extensions (المسافات)](#num-extensions-المسافات)
6. [BuildContext Extensions](#buildcontext-extensions)
7. [لماذا لا توجد ألوان/صور الثيم هنا؟](#لماذا-لا-توجد-الوانصور-الثيم-هنا)
8. [هيكل الحزمة](#هيكل-الحزمة)

---

## التثبيت

الحزمة محلية (Local Package) موجودة داخل مجلد `packages/`. لإضافتها لأي تطبيق، افتح ملف `pubspec.yaml` الخاص بالتطبيق وأضِف:

</div>

```yaml
dependencies:
  core_extensions:
    path: packages/core_extensions
```

<div dir="rtl">

ثم نفّذ الأمر:

</div>

```bash
flutter pub get
```

<div dir="rtl">

> إذا كان مشروعك في مكان مختلف، عدّل قيمة `path` لتشير إلى المسار الصحيح للحزمة (مثلاً `../core_extensions`).

---

## طريقة الاستيراد

استيراد واحد فقط يكفي لتفعيل **كل** الـ Extensions في الملف:

</div>

```dart
import 'package:core_extensions/core_extensions.dart';
```

<div dir="rtl">

بعد هذا الاستيراد تصبح كل الدوال (Methods) والخصائص (Getters) متاحة مباشرة على `String` و `DateTime` و `num` و `BuildContext`.

---

## String Extensions

تعمل على أي نص (`String`).

| الخاصية / الدالة | الوصف | النتيجة |
|---|---|---|
| `toCapitalized()` | تحويل أول حرف إلى Capital (آمنة مع النص الفارغ) | `"hello"` → `"Hello"` |
| `toTitleCase()` | تحويل أول حرف من كل كلمة إلى Capital | `"hello world"` → `"Hello World"` |
| `imageProductFormate()` | إزالة الأقواس `["..."]` المحيطة بنص الصورة | `'["img.png"]'` → `'img.png'` |
| `convertLongString()` | حذف آخر كلمة من النص (آمنة بدون مسافات) | `"a b c"` → `"a b"` |
| `convertDataFormate()` | تحويل نص تاريخ إلى صيغة `d MMM, y - h:mm a` | `"2026-06-11"` → `"11 Jun, 2026 - 12:00 AM"` |
| `isValidEmail` | التحقق من أن النص بريد إلكتروني صالح | `true` / `false` |
| `isBlank` | هل النص فارغ أو يحتوي مسافات فقط؟ | `true` / `false` |
| `initial` | أول حرف Capital (أو `?` إن كان فارغاً) — مفيد للـ Avatar | `"sami"` → `"S"` |

**مثال:**

</div>

```dart
final name = 'mohammed sami';
print(name.toTitleCase());      // Mohammed Sami
print(name.initial);            // M

final email = 'test@mail.com';
if (email.isValidEmail) {
  // بريد صالح
}

final empty = '   ';
print(empty.isBlank);           // true
```

<div dir="rtl">

---

## DateTime Extensions

تعمل على أي `DateTime`.

| الخاصية / الدالة | الوصف | النتيجة |
|---|---|---|
| `getFormatDayMonthYear()` | تنسيق `dd/MM/yyyy` | `09/06/2026` |
| `messageTime` | وقت الرسالة `h:mm a` | `3:04 PM` |
| `isToday` | هل التاريخ هو اليوم؟ | `true` / `false` |
| `isYesterday` | هل التاريخ هو الأمس؟ | `true` / `false` |
| `chatLabel` | عنوان للمحادثات: `Today` أو `Yesterday` أو التاريخ | `Today` |
| `timeAgo` | منذ كم من الوقت بصيغة مختصرة | `now` / `5m` / `3h` / `2d` |

**مثال (مفيد جداً في شاشات الدردشة):**

</div>

```dart
final messageDate = DateTime.now().subtract(const Duration(minutes: 5));

print(messageDate.messageTime);   // 3:04 PM
print(messageDate.timeAgo);       // 5m
print(messageDate.chatLabel);     // Today

if (messageDate.isToday) {
  // اعرض الرسائل تحت عنوان "اليوم"
}
```

<div dir="rtl">

---

## num Extensions (المسافات)

تعمل على أي رقم (`int` أو `double`) وتختصر كتابة `SizedBox` و `EdgeInsets` و `BorderRadius`.

| الخاصية | بدلاً من | النتيجة |
|---|---|---|
| `16.vGap` | `SizedBox(height: 16)` | مسافة عمودية |
| `8.hGap` | `SizedBox(width: 8)` | مسافة أفقية |
| `40.box` | `SizedBox.square(dimension: 40)` | مربع |
| `12.paddingAll` | `EdgeInsets.all(12)` | حشو من كل الجهات |
| `16.paddingH` | `EdgeInsets.symmetric(horizontal: 16)` | حشو أفقي |
| `8.paddingV` | `EdgeInsets.symmetric(vertical: 8)` | حشو عمودي |
| `12.radius` | `BorderRadius.circular(12)` | زوايا دائرية |

**مثال:**

</div>

```dart
Column(
  children: [
    const Text('العنوان'),
    16.vGap,                      // مسافة عمودية 16
    Container(
      padding: 12.paddingAll,     // حشو 12 من كل الجهات
      decoration: BoxDecoration(
        borderRadius: 12.radius,  // زوايا دائرية 12
      ),
      child: const Text('المحتوى'),
    ),
  ],
)
```

<div dir="rtl">

---

## BuildContext Extensions

اختصارات لـ `MediaQuery` وبعض الأدوات العامة — **لا تعتمد على ثيم التطبيق** لذلك آمنة في أي مشروع.
الـ Extension اسمها `MediaQueryExt` (اسم مختلف عن `ContextExt` الخاص بتطبيقك حتى لا يحدث تعارض).

| الخاصية / الدالة | الوصف |
|---|---|
| `context.screenSize` | حجم الشاشة (`Size`) |
| `context.screenWidth` | عرض الشاشة |
| `context.screenHeight` | ارتفاع الشاشة |
| `context.viewInsets` | المساحة المحجوزة (مثل الكيبورد) |
| `context.viewPadding` | الحشو الآمن (notch / status bar) |
| `context.isKeyboardOpen` | هل الكيبورد مفتوح؟ |
| `context.orientation` | اتجاه الشاشة (`portrait` / `landscape`) |
| `context.isPortrait` | هل الشاشة عمودية؟ |
| `context.isDarkMode` | هل الوضع الداكن مُفعّل؟ |
| `context.hideKeyboard()` | إخفاء الكيبورد |

**مثال:**

</div>

```dart
@override
Widget build(BuildContext context) {
  return SizedBox(
    width: context.screenWidth * 0.9,   // 90% من عرض الشاشة
    child: GestureDetector(
      onTap: () => context.hideKeyboard(),  // إخفاء الكيبورد عند الضغط
      child: Text(
        context.isDarkMode ? 'وضع داكن' : 'وضع فاتح',
      ),
    ),
  );
}
```

<div dir="rtl">

---

## لماذا لا توجد ألوان/صور الثيم هنا؟

ربما تتساءل: لماذا لا توجد `context.color` أو `context.assets` (مثل `MyColors` و `MyAssets`) في هذه الحزمة؟

السبب قاعدة مهمة في Flutter:

> **الحزمة لا يمكنها أبداً أن تستورد من التطبيق** (`import 'package:chat_material3/...'`).
> التطبيق يعتمد على الحزمة، فلو اعتمدت الحزمة على التطبيق لحصل اعتماد دائري (Circular Dependency) وهو ممنوع.

- `MyColors` و `MyAssets` معرّفتان **داخل تطبيقك** (`lib/core/style/`) وتحملان ألوان وصور تطبيقك الخاصة.
- لو وضعناهما هنا لأصبحت الحزمة خاصة بهذا التطبيق فقط — وبذلك تفقد معنى "إعادة الاستخدام".

لذلك تبقى `context.color` و `context.assets` و `context.textStyle` في ملف التطبيق
`lib/core/extensions/context_extension.dart` وتعمل كما هي، بينما تحتوي هذه الحزمة فقط على الأدوات العامة.

> 💡 القاعدة: **كل ما هو عام → في الحزمة. كل ما هو خاص بثيم/هوية التطبيق → داخل التطبيق.**

---

## هيكل الحزمة

</div>

```
packages/core_extensions/
├── pubspec.yaml                 # يعتمد فقط على flutter + intl
├── README.md                    # هذا الملف
└── lib/
    ├── core_extensions.dart     # الملف الرئيسي (Barrel) — يصدّر كل شيء
    └── src/
        ├── string_extension.dart    # StringFormate
        ├── date_extension.dart      # DateEx
        ├── num_extension.dart       # SpacingExt
        └── context_extension.dart   # MediaQueryExt
```

<div dir="rtl">

---

### ملاحظة حول الاستيراد داخل تطبيقك

ملفات الـ Extensions القديمة في `lib/core/extensions/` (مثل `date_extension.dart` و `string_exetension.dart`)
تم تحويلها إلى **إعادة تصدير (Re-export)** لهذه الحزمة، لذلك أي كود قديم يستورد منها لا يزال يعمل دون أي تعديل:

</div>

```dart
// lib/core/extensions/string_exetension.dart
export 'package:core_extensions/core_extensions.dart';
```

<div dir="rtl">

بهذا يصبح المصدر الوحيد للحقيقة (Single Source of Truth) هو الحزمة، مع بقاء كل الاستيرادات القديمة شغّالة.

</div>
