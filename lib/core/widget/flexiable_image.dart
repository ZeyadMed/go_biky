import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/custom_shimmer_widget.dart';

/// بيعرض أي صورة من غير ما تفرق نوعها: لينك (بيتكاش)، asset، مسار ملف،
/// `Uint8List`، أو data URI base64. وقت التحميل بيظهر shimmer، ولو فشلت
/// بتظهر أيقونة. `borderRadius` بيدور الأطراف و`isCircular` بيخليها دايرة
class FlexibleImage extends StatelessWidget {
  final Object? source;
  final double? borderRadius;
  final bool isCircular;
  final Widget? placeholder;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const FlexibleImage({
    super.key,
    required this.source,
    this.borderRadius,
    this.isCircular = false,
    this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  bool _isNetworkImage(String path) {
    final uri = Uri.tryParse(path);
    if (uri == null) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  bool _isFileImage(String path) {
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  Widget _errorIcon(BuildContext context) => Center(
    child: Icon(
      Icons.broken_image_outlined,
      size: 32.r,
      color: context.appColors.textHint,
    ),
  );

  Widget _image(BuildContext context) {
    final source = this.source;
    Widget onError(BuildContext context, Object error, StackTrace? _) =>
        _errorIcon(context);

    if (source is Uint8List) {
      return Image.memory(source, fit: fit, errorBuilder: onError);
    }
    if (source is! String || source.isEmpty) {
      return placeholder ?? _errorIcon(context);
    }

    // Data URI (base64) e.g. data:image/webp;base64,....
    if (source.startsWith('data:')) {
      try {
        final comma = source.indexOf(',');
        final meta = source.substring(5, comma); // image/webp;base64
        if (!meta.contains('base64')) return placeholder ?? _errorIcon(context);
        final bytes = base64Decode(source.substring(comma + 1));
        return Image.memory(bytes, fit: fit, errorBuilder: onError);
      } catch (_) {
        return placeholder ?? _errorIcon(context);
      }
    }

    if (_isNetworkImage(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        placeholder: (_, _) =>
            placeholder ??
            CustomShimmerWidget(
              height: height,
              width: width ?? double.infinity,
              borderRadius: 0,
            ),
        errorWidget: (context, _, _) => _errorIcon(context),
      );
    }

    if (_isFileImage(source)) {
      return Image.file(File(source), fit: fit, errorBuilder: onError);
    }

    // Treat as asset
    return Image.asset(source, fit: fit, errorBuilder: onError);
  }

  @override
  Widget build(BuildContext context) {
    final image = SizedBox(
      width: width,
      height: height,
      child: _image(context),
    );

    if (isCircular) return ClipOval(child: image);
    if (borderRadius == null) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: image,
    );
  }
}
