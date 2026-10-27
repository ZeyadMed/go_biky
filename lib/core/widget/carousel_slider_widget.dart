import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/widget/custom_page_indecator.dart';

/// سلايدر صفحات (بانرات مثلاً) بنقط تحت، وممكن يقلب لوحده بـ `autoPlay`
class CarouselSliderWidget extends StatefulWidget {
  final List<Widget> widgets;

  /// لو مش متبعت بياخد 400.h
  final double? height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Color? indicatorColor;

  const CarouselSliderWidget({
    super.key,
    required this.widgets,
    this.height,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.indicatorColor,
  });

  @override
  State<CarouselSliderWidget> createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!_pageController.hasClients || widget.widgets.length < 2) return;
      _pageController.animateToPage(
        (_currentPage + 1) % widget.widgets.length,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 400.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.widgets.length,
            itemBuilder: (context, index) {
              return Center(child: widget.widgets[index]);
            },
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
          if (widget.widgets.length > 1)
            PositionedDirectional(
              bottom: 21.h,
              start: 0,
              end: 0,
              child: Center(
                child: CustomPageIndicator(
                  currentIndex: _currentPage,
                  itemCount: widget.widgets.length,
                  activeDotWidth: 24.w,
                  spacing: 8.w,
                  activeColor: widget.indicatorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
