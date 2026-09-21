import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/widgets/buttons.dart';

class ContactCta extends StatelessWidget {
  const ContactCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to simplify delivery?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Coordinate exact drop-offs and integrate precision waypoint verification in minutes.',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            width: 115.w,
            height: 34.h,
            label: 'Get Started',
            labelSize: 8.sp,
            onPressed: () => context.go('/business/register'),
            suffixIcon: Icon(
              Icons.arrow_forward,
              size: 12.sp,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
