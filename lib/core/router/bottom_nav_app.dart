import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/home/presentation/view/home_screen.dart';
import 'package:go_biky/feature/orders/presentation/view/orders_screen.dart';
import 'package:go_biky/feature/profile/presentation/view/profile_screen.dart';
import 'package:go_biky/feature/spare_parts/presentation/view/spare_parts_screen.dart';

/// الشاشة اللي شايلة التابات الأساسية، والتنقل بينهم بيتم هنا.
/// الصفحات جوه `IndexedStack` فكل تاب بيحتفظ بالـ state بتاعه
/// لما تتنقل بين التابات
class BottomNavApp extends StatefulWidget {
  const BottomNavApp({super.key});

  @override
  State<BottomNavApp> createState() => _BottomNavAppState();
}

class _BottomNavAppState extends State<BottomNavApp> {
  static const _exitInterval = Duration(seconds: 2);

  int _currentIndex = 0;
  DateTime? _lastBackPress;

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
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: _exitInterval,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: Text('common.tapAgainToExit'.tr()),
        ),
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

/// ترتيبهم هنا هو ترتيب التابات في البار، وأول واحد هو اللي بيفتح الأول
const _items = [
  _NavItem(Icons.home_outlined, 'bottomNav.home', HomeScreen()),
  _NavItem(
    Icons.shopping_bag_outlined,
    'bottomNav.spareParts',
    SparePartsScreen(),
  ),
  _NavItem(Icons.assignment_outlined, 'bottomNav.orders', OrdersScreen()),
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
