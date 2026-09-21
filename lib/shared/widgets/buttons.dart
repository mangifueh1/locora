import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.labelSize,
    this.width,
    this.color,
    this.labelColor,
    this.suffixIcon,
  });

  final String label;
  final void Function()? onPressed;
  final double? height;
  final double? width;
  final double? labelSize;
  final Color? color;
  final Color? labelColor;
  final Icon? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.primary,
      borderRadius: BorderRadius.circular(4.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.r),
        child: Container(
          padding: (height != null || width != null)
              ? null
              : EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          height: height,
          width: width,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize ?? AppTextSizes.label.sp,
                    fontWeight: FontWeight.w700,
                    color: labelColor ?? AppColors.onPrimary,
                  ),
                ),
                if (suffixIcon != null) SizedBox(width: 8.w),
                ?suffixIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
