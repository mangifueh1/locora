import 'package:flutter/material.dart';
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
    final compact = MediaQuery.sizeOf(context).width < 900;
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
                margin: EdgeInsets.symmetric(
                  vertical: compact ? 28 : 48,
                  horizontal: compact ? 20 : 65,
                ),
                padding: EdgeInsets.all(compact ? 22 : 48),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EnterpriseCopy(compact: true),
                          const SizedBox(height: 20),
                          const _EnterpriseActions(compact: true),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: .center,
                        mainAxisAlignment: .spaceBetween,
                        spacing: 70,
                        children: [
                          const Expanded(child: _EnterpriseCopy()),
                          const _EnterpriseActions(),
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

class _EnterpriseCopy extends StatelessWidget {
  const _EnterpriseCopy({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(backgroundColor: AppColors.secondary, radius: 4),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'ENTERPRISE & MERCHANT READY',
              style: TextStyle(
                fontSize: AppTextSizes.eyebrow,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Make every delivery easier to find.',
        style: TextStyle(
          fontSize: AppTextSizes.sectionTitle,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Connect your business to Locora and give your customers a simpler way to share their delivery location.',
        style: TextStyle(
          fontSize: AppTextSizes.body,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _EnterpriseActions extends StatelessWidget {
  const _EnterpriseActions({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = [
      PrimaryButton(
        width: compact ? double.infinity : 250,
        height: 40,
        label: 'Create a Business Account',
        onPressed: () => context.go('/business/register'),
      ),
      PrimaryButton(
        width: compact ? double.infinity : 120,
        height: 40,
        label: 'Talk to Sales',
        onPressed: () => context.go('/contact'),
        color: AppColors.background,
        labelColor: AppColors.onBackground,
      ),
    ];
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [actions.first, const SizedBox(height: 10), actions.last],
      );
    }
    return Row(children: [actions.first, SizedBox(width: 12), actions.last]);
  }
}

class _FeatureSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 65,
        vertical: compact ? 32 : 48,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'ENGINEERED INFRASTRUCTURE',
            style: TextStyle(
              fontSize: AppTextSizes.eyebrow,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.55,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Built to make delivery more precise.",
            style: TextStyle(
              fontSize: AppTextSizes.sectionTitle,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: compact ? double.infinity : 600,
            child: Text(
              "Purpose-built infrastructure for emerging and non-standard address markets.",
              style: TextStyle(
                fontSize: AppTextSizes.body,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              softWrap: true,
            ),
          ),
          SizedBox(height: 48),
          SizedBox(
            // height: 250,
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
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 65,
        vertical: compact ? 32 : 48,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'THE LAST-MILE DILEMMA',
            style: TextStyle(
              fontSize: AppTextSizes.eyebrow,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.55,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Home delivery shouldn't depend on an address.",
            style: TextStyle(
              fontSize: AppTextSizes.sectionTitle,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: compact ? double.infinity : 600,
            child: Text(
              "Customers don't always have a standard street address. Locora lets them share exactly where they are, so businesses and drivers know where to deliver.",
              style: TextStyle(
                fontSize: AppTextSizes.body,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              softWrap: true,
            ),
          ),
          SizedBox(height: 48),
          if (compact) ...[
            const SizedBox(height: 22),
            Image.asset('assets/images/chat_discussion.png', fit: BoxFit.cover),
            const SizedBox(height: 14),
            Image.asset(
              'assets/images/locora_precision.png',
              fit: BoxFit.cover,
            ),
          ] else
            Container(
              height: 410,
              padding: .symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: .start,
                spacing: 30,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/chat_discussion.png',
                      fit: .fitHeight,
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/locora_precision.png',
                      fit: .fitHeight,
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
    final compact = MediaQuery.sizeOf(context).width < 900;
    final copy = Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .start,
      spacing: 20,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                radius: 4,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'LOCATION INFRASTRUCTURE API',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Deliver to the exact place.',
          style: TextStyle(
            fontSize: AppTextSizes.sectionTitle,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          'Locora helps businesses collect precise customer locations and make home delivery simpler for everyone.',
          style: TextStyle(
            fontSize: AppTextSizes.body,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            PrimaryButton(
              label: 'Get Started',
              onPressed: () => context.go('/business/register'),
              width: 200,
              height: 40,
              suffixIcon: Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.onPrimary,
              ),
            ),
            PrimaryButton(
              label: 'Contact Us',
              onPressed: () => context.go('/contact'),
              color: AppColors.background,
              labelColor: AppColors.onBackground,
              width: 200,
              height: 40,
            ),
          ],
        ),
        const Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.secondary,
              size: 18,
            ),
            Text('No street address required.'),
            Icon(Icons.circle, color: AppColors.onSurfaceVariant, size: 5),
            Text('Plug-and-Play API'),
          ],
        ),
      ],
    );
    final image = Image.asset(
      'assets/images/home_hero_image.png',
      fit: BoxFit.contain,
    );
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: compact ? 30 : 48,
        horizontal: compact ? 20 : 65,
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 26),
                SizedBox(height: 230, child: image),
              ],
            )
          : Row(
              crossAxisAlignment: .center,
              mainAxisAlignment: .spaceBetween,
              spacing: 70,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: copy,
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 700),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: image,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
