import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';

class LocoraFooter extends StatelessWidget {
  const LocoraFooter({
    super.key,
    this.onHomePressed,
    this.onContactPressed,
    this.onLoginPressed,
    this.onGetStartedPressed,
    this.onPrivacyPressed,
    this.onTermsPressed,
  });

  final VoidCallback? onHomePressed;
  final VoidCallback? onContactPressed;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onGetStartedPressed;
  final VoidCallback? onPrivacyPressed;
  final VoidCallback? onTermsPressed;

  @override
  Widget build(BuildContext context) {
    final compactViewport = MediaQuery.sizeOf(context).width < 780;
    final homePressed = onHomePressed ?? () => context.go('/');
    final contactPressed = onContactPressed ?? () => context.go('/contact');
    final loginPressed = onLoginPressed ?? () => context.go('/login');
    final getStartedPressed =
        onGetStartedPressed ?? () => context.go('/business/register');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      padding: compactViewport
          ? const EdgeInsets.fromLTRB(20, 28, 20, 24)
          : EdgeInsets.fromLTRB(65, 38, 65, 34),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 780;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FooterBrand(),
                    SizedBox(height: 28),
                    _FooterLinks(
                      onHomePressed: homePressed,
                      onContactPressed: contactPressed,
                      onLoginPressed: loginPressed,
                      onGetStartedPressed: getStartedPressed,
                      onPrivacyPressed: onPrivacyPressed,
                      onTermsPressed: onTermsPressed,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _FooterBrand(),
                  _FooterLinks(
                    onHomePressed: homePressed,
                    onContactPressed: contactPressed,
                    onLoginPressed: loginPressed,
                    onGetStartedPressed: getStartedPressed,
                    onPrivacyPressed: onPrivacyPressed,
                    onTermsPressed: onTermsPressed,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 42),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
          SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 560;
              final copyright = Text(
                '\u00A9 2025 Locora Technologies Inc. All rights reserved.',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copyright,
                    SizedBox(height: 18),
                    const FooterStatusBadge(),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [copyright, const FooterStatusBadge()],
              );
            },
          ),
        ],
      ),
    );
  }
}

class FooterStatusBadge extends StatelessWidget {
  const FooterStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 7),
          Text(
            'Operational Precision',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/locora_icon.svg',
          width: 92,
          height: 23,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 8),
        Text(
          'Deliver to the exact place.',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({
    this.onHomePressed,
    this.onContactPressed,
    this.onLoginPressed,
    this.onGetStartedPressed,
    this.onPrivacyPressed,
    this.onTermsPressed,
  });

  final VoidCallback? onHomePressed;
  final VoidCallback? onContactPressed;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onGetStartedPressed;
  final VoidCallback? onPrivacyPressed;
  final VoidCallback? onTermsPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      runAlignment: WrapAlignment.end,
      spacing: 30,
      runSpacing: 14,
      children: [
        FooterLink(label: 'Home', isActive: true, onPressed: onHomePressed),
        FooterLink(label: 'Contact', onPressed: onContactPressed),
        FooterLink(label: 'Log In', onPressed: onLoginPressed),
        FooterLink(label: 'Get Started', onPressed: onGetStartedPressed),
        FooterLink(label: 'Privacy Policy', onPressed: onPrivacyPressed),
        FooterLink(label: 'Terms of Service', onPressed: onTermsPressed),
      ],
    );
  }
}

class FooterLink extends StatelessWidget {
  const FooterLink({
    super.key,
    required this.label,
    this.isActive = false,
    this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
