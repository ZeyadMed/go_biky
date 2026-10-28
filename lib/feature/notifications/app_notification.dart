import 'package:flutter/material.dart';

/// نوع الإشعار بيحدد الأيقونة مكان الصورة والشاشة اللي بيفتحها
enum NotificationType {
  /// معاد تغيير الزيت قرّب أو عدّى، وعنوانه بلون الخطأ
  oilDue(Icons.oil_barrel_outlined),

  /// تحديث في إثبات تغيير الزيت
  oilProof(Icons.fact_check_outlined);

  const NotificationType(this.icon);

  final IconData icon;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.image,
  });

  final int id;
  final NotificationType type;

  /// النصوص بتيجي جاهزة من الـ API
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? image;

  AppNotification asRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: true,
    image: image,
  );
}
