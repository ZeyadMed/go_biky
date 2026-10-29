import 'package:go_biky/core/helpers/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// بيفتح الاتصال أو واتساب أو لينك في تطبيق بره. كلهم بيرجعوا false لو
/// مفيش تطبيق يفتحه، والشاشة هي اللي بتعرض الرسالة
abstract final class UrlLauncherHelper {
  /// كود مصر، لأن أرقام التواصل اللي بترجع من الباك محلية (01xxxxxxxxx)
  static const _countryCode = '20';

  static Future<bool> call(String phone) => _launch(
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), '')),
  );

  /// `message` بيتكتب جاهز في الشات وصاحب الرقم مابيستلموش غير لما يتبعت
  static Future<bool> whatsApp(String phone, {String? message}) {
    final query = message == null || message.isEmpty
        ? ''
        // encodeComponent بيكتب المسافة %20، و wa.me ساعات بيعرض الـ + زي ما هي
        : '?text=${Uri.encodeComponent(message)}';
    return _launch(Uri.parse('https://wa.me/${_international(phone)}$query'));
  }

  /// لينك جوه محتوى (زي سياسة الخصوصية) بيتفتح في المتصفح
  static Future<bool> openUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return Future.value(false);
    return _launch(uri);
  }

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      loggerError('Could not launch $uri: $e');
      return false;
    }
  }

  /// واتساب محتاج الرقم دولي من غير + ولا أصفار في الأول:
  /// "01222333444" و "+201222333444" و "00201222333444" ← "201222333444"
  static String _international(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.trim().startsWith('+')) return digits;
    if (digits.startsWith('00')) return digits.substring(2);
    if (digits.startsWith('0')) return '$_countryCode${digits.substring(1)}';
    return digits;
  }
}
