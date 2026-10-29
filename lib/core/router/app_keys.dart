import 'package:flutter/material.dart';

/// مفاتيح عامة للـ Navigator والـ ScaffoldMessenger، عشان الأجزاء اللي
/// مالهاش context (زي طبقة الشبكة والإشعارات) تعرض رسالة أو تتنقل.
/// كانت في main.dart فكل اللي محتاجها كان بيعمل import لـ main
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'navigatorKey-${DateTime.now().millisecondsSinceEpoch}',
);

/// لغة الواجهة الحالية، بتتبعت للباك عشان رسايله ترجع بنفس اللغة. قبل ما
/// الـ Navigator يتبني بترجع العربي (اللغة الافتراضية)
String get currentLanguageCode {
  final context = navigatorKey.currentContext;
  final locale = context == null ? null : Localizations.maybeLocaleOf(context);
  return locale?.languageCode ?? 'ar';
}
