import 'package:flutter/material.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class ContactIntro extends StatelessWidget {
  const ContactIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5),
            Text(
              'INQUIRIES & DISPATCH',
              style: TextStyle(
                fontSize: AppTextSizes.eyebrow,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "Let's talk.",
          style: TextStyle(
            fontSize: AppTextSizes.sectionTitle,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 5),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520),
          child: Text(
            'Have a question about Locora, want to integrate it into your business, or need help getting started? Send us a message.',
            style: TextStyle(
              fontSize: AppTextSizes.body,
              height: 1.45,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
