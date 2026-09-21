import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/shared/widgets/buttons.dart';

import 'package:locora/shared/widgets/navbar.dart';
import 'package:locora/shared/widgets/feature_card.dart';
import 'package:locora/shared/widgets/footer.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Navbar(),
              _HeroSection(),
              _LocoraPrecisionSection(),
              _FeatureSection(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 48.h, horizontal: 65.w),
                padding: EdgeInsets.all(48.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .spaceBetween,
                  spacing: 70.w,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600.w),
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        spacing: 4.h,
                        children: [
                          Row(
                            spacing: 4.w,
                            mainAxisSize: .min,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.secondary,
                                radius: 4.r,
                              ),
                              Text(
                                'ENTERPRISE & MERCHANT READY',
                                style: TextStyle(
                                  fontSize: AppTextSizes.eyebrow.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.55,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Make every delivery easier to find.',
                            style: TextStyle(
                              fontSize: AppTextSizes.sectionTitle.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Connect your business to Locora and give your customers a simpler way to share their delivery location.',
                            style: TextStyle(
                              fontSize: AppTextSizes.body.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onSurfaceVariant,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        PrimaryButton(
                          width: 250.w,
                          height: 40.h,
                          label: 'Create a Business Account',
                          onPressed: () => context.go('/business/register'),
                        ),
                        SizedBox(width: 12.w),
                        PrimaryButton(
                          width: 120.w,
                          height: 40.h,
                          label: 'Talk to Sales',
                          onPressed: () => context.go('/contact'),
                          color: AppColors.background,
                          labelColor: AppColors.onBackground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const LocoraFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 65.w, vertical: 48.h),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'ENGINEERED INFRASTRUCTURE',
            style: TextStyle(
              fontSize: AppTextSizes.eyebrow.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.55,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Built to make delivery more precise.",
            style: TextStyle(
              fontSize: AppTextSizes.sectionTitle.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 600.w,
            child: Text(
              "Purpose-built infrastructure for emerging and non-standard address markets.",
              style: TextStyle(
                fontSize: AppTextSizes.body.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              softWrap: true,
            ),
          ),
          SizedBox(height: 48.h),
          SizedBox(
            // height: 250.h,
            child: const FeatureCardsRow(),
          ),
        ],
      ),
    );
  }
}

class _LocoraPrecisionSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: .symmetric(horizontal: 65.w, vertical: 48.h),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'THE LAST-MILE DILEMMA',
            style: TextStyle(
              fontSize: AppTextSizes.eyebrow.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.55,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Home delivery shouldn't depend on an address.",
            style: TextStyle(
              fontSize: AppTextSizes.sectionTitle.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 600.w,
            child: Text(
              "Customers don't always have a standard street address. Locora lets them share exactly where they are, so businesses and drivers know where to deliver.",
              style: TextStyle(
                fontSize: AppTextSizes.body.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              softWrap: true,
            ),
          ),
          SizedBox(height: 48.h),
          Container(
            height: 410.h,
            padding: .symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: .start,
              spacing: 30.w,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/chat_discussion.png',
                    fit: .cover,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    'assets/images/locora_precision.png',
                    fit: .cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 48.h, horizontal: 65.w),
      child: Row(
        crossAxisAlignment: .center,
        mainAxisAlignment: .spaceBetween,
        spacing: 70.w,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.h),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              spacing: 24.h,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    spacing: 4.w,
                    mainAxisSize: .min,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.secondaryContainer,
                        radius: 4.r,
                      ),
                      Text(
                        'LOCATION INFRASTRUCTURE API',
                        style: TextStyle(
                          fontSize: AppTextSizes.eyebrow.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                          letterSpacing: 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Deliver to the exact place.',
                  style: TextStyle(
                    fontSize: AppTextSizes.sectionTitle.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Locora helps businesses collect precise customer locations and make home delivery simpler for everyone.',
                  style: TextStyle(
                    fontSize: AppTextSizes.body.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                  softWrap: true,
                ),
                Row(
                  children: [
                    PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => context.go('/business/register'),
                      suffixIcon: Icon(
                        Icons.arrow_forward,
                        size: 16.sp,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    PrimaryButton(
                      label: 'Contact Us',
                      onPressed: () => context.go('/contact'),
                      color: AppColors.background,
                      labelColor: AppColors.onBackground,
                    ),
                  ],
                ),
                Row(
                  spacing: 4.w,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.secondary,
                    ),
                    Text(
                      'No streed address required',
                      style: TextStyle(
                        fontSize: AppTextSizes.small.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: AppColors.onSurfaceVariant,
                      size: 5.r,
                    ),
                    Text(
                      'Plug-and-Play API',
                      style: TextStyle(
                        fontSize: AppTextSizes.small.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              // width: 550.w,
              // height: 430.h,
              child: Image.asset(
                'assets/images/home_hero_image.png',
                fit: .contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
