# Go Biky — قواعد المشروع

تطبيق Flutter اسمه **Go Biky** (package: `go_biky`). القواعد دي لازم تتطبق على أي كود جديد أو تعديل.

## 1. Responsive (موبايل صغير / موبايل متوسط / تابلت)
- كل الأبعاد بـ `flutter_screenutil`: `.w` للعرض، `.h` للطول، `.r` للـ radius، `.sp` للخطوط. ممنوع أرقام ثابتة من غير extension.
- الـ design size بيتحدد في `main.dart`: `375x812` للموبايل و `768x1024` للتابلت، عشان التابلت مايكبّرش كل حاجة.
- حدود الأجهزة في `Breakpoints` (`lib/core/extensions/context_extension.dart`): موبايل صغير أقل من 360، تابلت من 600.
- لو قيمة واحدة بتختلف حسب الجهاز: `context.responsiveValue(mobile: ..., smallMobile: ..., tablet: ...)` (`smallMobile` و `tablet` اختياريين).
- لو الـ layout كله بيختلف: `ResponsiveLayout(mobile: ..., smallMobile: ..., tablet: ...)`.
- أي شاشة فيها فورم أو محتوى أساسي تتلف بـ `ResponsiveCenter` عشان المحتوى مايتمطش على عرض التابلت.
- للشروط: `context.isSmallMobile` / `context.isNormalMobile` / `context.isTablet`.
- أي شاشة لازم ماتعملش overflow على الموبايل الصغير (استخدم scroll و `Flexible`/`Expanded` بدل الارتفاعات الثابتة).

## 2. Dark & Light mode
- الألوان اللي بتتغير حسب الوضع موجودة في `AppThemeColors` (`lib/core/theme/app_theme_colors.dart`) وبتتقري بـ `context.appColors` (مثلاً `context.appColors.textPrimary`، `bgSecondary`، `border`).
- الخطوط بـ `context.textTheme` (مثلاً `context.textTheme.bodyMedium`)، ولو عايز وزن أو لون مختلف استخدم `copyWith`. الـ text theme لونه بيتغير لوحده مع الوضع.
- ممنوع ألوان hardcoded جوه الـ widgets (`Colors.white`، `Color(0x...)`)، وممنوع استخدام `TextStyles` أو `AppColors` للنصوص والخلفيات العادية لأن ألوانهم ثابتة ومش بتتغير مع الـ dark mode.
- `AppColors` للألوان الثابتة بس (ألوان البراند، الـ gradients، النص الأبيض فوق الصور زي السبلاش).
- أي لون جديد بيتغير حسب الوضع يتضاف في `AppThemeColors` بقيمتين (`light` و `dark`) ويتضاف في `copyWith` و `lerp`.
- تغيير الوضع: `ThemeModeController.setThemeMode(ThemeMode.light / dark / system)` أو `ThemeModeController.toggleTheme()`، والاختيار بيتحفظ.
- أي شاشة جديدة لازم تكون شكلها سليم في الوضعين.

## 3. ألوان البراند (من اللوجو)
- ألوان التطبيق الأساسية مأخوذة من `assets/images/GoBiky_logo.png`، ومفيش غيرها كلون براند:
  - **الأحمر** `#BF3332` ← `primary`: الأزرار الأساسية، التاب/العنصر النشط، اللينكات، الأيقونات المميزة، الـ progress، الـ selected states.
  - **الرمادي الغامق (charcoal)** `#444442` ← `secondary`: الأزرار الثانوية، الـ chips، أي عنصر مميز مش المفروض يبقى أحمر.
- في الـ widgets استخدم `context.appColors.primary` / `primaryContainer` / `secondary` (بيتغيروا لوحدهم في الـ dark mode). النص فوق `primary` لونه `context.colorScheme.onPrimary`.
- ثوابت البراند في `AppColors` (`brandRed`، `brandRedDeep`، `brandCharcoal`، `mainGradient`) للحاجات الثابتة بس زي الـ gradients والسبلاش.
- ممنوع أي لون براند تاني (أزرق، برتقالي، أخضر، بنفسجي...) كلون أساسي في أي شاشة.
- الـ `error` لونه rose (`#E11D48`) عشان يبان مختلف عن أحمر البراند: ماتستخدموش في حاجة براند، وماتستخدمش `primary` لرسايل الخطأ.

### لما أبعتلك سكرين أو ديزاين تعمل زيه
- انقل الـ layout والمسافات والأحجام والخطوط وشكل العناصر زي ما هي، **إلا الألوان**: ماتنقلش أي hex من السكرين.
- حوّل كل لون في السكرين لمكانه في الثيم:

  | في السكرين | في الكود |
  |---|---|
  | اللون الأساسي/المميز للتصميم (أزرار، تاب نشط، أيقونات، لينكات) | `appColors.primary` |
  | درجة فاتحة من اللون الأساسي (badge، كارت متحدد، chip نشط) | `appColors.primaryContainer` |
  | لون مميز تاني (accent) | `appColors.secondary` |
  | gradient | `AppColors.mainGradient` |
  | خلفية الشاشة / الكروت والـ sheets / الحقول والـ chips | `bgPrimary` / `bgSecondary` / `bgTertiary` |
  | النصوص: عنوان / عادي / hint | `textPrimary` / `textSecondary` / `textHint` |
  | الحدود والفواصل | `border` |
  | نجاح / تحذير / خطأ / معلومة | `success` / `warning` / `error` / `info` (والخلفية الفاتحة بتاعتهم `...Container`) |

- ألوان الحالات بتفضل بمعناها حتى لو لونها في السكرين مختلف: "تم بنجاح" يفضل `success` حتى لو السكرين عامله بلون البراند بتاعه.
- لو في السكرين لون مهم مش موجود في الجدول (زي لون تالت للتصنيفات)، اسألني الأول قبل ما تضيف لون جديد.

## 4. الترجمة (عربي + إنجليزي)
- الترجمة بـ `easy_localization`، اللغات `ar` (الافتراضية) و `en`، والملفات في `assets/translations/`.
- ممنوع أي نص ظاهر للمستخدم يتكتب hardcoded — لازم key مع `.tr()`.
- أي key جديد يتضاف في `ar.json` و `en.json` مع بعض بنفس الترتيب، ومتجمع تحت اسم الـ feature (زي `"splash": { ... }`).
- النصوص المشتركة (حسناً، إلغاء، إعادة المحاولة، تحميل، لا يوجد إنترنت...) في `common`، ونصوص الإعدادات (اللغة، المظهر) في `settings` — استخدمهم قبل ما تعمل key جديد.
- تغيير اللغة: `context.toggleLanguage()` أو `context.setLocale(const Locale('en'))`، والاختيار بيتحفظ.
- دعم RTL: استخدم `EdgeInsetsDirectional`، `AlignmentDirectional`، `PositionedDirectional`، و `start`/`end` بدل `left`/`right`.
- في الملفات اللي فيها `TextDirection` استورد easy_localization كده: `import 'package:easy_localization/easy_localization.dart' hide TextDirection;`

## 5. Conventions عامة
- الخط: `Cairo`.
- المسافات: `Gaps` من `lib/core/widgets/stateless/gaps.dart` (مثلاً `Gaps.v(12.h)`).
- الصور والأيقونات: من `lib/core/style/assets.dart`، مش paths مكتوبة يدوي.
- State management: `flutter_bloc`، الـ DI بـ `get_it` (`lib/core/service_locator/`)، الـ navigation بـ `go_router` (`lib/core/router/`).
- كل feature جديدة في `lib/feature/<feature_name>/` بنفس تقسيم الـ features الموجودة.

## قواعد للتعامل معايا
- قبل ما تضيف package جديدة، اسألني الأول
- بعد أي تعديل، شغّل flutter analyze
- ماتعدّلش في ملفات خارج المطلوب من غير ما تقولي
- اشرحلي التعديلات بالعربي باختصار