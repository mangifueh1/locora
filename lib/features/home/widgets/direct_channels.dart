import 'package:flutter/material.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class DirectChannels extends StatelessWidget {
  const DirectChannels({super.key});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'DIRECT CHANNELS',
      child: Column(
        children: const [
          _ChannelTile(
            icon: Icons.mail_outline,
            title: 'Email',
            description: 'For general inquiries and press.',
            address: 'hello@locora.com',
          ),
          _ChannelTile(
            icon: Icons.storefront_outlined,
            title: 'Business inquiries',
            description:
                'Talk to us about integrating Locora into your business.',
            address: 'sales@locora.com',
          ),
          _ChannelTile(
            icon: Icons.support_agent,
            title: 'Support',
            description:
                "Need help? Send us a message and we'll get back to you.",
            address: 'support@locora.com',
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTextSizes.eyebrow,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.25,
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.address,
  });

  final IconData icon;
  final String title;
  final String description;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTextSizes.cardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppTextSizes.eyebrow,
                    height: 1.25,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '$address ›',
                  style: TextStyle(
                    fontSize: AppTextSizes.eyebrow,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
