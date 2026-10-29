import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/helpers/push_notifications_helper.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/home/presentation/view/home_screen.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_navigation.dart';
import 'package:go_biky/feature/oil_change/presentation/view/screens/oil_log_screen.dart';
import 'package:go_biky/feature/profile/presentation/view/screens/profile_screen.dart';

/// التابات بنفس ترتيبها في البار
enum BottomNavTab { home, oilLog, profile }

/// الشاشة اللي شايلة التابات الأساسية، والتنقل بينهم بيتم هنا.
/// الصفحات جوه `IndexedStack` فكل تاب بيحتفظ بالـ state بتاعه
/// لما تتنقل بين التابات
class BottomNavApp extends StatefulWidget {
  const BottomNavApp({super.key});

  /// بيرجع للتابات من أي شاشة فوقها ويفتح `tab`، زي "عرض سجل الزيت"
  /// اللي بيفتح تاب السجل. بيرجع بـ pop مش go عشان التابات تحتفظ بالـ state
  /// بتاعها
  static void openTab(BuildContext context, BottomNavTab tab) {
    _tabRequest.value = tab;
    // لو التابات مش في الـ stack الـ popUntil هيشيل كل الصفحات
    if (_alive == null) {
      AppRouter.router.go(AppRouter.initialRoute);
      return;
    }
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == AppRouter.initialRoute);
  }

  /// طلب فتح تاب من بره، والـ state بتنفّذه وترجّعه null
  static final _tabRequest = ValueNotifier<BottomNavTab?>(null);

  /// موجود طول ما التابات في الشجرة، وبيكمل لما تتشال
  static Completer<void>? _alive;

  /// الخروج بيستنى التابات تتشال قبل ما يقفل الـ cubits اللي معروضة فيها
  static Future<void> whenDisposed() => _alive?.future ?? Future.value();

  @override
  State<BottomNavApp> createState() => _BottomNavAppState();
}

class _BottomNavAppState extends State<BottomNavApp> {
  static const _exitInterval = Duration(seconds: 2);

  int _currentIndex = 0;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    BottomNavApp._alive = Completer<void>();
    // طلب جه والتابات مش موجودة (اتفتحت بـ go)، فبيتنفذ هنا
    final requested = BottomNavApp._tabRequest.value;
    if (requested != null) {
      BottomNavApp._tabRequest.value = null;
      _currentIndex = requested.index;
    }
    BottomNavApp._tabRequest.addListener(_onTabRequested);
    // التابات بتتبني بعد اللوجين أو فتح التطبيق والجلسة موجودة: التوكن
    // بيتسجل، والإشعار اللي اتداس عليه قبل كده بيتفتح بعد أول frame
    PushNotificationsHelper.onSessionStarted();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NotificationNavigation.attach();
    });
  }

  @override
  void dispose() {
    NotificationNavigation.detach();
    BottomNavApp._tabRequest.removeListener(_onTabRequested);
    BottomNavApp._alive?.complete();
    BottomNavApp._alive = null;
    super.dispose();
  }

  void _onTabRequested() {
    final tab = BottomNavApp._tabRequest.value;
    if (tab == null) return;
    BottomNavApp._tabRequest.value = null;
    _goToTab(tab.index);
  }

  void _goToTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  /// الرجوع من أي تاب بيودّي على الرئيسية، ومن الرئيسية لازم يضغط
  /// مرتين ورا بعض عشان يخرج من التطبيق
  void _onBackPressed() {
    if (_currentIndex != 0) {
      _goToTab(0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < _exitInterval) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPress = now;
    context.showInfoMessage(
      'common.tapAgainToExit'.tr(),
      duration: _exitInterval,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackPressed();
      },
      child: Scaffold(
        // المحتوى بيكمل تحت البار، والـ Scaffold بيزوّد الـ padding
        // اللي تحت بارتفاع البار عشان SafeArea والـ lists ماتستخباش وراه
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: [for (final item in _items) item.page],
        ),
        bottomNavigationBar: _NavBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.labelKey, this.page);

  final IconData icon;
  final String labelKey;
  final Widget page;
}

/// بنفس ترتيب `BottomNavTab`، وأول واحد هو اللي بيفتح الأول
const _items = [
  _NavItem(Icons.home_outlined, 'bottomNav.home', HomeScreen()),
  _NavItem(Icons.oil_barrel_outlined, 'bottomNav.oilLog', OilLogScreen()),
  _NavItem(Icons.person_outline_rounded, 'bottomNav.profile', ProfileScreen()),
];

class _NavBar extends StatelessWidget {
  const _NavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        // على التابلت البار مايتمطش على العرض كله
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520.w),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 24.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavBarItem(
                        item: _items[i],
                        isActive: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isActive ? colors.primary : colors.textSecondary;

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: color, size: 26.r),
              Gaps.v(4.h),
              Text(
                item.labelKey.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  fontSize: 13.sp,
                  color: color,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Gaps.v(4.h),
              // النقطة مكانها محجوز في كل التابات عشان النصوص تفضل على خط واحد
              Container(
                width: 5.r,
                height: 5.r,
                decoration: BoxDecoration(
                  color: isActive ? colors.primary : null,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
