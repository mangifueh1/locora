import 'package:flutter/material.dart';
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
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: (height != null || width != null)
              ? null
              : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: height,
          width: width,
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final labelText = Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: labelSize ?? AppTextSizes.label,
                    fontWeight: FontWeight.w700,
                    color: labelColor ?? AppColors.onPrimary,
                  ),
                );
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (constraints.maxWidth.isFinite)
                      Flexible(child: labelText)
                    else
                      labelText,
                    if (suffixIcon != null) SizedBox(width: 8),
                    ?suffixIcon,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
