import 'package:flutter/material.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';

/// الوضع الحالي (فاتح / داكن / حسب الجهاز)، والاختيار بيتحفظ في الكاش
abstract final class ThemeModeController {
  static const String _themeModeKey = 'theme_mode';

  static final ValueNotifier<ThemeMode> notifier = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static ThemeMode get themeMode => notifier.value;

  /// بتتنادى في main بعد CacheManager.init
  static Future<void> loadSavedTheme() async {
    final saved = CacheManager.sharedPreferences.getString(_themeModeKey);
    notifier.value = ThemeMode.values.asNameMap()[saved] ?? ThemeMode.light;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    notifier.value = mode;
    await CacheManager.sharedPreferences.setString(_themeModeKey, mode.name);
  }

  /// بيقلب بين الفاتح والداكن، ولو كان على وضع الجهاز بيقلب عكس اللي ظاهر
  static Future<void> toggleTheme() {
    final isDark = switch (notifier.value) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
    return setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
