import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/profile/data/model/policy_document.dart';

// TODO: الشروط بترجع من الـ API لما الاند بوينت بتاعها يجهز، والنصوص دي مؤقتة
final _tempDocuments = {
  PolicyType.terms: PolicyDocument(
    updatedAt: DateTime(2026, 10, 25),
    highlight: (
      title: 'طريق واضح بيننا.',
      body:
          'تعرّف على شروط استخدام حسابك، وتوثيق الصيانة وطلب قطع الغيار. '
          'سلامتك وحقوقك أساس كل رحلة.',
    ),
    sections: const [
      (
        title: 'قبول الشروط',
        body:
            'باستخدام تطبيق مدار، تقر بأنك اطلعت على هذه الشروط وسياسة '
            'الخصوصية وتوافق على الالتزام بهما. التطبيق مخصص لركاب الشركة '
            'المسجلين، ولا يحل محل عقد تأجير الدراجة أو تعليمات السلامة. عند '
            'التعارض، تُراعى الأحكام الإلزامية في الأنظمة المعمول بها وشروط '
            'العقد الموقع.',
      ),
      (
        title: 'الحساب ومسؤولية الدخول',
        body:
            'تنشئ شركة مدار حساب الراكب وتسلّمه بيانات الدخول. أنت مسؤول عن '
            'الحفاظ على سريتها وعدم مشاركة الحساب. أبلغ الشركة فور الاشتباه '
            'باستخدام غير مصرح به. عند فقد كلمة المرور، تواصل مع الشركة للتحقق '
            'من هويتك وإعادة تعيينها. لا يتيح التطبيق إنشاء حساب ذاتي.',
      ),
      (
        title: 'استخدام الدراجة والسلامة',
        body:
            'استخدم الدراجة المخصصة لك فقط وفق عقد التأجير وتعليمات الشركة '
            'والأنظمة المرورية. افحص الدراجة قبل كل رحلة، وارتدِ معدات الوقاية، '
            'ولا تواصل القيادة عند ظهور عطل أو تسرب زيت أو مؤشر خطر. تنبيهات '
            'التطبيق مساعدة ولا تغني عن الفحص أو إرشادات المصنّع.',
      ),
      (
        title: 'دورة الزيت والإثبات',
        body:
            'يعرض التطبيق المسافة منذ آخر تغيير زيت معتمد، وهي منفصلة عن العداد '
            'الكلي للدراجة. يلتزم الراكب بتغيير الزيت في موعده وإرسال صورة '
            'واضحة وصحيحة كإثبات، ولا يُصفَّر العداد إلا بعد موافقة المشرف. '
            'الإثباتات غير الواضحة أو غير المطابقة لقراءة العداد قد تُرفض.',
      ),
      (
        title: 'طلبات قطع الغيار',
        body:
            'طلبات القطع طلبات توريد للمراجعة وليست عملية دفع. يراجع المشرف '
            'التوفر قبل تأكيد الاستلام، والأسعار المعروضة شاملة الضريبة.',
      ),
      (
        title: 'إنهاء الحساب',
        body:
            'يمكن للشركة إيقاف الحساب عند انتهاء التعاقد أو مخالفة الشروط. '
            'ويمكنك طلب حذف حسابك في أي وقت من صفحة حسابي، ويبقى الحساب فعالاً '
            'حتى تعتمد إدارة الشركة الطلب.',
      ),
    ],
  ),
};

/// الشروط والأحكام: كارت ملخص لو موجود، وبعده الأقسام مترقّمة
class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, required this.type});

  final PolicyType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final document = _tempDocuments[type]!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(
                  title: type.titleKey.tr(),
                  subtitle: 'policy.lastUpdated'.tr(
                    args: [context.formatDate(document.updatedAt)],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (document.highlight case final highlight?) ...[
                        _HighlightCard(type: type, section: highlight),
                        Gaps.v(14.h),
                      ],
                      Text(
                        'policy.readTime'.plural(
                          document.readMinutes,
                          args: [context.formatNumber(document.readMinutes)],
                        ),
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.textHint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      for (final (index, section)
                          in document.sections.indexed) ...[
                        Gaps.v(20.h),
                        Text(
                          'policy.sectionTitle'.tr(
                            args: [
                              context.formatNumber(index + 1),
                              section.title,
                            ],
                          ),
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Gaps.v(8.h),
                        Text(
                          section.body,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13.sp,
                            color: colors.textSecondary,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.type, required this.section});

  final PolicyType type;
  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dark = type.darkHighlight;
    final onCard = dark ? context.colorScheme.onSecondary : colors.textPrimary;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 18.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: dark ? colors.secondary : colors.primaryContainer,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.highlightIcon, color: colors.primary, size: 26.r),
              Gaps.h(10.w),
              Expanded(
                child: Text(
                  section.title,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: onCard,
                  ),
                ),
              ),
            ],
          ),
          Gaps.v(10.h),
          Text(
            section.body,
            style: context.textTheme.bodySmall?.copyWith(
              color: dark
                  ? onCard.withValues(alpha: 0.75)
                  : colors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
