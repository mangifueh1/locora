import 'package:flutter/material.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class LocoraTextField extends StatelessWidget {
  const LocoraTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.bottomPadding = 14,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        spacing: 6,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppTextSizes.label,
              fontWeight: FontWeight.w600,
              color: AppColors.tertiary,
            ),
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,

            decoration: InputDecoration(
              contentPadding: .all(14),
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.outlineVariant),
              focusedBorder: OutlineInputBorder(
                borderRadius: .circular(4),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              prefixIcon: icon == null ? null : Icon(icon),
              suffixIcon: suffix,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
