import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// تابات فوق ومحتوى كل تاب تحت. `tabs` بتتبعت مترجمة، والـ widget لازم
/// ياخد ارتفاع محدد (Expanded أو SizedBox) عشان الـ TabBarView جواه Expanded
class CustomTabBarView extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> views;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final ValueChanged<int>? onTabChanged;

  const CustomTabBarView({
    super.key,
    required this.tabs,
    required this.views,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.onTabChanged,
  }) : assert(tabs.length == views.length, 'Tabs and Views must be equal');

  @override
  State<CustomTabBarView> createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant CustomTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.tabs.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [for (final text in widget.tabs) Text(text)],
            onTap: widget.onTabChanged,
            dividerColor: Colors.transparent,
            isScrollable: false,
            labelPadding: EdgeInsets.symmetric(vertical: 16.h),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: widget.indicatorColor ?? colors.primary,
            labelColor: widget.labelColor ?? colors.primary,
            unselectedLabelColor:
                widget.unselectedLabelColor ?? colors.textSecondary,
            labelStyle: widget.labelStyle ?? textTheme.titleSmall,
            unselectedLabelStyle:
                widget.unselectedLabelStyle ?? textTheme.titleSmall,
          ),
        ),
        Gaps.v(16.h),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: widget.views,
          ),
        ),
      ],
    );
  }
}
