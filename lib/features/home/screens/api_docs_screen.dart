import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';
import 'package:locora/shared/widgets/buttons.dart';
import 'package:locora/shared/widgets/footer.dart';
import 'package:locora/shared/widgets/navbar.dart';

class ApiDocsScreen extends StatelessWidget {
  const ApiDocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Navbar(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 65.w, vertical: 72.h),
                child: Center(
                  child: Container(
                    width: 760.w,
                    padding: EdgeInsets.all(48.r),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppColors.primary,
                            size: 32.sp,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'API Documentation',
                          style: TextStyle(
                            fontSize: AppTextSizes.sectionTitle.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'API Documentation would be uploaded very soon.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTextSizes.body.sp,
                            height: 1.6,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        PrimaryButton(
                          label: 'Back to Home',
                          onPressed: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),
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
