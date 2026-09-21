import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';
import 'package:locora/shared/widgets/buttons.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(label: 'Home', route: '/'),
      _NavItem(label: 'Contact', route: '/contact'),
      _NavItem(label: 'API Docs', route: '/api-docs'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 45.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: .center,
          children: [
            _BrandLogo(),
            SizedBox(width: 32.w),
            Expanded(
              child: Row(
                children: navItems
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(right: 28.w),
                        child: _NavLink(
                          label: item.label,
                          isActive:
                              item.route == GoRouterState.of(context).uri.path,
                          onPressed: item.route == null
                              ? null
                              : () => context.go(item.route!),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              children: [
                _TextActionButton(
                  label: 'Log In',
                  onPressed: () => context.go('/login'),
                ),
                const SizedBox(width: 14),
                PrimaryButton(
                  label: 'Get Started',
                  onPressed: () => context.go('/business/register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 106.w,
      height: 32.h,
      child: SvgPicture.asset(
        'assets/icons/locora_icon.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSizes.small.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),

            if (isActive)
              Container(
                margin: EdgeInsets.only(top: 6.r),
                width: 37.w,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTextSizes.small.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, this.route});

  final String label;
  final String? route;
}
