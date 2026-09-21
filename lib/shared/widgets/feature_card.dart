import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.linkLabel,
    this.showArrow = false,
    this.onLinkPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String linkLabel;
  final bool showArrow;
  final VoidCallback? onLinkPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLinkPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.r,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20.h,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 16.sp),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTextSizes.cardTitle.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: AppTextSizes.cardBody.sp,
                height: 1.55,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    linkLabel,
                    style: TextStyle(
                      fontSize: AppTextSizes.link.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                if (showArrow)
                  Icon(
                    Icons.arrow_forward,
                    size: 17.sp,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCardsRow extends StatelessWidget {
  const FeatureCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FeatureCard(
            icon: Icons.explore_outlined,
            title: 'Precise Locations',
            description: 'Customers can select exactly where they want their delivery on an intuitive map picker.',
            linkLabel: 'Coordinate-level resolution',
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: FeatureCard(
            icon: Icons.integration_instructions_outlined,
            title: 'Simple Integration',
            description: 'Connect Locora to the websites and apps your business already uses with our modern REST and webhook APIs.',
            linkLabel: 'See API Docs',
            showArrow: true,
            onLinkPressed: () => context.go('/api-docs'),
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: FeatureCard(
            icon: Icons.visibility_outlined,
            title: 'Delivery Visibility',
            description: "Businesses and drivers can see where deliveries are and where they're going in real time.",
            linkLabel: 'Real-time order tracking.',
          ),
        ),
      ],
    );
  }
}
