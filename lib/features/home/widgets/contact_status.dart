import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class ContactStatus extends StatelessWidget {
  const ContactStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: const [_ApiStatusCard()]);
  }
}

class _ApiStatusCard extends StatelessWidget {
  const _ApiStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: AppTextSizes.eyebrow.sp,
                  color: AppColors.onSurfaceVariant,
                ),

                children: const [
                  TextSpan(
                    text: 'API status: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: 'All systems operational\n'),
                  TextSpan(text: '99.99% uptime verified past 90 days'),
                ],
              ),
            ),
          ),
          Icon(
            Icons.verified_outlined,
            size: 13.sp,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
