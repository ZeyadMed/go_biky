import 'package:go_biky/core/http/session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<String> {
  SplashCubit() : super('');

  Future<void> startSplashScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (isClosed) return;

    // `Session` هو المصدر الوحيد لحالة الدخول — التوكن المنتهي
    // بيتجدد أوتوماتيك في أول ريكوست، فوجود جلسة محفوظة كفاية.
    emit(Session.isLoggedIn ? 'home' : 'login');
  }
}
