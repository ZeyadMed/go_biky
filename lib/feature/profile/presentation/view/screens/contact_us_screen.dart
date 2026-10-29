import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/profile/data/model/contact_model.dart';
import 'package:go_biky/feature/profile/presentation/view/widgets/contact_channels.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/contacts_cubit.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/profile_cubit.dart';

/// تواصل معنا: أرقام الاتصال والواتساب زي ما الإدارة ضايفاها
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _contactsCubit = getIt<ContactsCubit>();

  @override
  void initState() {
    super.initState();
    _contactsCubit.getContacts();
  }

  @override
  void dispose() {
    _contactsCubit.close();
    super.dispose();
  }

  /// الشات بيتفتح ومعاه رسالة جاهزة فيها اسم الراكب لو بياناته وصلت
  String get _whatsAppMessage {
    final name = getIt<ProfileCubit>().state.data?.fullName;
    return name == null || name.isEmpty
        ? 'contactUs.whatsappMessageNoName'.tr()
        : 'contactUs.whatsappMessage'.tr(args: [name]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(title: 'contactUs.title'.tr()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'contactUs.headline'.tr(),
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                      Gaps.v(16.h),
                      BlocBuilder<ContactsCubit, BaseState<ContactModel>>(
                        bloc: _contactsCubit,
                        builder: (context, state) => ContactChannelsList(
                          state: state,
                          onRetry: _contactsCubit.getContacts,
                          whatsAppMessage: _whatsAppMessage,
                        ),
                      ),
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
